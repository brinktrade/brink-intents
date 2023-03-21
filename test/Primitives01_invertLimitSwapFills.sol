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

  function testInvertLimitSwapFills () public {
    // uint wethInputAmount = 1450_000000;

    // vm.prank(TRADER_1);
    // USDC_ERC20.approve(address(primitives), usdcInputAmount);

    // uint wethOutputAmount = usdcInputAmount * MAGIC_TWAP_PRICE_USDC_ETH_1000_0 / Q96;
    // bytes memory fillCall50Percent = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, wethOutputAmount / 4, new uint[](0));

    // bytes32 limitSwapId = keccak256("123");

    // assertEq(primitives.getLimitSwapFilledAmount(limitSwapId, usdcInputAmount), 0);
    // startBalances(address(filler));
    // startBalances(TRADER_1);

    // // fill 25%
    // primitives.limitSwap(
    //   limitSwapId,
    //   TRADER_1,
    //   WETH_Token,
    //   DOODLES_Token,
    //   usdcInputAmount,
    //   flatPriceCurve,
    //   abi.encode(MAGIC_TWAP_PRICE_USDC_ETH_1000_0),
    //   UnsignedLimitSwapData(
    //     address(filler),
    //     usdcInputAmount / 4,
    //     EMPTY_IDS_PROOF,
    //     EMPTY_IDS_PROOF,
    //     Call(address(filler), fillCall50Percent)
    //   )
    // );


    // // D0 -> 1.2 ETH
    // // D1 -> 1.3 ETH
    // // 1.29 ETH -> D1
    // // 1.19 ETH -> D0



    // endBalances(address(filler));
    // endBalances(TRADER_1);

    // assertEq(primitives.getLimitSwapFilledAmount(limitSwapId, usdcInputAmount), usdcInputAmount / 4);
    
    // assertEq(diffBalance(USDC, TRADER_1), -int(usdcInputAmount / 4));
    // assertEq(diffBalance(USDC, address(filler)), int(usdcInputAmount / 4));
    // assertEq(diffBalance(WETH, TRADER_1), int(wethOutputAmount / 4));
    // assertEq(diffBalance(WETH, address(filler)), -int(wethOutputAmount / 4));
  }

}
