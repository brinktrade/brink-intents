// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Account_signedMetaDelegateCall is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
  }

  // test for signed metaDelegateCall
  function testAccount_signedMetaDelegateCall () public {
    setupFiller();
    setupProxy0();

    bytes memory twapAdapterParams = abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000));
    uint usdcInAmount = 1450_000000;
    uint24 feePercent = 10000; // 1%
    uint feeMin = 0; // no minimum fixed fee

    uint expectedRequiredWethOutAmount = primitives.getSwapAmountWithFee(twapAdapter, twapAdapterParams, usdcInAmount, -int24(feePercent), int(feeMin));
    int intWethOutAmount = int(expectedRequiredWethOutAmount);
    
    // fill with exact expectedRequiredWethOutAmount. for a real market swap, filler could provide an additional amount as buffer for
    // price movement to avoid revert
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, proxy0_signerAddress, expectedRequiredWethOutAmount, new uint[](0));

    Primitive[] memory primitives_order0 = new Primitive[](2);
    
    // useBit primitive
    primitives_order0[0] = Primitive(
      abi.encodeWithSelector(Primitives01.useBit.selector, 0, 1),
      false
    );

    // marketSwapExactInput primitive
    primitives_order0[1] = Primitive(
      abi.encodeWithSelector(
        Primitives01.marketSwapExactInput.selector,
        twapAdapter,
        twapAdapterParams,
        proxy0_signerAddress,
        USDC_Token,
        WETH_Token,
        usdcInAmount,
        feePercent,
        feeMin,
        new bytes(0) // add an empty dynamic bytes, which will be overwritten by UnsignedMarketSwapData
      ),
      true
    );

    Order[] memory orders = new Order[](1);
    orders[0] = Order(primitives_order0);

    bytes[] memory unsignedCalls = new bytes[](1);

    // encode the UnsignedMarketSwapData.
    // don't wrap in UnsignedMarketSwapData() struct type because this adds additional data that will break the call
    unsignedCalls[0] = abi.encode(
      address(filler),
      EMPTY_IDS_PROOF,
      EMPTY_IDS_PROOF,
      Call(address(filler), fillCall)
    );

    bytes memory data = strategyExecuteData(orders, new Call[](0), new Call[](0));
    bytes32 msgHash = messageHash(address(strategyTarget), data, address(proxy0_account));
    bytes memory signature = signMessageHash(proxy0_signerPrivateKey, msgHash);
    bytes memory unsignedData = abi.encode(0, unsignedCalls);

    startBalances(address(filler));
    startBalances(proxy0_signerAddress);

    vm.prank(proxy0_signerAddress);
    USDC_ERC20.approve(address(proxy0_account), 1450_000000);

    proxy0_account.metaDelegateCall(address(strategyTarget), data, signature, unsignedData);

    endBalances(address(filler));
    endBalances(proxy0_signerAddress);

    assertEq(diffBalance(USDC, proxy0_signerAddress), -1450_000000);
    assertEq(diffBalance(USDC, address(filler)), 1450_000000);
    assertEq(diffBalance(WETH, proxy0_signerAddress), intWethOutAmount);
    assertEq(diffBalance(WETH, address(filler)), -intWethOutAmount);
  }

  function strategyExecuteData (
    Order[] memory orders,
    Call[] memory beforeCalls,
    Call[] memory afterCalls
  ) public view returns (bytes memory data) {
    // encode strategy data without using Strategy struct
    bytes memory strategyData = abi.encode(
      address(primitives),
      orders,
      beforeCalls,
      afterCalls
    );

    // create a memory pointer to the encoded strategy data, which starts after 64 bytes (after the two pointers)
    bytes32 strategyPtr = 0x0000000000000000000000000000000000000000000000000000000000000040;

    // create a memory pointer to where unsigned data will be appended,
    // which will be after 64 bytes (for the two pointers) plus the length of the encoded strategy
    bytes32 unsignedDataPtr = bytes32(strategyData.length + 0x40); 

    data = bytes.concat(
      strategyTarget.execute.selector, // bytes4: fn selector
      strategyPtr,        // bytes32: memory pointer to strategy data
      unsignedDataPtr,    // bytes32: memory pointer to unsigned data
      strategyData        // bytes: encoded strategy
    );
  }

  function messageHash (
    address to,
    bytes memory data,
    address account
  ) public view returns (bytes32 messageHash) {
    bytes32 dataHash = keccak256(
      abi.encode(
        keccak256("MetaDelegateCall(address to,bytes data)"), // META_DELEGATE_CALL_TYPEHASH
        to,
        keccak256(data)
      )
    );
    messageHash = keccak256(abi.encodePacked(
      "\x19\x01",
      keccak256(abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256("BrinkAccount"),
        keccak256("1"),
        block.chainid,
        account
      )),
      dataHash
    ));
  }

  function signMessageHash (
    bytes32 privateKey,
    bytes32 messageHash
  ) public view returns (bytes memory signature) {
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint(privateKey), messageHash);
    signature = abi.encodePacked(r, s, v);
  }

}
