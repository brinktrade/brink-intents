// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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
    bytes memory strategyData;
    bytes32 strategyHash;
    uint expectedRequiredWethOutAmount;
    {
      bytes memory twapAdapterParams = abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000));
      uint usdcInAmount = 1450_000000;
      uint24 feePercent = 10000; // 1%
      uint feeMin = 0; // no minimum fixed fee

      Order[] memory orders = ordersBuilder.orders(
        orderBuilder.order(
          primitiveBuilder.useBit(0, 1),
          primitiveBuilder.marketSwapExactInput(
            twapAdapter,
            twapAdapterParams,
            proxy0_signerAddress,
            USDC_Token,
            WETH_Token,
            usdcInAmount,
            feePercent,
            feeMin
          )
        )
      );
      (strategyData, strategyHash) = strategyBuilder.strategy(
        address(proxy0_account),
        block.chainid,
        SignatureType.EIP712,
        orders
      );

      expectedRequiredWethOutAmount = primitives.getSwapAmountWithFee(twapAdapter, twapAdapterParams, usdcInAmount, -int24(feePercent), int(feeMin));
    }

    int intWethOutAmount = int(expectedRequiredWethOutAmount);
    
    // fill with exact expectedRequiredWethOutAmount. for a real market swap, filler could provide an additional amount as buffer for
    // price movement to avoid revert
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, proxy0_signerAddress, expectedRequiredWethOutAmount, new uint[](0));

    bytes memory signature = signMessageHash(proxy0_signerPrivateKey, strategyHash);

    bytes memory unsignedData = unsignedDataBuilder.unsignedData(
      0, // orderIndex
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

    proxy0_account.metaDelegateCall(address(strategyTarget), strategyData, signature, unsignedData);

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
