// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Account_signedMetaDelegateCall is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
      setupFiller();
      setupProxy0();
  }

  // test for signed metaDelegateCall
  function testAccount_signedMetaDelegateCall () public {
    bytes memory intentData;
    bytes32 intentHash;
    uint expectedRequiredWethOutAmount;
    {
      bytes memory twapAdapterParams = abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000));
      uint usdcInAmount = 1450_000000;
      uint24 feePercent = 10000; // 1%
      uint feeMin = 0; // no minimum fixed fee

      // build intents bytes data
      bytes[][] memory intentsData = new bytes[][](1);
      intentsData[0] = new bytes[](2);
      intentsData[0][0] = segmentBuilder.useBit(0, 1);
      intentsData[0][1] = segmentBuilder.marketSwapExactInput(
        twapAdapter,
        twapAdapterParams,
        proxy0_signerAddress,
        USDC_Token,
        WETH_Token,
        usdcInAmount,
        feePercent,
        feeMin
      );

      // send declaration bytes data to intent builder
      (intentData, intentHash) = intentBuilder.declaration(
        address(proxy0_account),
        block.chainid,
        SignatureType.EIP712,
        intentsData,
        address(segments),
        address(intentTarget)
      );

      uint usdc_eth_priceX96 = twapAdapter.getUint256(twapAdapterParams);
      (,,expectedRequiredWethOutAmount) = swapIO.marketSwapExactInput_getOutput(usdcInAmount, usdc_eth_priceX96, feePercent, feeMin);
    }

    int intWethOutAmount = int(expectedRequiredWethOutAmount);
    
    // fill with exact expectedRequiredWethOutAmount. for a real market swap, filler could provide an additional amount as buffer for
    // price movement to avoid revert
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, proxy0_signerAddress, expectedRequiredWethOutAmount, new uint[](0));

    bytes memory signature = signMessageHash(proxy0_signerPrivateKey, intentHash);

    bytes memory unsignedData = unsignedDataBuilder.unsignedData(
      0, // intentIndex
      unsignedDataBuilder.unsignedMarketSwapData(
        address(filler),
        EMPTY_IDS_PROOF,
        EMPTY_IDS_PROOF,
        Call(address(filler), fillCall)
      )
    );

    startBalances(address(filler));
    startBalances(proxy0_signerAddress);

    vm.prank(proxy0_signerAddress);
    USDC_ERC20.approve(address(proxy0_account), 1450_000000);

    proxy0_account.metaDelegateCall(address(intentTarget), intentData, signature, unsignedData);

    endBalances(address(filler));
    endBalances(proxy0_signerAddress);

    assertEq(diffBalance(USDC, proxy0_signerAddress), -1450_000000);
    assertEq(diffBalance(USDC, address(filler)), 1450_000000);
    assertEq(diffBalance(WETH, proxy0_signerAddress), intWethOutAmount);
    assertEq(diffBalance(WETH, address(filler)), -intWethOutAmount);
  }

  function signMessageHash (
    bytes32 privateKey,
    bytes32 messageHash
  ) public view returns (bytes memory signature) {
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint(privateKey), messageHash);
    signature = abi.encodePacked(r, s, v);
  }

}
