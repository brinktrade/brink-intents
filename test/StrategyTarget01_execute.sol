// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract StrategyTarget01_execute is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
  }

  // test for a simple useBit + marketSwapExactInput order
  function testExecute_singleOrder () public {
    setupFiller();
    setupTrader1();

    bytes memory twapAdapterParams = abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000));
    uint usdcInAmount = 1450_000000;
    uint24 feePercent = 10000; // 1%
    uint feeMin = 0; // no minimum fixed fee

    uint expectedRequiredWethOutAmount = primitives.getSwapAmountWithFee(twapAdapter, twapAdapterParams, usdcInAmount, -int24(feePercent), int(feeMin));
    int intWethOutAmount = int(expectedRequiredWethOutAmount);
    
    // fill with exact expectedRequiredWethOutAmount. for a real market swap, filler could provide an additional amount as buffer for
    // price movement to avoid revert
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, expectedRequiredWethOutAmount, new uint[](0));

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
        TRADER_1,
        USDC_Token,
        WETH_Token,
        usdcInAmount,
        feePercent,
        feeMin
      ),
      true
    );

    Order[] memory orders = new Order[](1);
    orders[0] = Order(primitives_order0);

    bytes[] memory unsignedCalls = new bytes[](1);
    unsignedCalls[0] = abi.encode(UnsignedMarketSwapData(
      address(filler),
      EMPTY_IDS_PROOF,
      EMPTY_IDS_PROOF,
      Call(address(filler), fillCall)
    ));

    Strategy memory strategy = Strategy(
      address(primitives),
      orders,
      new Call[](0),
      new Call[](0)
    );

    startBalances(address(filler));
    startBalances(TRADER_1);

    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(strategyTarget), 1450_000000);




    // IN PROGRESS: this is reverting now at marketSwapExactInput() fn, probably because of unsigned call data encoding.
    // need to compare this calldata to the test that is passing to figure out the problem




    strategyTarget.execute(
      strategy,
      0, // order0
      unsignedCalls
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), -1450_000000);
    assertEq(diffBalance(USDC, address(filler)), 1450_000000);
    assertEq(diffBalance(WETH, TRADER_1), intWethOutAmount);
    assertEq(diffBalance(WETH, address(filler)), -intWethOutAmount);
  }

}
