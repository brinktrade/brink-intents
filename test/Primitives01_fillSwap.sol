// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_fillSwap is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
  }

  function testFillSwap_erc20 () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(primitiveInternals), 1450_000000);

    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, 1_000000000000000000, new uint[](0));

    startBalances(address(filler));
    startBalances(TRADER_1);

    primitiveInternals.fillSwap(
      USDC_Token,
      WETH_Token,
      TRADER_1,
      address(filler),
      1450_000000,
      1_000000000000000000,
      EMPTY_IDS_MERKLE_PROOF,
      EMPTY_IDS_MERKLE_PROOF,
      Call(address(filler), fillCall)
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), -1450_000000);
    assertEq(diffBalance(USDC, address(filler)), 1450_000000);
    assertEq(diffBalance(WETH, TRADER_1), 1_000000000000000000);
    assertEq(diffBalance(WETH, address(filler)), -1_000000000000000000);
  }

}
