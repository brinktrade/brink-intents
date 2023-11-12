// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_marketSwapExactOutput is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
  }

  function testMarketSwapExactOutput () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segments), MAX_UINT);

    bytes memory twapAdapterParams = abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000));
    uint wethOutAmount = 1_000000000000000000;
    uint24 feePercent = 10000; // 1%
    uint feeMin = 0; // no minimum fixed fee

    // since the oracle is used to calculate outputToken (WETH) -> inputToken (USDC), and the pool used for TWAP is USDC-WETH (USDC address hex is < WETH address hex),
    // we need to use the TwapInverseAdapter here
    uint eth_usdc_priceX96 = twapInverseAdapter.getUint256(twapAdapterParams);
    (,,uint expectedRequiredUsdcInAmount) = swapIO.marketSwapExactOutput_getInput(wethOutAmount, eth_usdc_priceX96, feePercent, feeMin);
    int intUsdcInAmount = int(expectedRequiredUsdcInAmount);
    
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, wethOutAmount, new uint[](0));

    startBalances(address(filler));
    startBalances(TRADER_1);

    segments.marketSwapExactOutput(
      twapInverseAdapter,
      twapAdapterParams,
      TRADER_1,
      USDC_Token,
      WETH_Token,
      wethOutAmount,
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

    assertEq(diffBalance(USDC, TRADER_1), -intUsdcInAmount);
    assertEq(diffBalance(USDC, address(filler)), intUsdcInAmount);
    assertEq(diffBalance(WETH, TRADER_1), 1_000000000000000000);
    assertEq(diffBalance(WETH, address(filler)), -1_000000000000000000);
  }

}
