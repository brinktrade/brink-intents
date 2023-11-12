// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_marketSwapExactInput is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
  }

  function testMarketSwapExactInput () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segments), 1450_000000);

    bytes memory twapAdapterParams = abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000));
    uint usdcInAmount = 1450_000000;
    uint24 feePercent = 10000; // 1%
    uint feeMin = 0; // no minimum fixed fee

    uint usdc_eth_priceX96 = twapAdapter.getUint256(twapAdapterParams);
    (,,uint expectedRequiredWethOutAmount) = swapIO.marketSwapExactInput_getOutput(usdcInAmount, usdc_eth_priceX96, feePercent, feeMin);
    int intWethOutAmount = int(expectedRequiredWethOutAmount);
    
    // fill with exact expectedRequiredWethOutAmount. for a real market swap, filler could provide an additional amount as buffer for
    // price movement to avoid revert
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, expectedRequiredWethOutAmount, new uint[](0));

    startBalances(address(filler));
    startBalances(TRADER_1);

    segments.marketSwapExactInput(
      twapAdapter,
      twapAdapterParams,
      TRADER_1,
      USDC_Token,
      WETH_Token,
      usdcInAmount,
      feePercent,
      feeMin,
      UnsignedMarketSwapData(
        address(filler),
        EMPTY_IDS_PROOF,
        EMPTY_IDS_PROOF,
        Call(address(filler), fillCall)
      )
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), -1450_000000);
    assertEq(diffBalance(USDC, address(filler)), 1450_000000);
    assertEq(diffBalance(WETH, TRADER_1), intWethOutAmount);
    assertEq(diffBalance(WETH, address(filler)), -intWethOutAmount);
  }

}
