// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_limitSwap is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
  }

  function testLimitSwap_full () public {
    uint usdcInputAmount = 1450_000000;

    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(primitives), usdcInputAmount);

    uint wethOutputAmount = usdcInputAmount * MAGIC_TWAP_PRICE_USDC_ETH_1000_0 / Q96;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, wethOutputAmount, new uint[](0));

    bytes32 limitSwapId = keccak256("123");

    assertEq(primitives.getLimitSwapFilledAmount(limitSwapId, usdcInputAmount), 0);
    startBalances(address(filler));
    startBalances(TRADER_1);

    primitives.limitSwap(
      limitSwapId,
      TRADER_1,
      USDC_Token,
      WETH_Token,
      usdcInputAmount,
      flatPriceCurve,
      abi.encode(MAGIC_TWAP_PRICE_USDC_ETH_1000_0),
      UnsignedLimitSwapData(
        address(filler),
        usdcInputAmount,
        EMPTY_IDS_PROOF,
        EMPTY_IDS_PROOF,
        Call(address(filler), fillCall)
      )
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(primitives.getLimitSwapFilledAmount(limitSwapId, usdcInputAmount), usdcInputAmount);
    
    assertEq(diffBalance(USDC, TRADER_1), -int(usdcInputAmount));
    assertEq(diffBalance(USDC, address(filler)), int(usdcInputAmount));
    assertEq(diffBalance(WETH, TRADER_1), int(wethOutputAmount));
    assertEq(diffBalance(WETH, address(filler)), -int(wethOutputAmount));
  }

  function testLimitSwap_partial () public {
    uint usdcInputAmount = 1450_000000;

    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(primitives), usdcInputAmount);

    uint wethOutputAmount = usdcInputAmount * MAGIC_TWAP_PRICE_USDC_ETH_1000_0 / Q96;
    bytes memory fillCall50Percent = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, wethOutputAmount / 2, new uint[](0));

    bytes32 limitSwapId = keccak256("123");

    assertEq(primitives.getLimitSwapFilledAmount(limitSwapId, usdcInputAmount), 0);
    startBalances(address(filler));
    startBalances(TRADER_1);

    // fill 50%
    primitives.limitSwap(
      limitSwapId,
      TRADER_1,
      USDC_Token,
      WETH_Token,
      usdcInputAmount,
      flatPriceCurve,
      abi.encode(MAGIC_TWAP_PRICE_USDC_ETH_1000_0),
      UnsignedLimitSwapData(
        address(filler),
        usdcInputAmount / 2,
        EMPTY_IDS_PROOF,
        EMPTY_IDS_PROOF,
        Call(address(filler), fillCall50Percent)
      )
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(primitives.getLimitSwapFilledAmount(limitSwapId, usdcInputAmount), usdcInputAmount / 2);
    
    assertEq(diffBalance(USDC, TRADER_1), -int(usdcInputAmount / 2));
    assertEq(diffBalance(USDC, address(filler)), int(usdcInputAmount / 2));
    assertEq(diffBalance(WETH, TRADER_1), int(wethOutputAmount / 2));
    assertEq(diffBalance(WETH, address(filler)), -int(wethOutputAmount / 2));
  }

}
