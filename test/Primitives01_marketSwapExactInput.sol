// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_marketSwapExactInput is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
  }

  function testMarketSwapExactInput_erc20 () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(primitives), 1450_000000);

    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, 1_000000000000000000, new uint[](0));

    startBalances(address(filler));
    startBalances(TRADER_1);

    primitives.marketSwapExactInput(
      twapAdapter,
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)),
      TRADER_1,
      USDC_Token,
      WETH_Token,
      1450_000000,
      10000, // 1%
      0, // no minimum fixed fee
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
    assertEq(diffBalance(WETH, TRADER_1), 1_000000000000000000);
    assertEq(diffBalance(WETH, address(filler)), -1_000000000000000000);
  }

}
