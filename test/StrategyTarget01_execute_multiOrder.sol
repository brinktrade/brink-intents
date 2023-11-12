// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract IntentTarget01_execute_multiOrder is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
  }

  /*
    test for a multi part order:
      order_0: market order for 1450 USDC -> WETH
      order_1: if order_0 executed, limit buy 1 WETH -> 1 Doodle
  */
  function testExecute_multiOrder () public {
    setupFiller();
    setupTrader1();

    bytes memory twapAdapterParams = abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000));
    uint usdcInAmount = 1450_000000;
    uint24 feePercent = 10000; // 1%
    uint feeMin = 0; // no minimum fixed fee

    uint usdc_eth_priceX96 = twapAdapter.getUint256(twapAdapterParams);
    (,,uint expectedRequiredWethOutAmount) = swapIO.marketSwapExactInput_getOutput(usdcInAmount, usdc_eth_priceX96, feePercent, feeMin);
    int intWethOutAmount = int(expectedRequiredWethOutAmount);

    // order0: bit 0|1, market swap 1450 USDC -> WETH
    Segment[] memory segments_order0 = new Segment[](2);
    segments_order0[0] = Segment(
      abi.encodeWithSelector(Segments01.useBit.selector, 0, 2**0),
      false
    );
    segments_order0[1] = Segment(
      abi.encodeWithSelector(
        Segments01.marketSwapExactInput.selector,
        twapAdapter,
        twapAdapterParams,
        TRADER_1,
        USDC_Token,
        WETH_Token,
        usdcInAmount,
        feePercent,
        feeMin,
        new bytes(0) // add an empty dynamic bytes, which will be overwritten by UnsignedMarketSwapData
      ),
      true
    );

    // order1: require bit 0|1 used, limit swap 0.5 WETH -> 1 Doodle
    Segment[] memory segments_order1 = new Segment[](2);
    segments_order1[0] = Segment(
      abi.encodeWithSelector(Segments01.requireBitUsed.selector, 0, 2**0),
      false
    );
    segments_order1[1] = Segment(
      abi.encodeWithSelector(
        Segments01.limitSwapExactInput.selector,
        TRADER_1,
        WETH_Token,
        DOODLES_Token,
        5*10**17, // 0.5 WETH
        flatPriceCurve,
        abi.encode(1),
        DEFAULT_FILL_STATE_PARAMS,
        new bytes(0) // add an empty dynamic bytes, which will be overwritten by UnsignedLimitSwapData
      ),
      true
    );

    Order[] memory orders = new Order[](2);
    orders[0] = Order(segments_order0);
    orders[1] = Order(segments_order1);

    bytes[] memory unsignedCalls_fillOrder0 = new bytes[](1);
    unsignedCalls_fillOrder0[0] = abi.encode(
      address(filler),
      EMPTY_IDS_PROOF,
      EMPTY_IDS_PROOF,
      Call(
        address(filler),
        abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, expectedRequiredWethOutAmount, new uint[](0))
      )
    );

    uint[] memory doodleIds = new uint[](1);
    doodleIds[0] = 5268;
    IdsProof memory doodleIdsProof = EMPTY_IDS_PROOF;
    doodleIdsProof.ids = new uint[](1);
    doodleIdsProof.ids[0] = 5268;
    bytes[] memory unsignedCalls_fillOrder1 = new bytes[](1);
    unsignedCalls_fillOrder1[0] = abi.encode(
      address(filler),
      5*10**17,
      EMPTY_IDS_PROOF,
      doodleIdsProof,
      Call(
        address(filler),
        abi.encodeWithSelector(filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, doodleIds)
      )
    );

    Intent memory intent = Intent(
      address(segments),
      orders,
      new bytes[](0),
      new bytes[](0)
    );

    // approve for both orders
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(intentTarget), 1450_000000);
    vm.prank(TRADER_1);
    WETH_ERC20.approve(address(intentTarget), 5*10**17);


    // should revert if we try to execute order 1 before order 0
    vm.expectRevert(BitNotUsed.selector);
    intentTarget.execute(
      intent,
      UnsignedData(
        1, // order1
        unsignedCalls_fillOrder1
      )
    );

    // track balances and execute the USDC->WETH order
    startBalances(address(filler));
    startBalances(TRADER_1);
    intentTarget.execute(
      intent,
      UnsignedData(
        0, // order0
        unsignedCalls_fillOrder0
      )
    );
    endBalances(address(filler));
    endBalances(TRADER_1);
    assertEq(diffBalance(USDC, TRADER_1), -1450_000000);
    assertEq(diffBalance(USDC, address(filler)), 1450_000000);
    assertEq(diffBalance(WETH, TRADER_1), intWethOutAmount);
    assertEq(diffBalance(WETH, address(filler)), -intWethOutAmount);

    // track balances and execute the WETH->DOODLES order
    startBalances(address(filler));
    startBalances(TRADER_1);
    intentTarget.execute(
      intent,
      UnsignedData(
        1, // order1
        unsignedCalls_fillOrder1
      )
    );
    endBalances(address(filler));
    endBalances(TRADER_1);
    assertEq(diffBalance(WETH, TRADER_1), -5*10**17);
    assertEq(diffBalance(WETH, address(filler)), 5*10**17);
    assertEq(diffBalance(DOODLES, TRADER_1), 1);
    assertEq(diffBalance(DOODLES, address(filler)), -1);
  }

}
