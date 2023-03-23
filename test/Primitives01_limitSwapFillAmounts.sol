// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

import "openzeppelin/utils/math/Math.sol";

contract Primitives01_limitSwapFillAmounts is Test, Helper  {

  using Math for uint;

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
  }

  function testLimitSwapFillAmounts_precision_2_3 () public {
    primitiveInternals.setFillAmount(DEFAULT_FILL_STATE_PARAMS, 2, 3);
    assertEq(primitiveInternals.getFillAmount(DEFAULT_FILL_STATE_PARAMS, 3), 2);
  }

  function testLimitSwapFillAmounts_precision_29_30 () public {
    primitiveInternals.setFillAmount(DEFAULT_FILL_STATE_PARAMS, 2999, 3000);
    assertEq(primitiveInternals.getFillAmount(DEFAULT_FILL_STATE_PARAMS, 3000), 2999);
  }

  function testLimitSwapFillAmounts_precision_largeDenominator () public {
    primitiveInternals.setFillAmount(DEFAULT_FILL_STATE_PARAMS, 1, 10**9);
    assertEq(primitiveInternals.getFillAmount(DEFAULT_FILL_STATE_PARAMS, 10**9), 1);
  }

  function testLimitSwapFillAmounts_precision_largeNumbers () public {
    primitiveInternals.setFillAmount(DEFAULT_FILL_STATE_PARAMS, 2 * 10**26, 3 * 10**26);
    assertEq(primitiveInternals.getFillAmount(DEFAULT_FILL_STATE_PARAMS, 3 * 10**26), 2 * 10**26);
  }

}
