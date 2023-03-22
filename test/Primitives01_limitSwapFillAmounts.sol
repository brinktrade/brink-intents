// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

import "openzeppelin/utils/math/Math.sol";

contract Primitives01_limitSwapFillAmounts is Test, Helper  {

  using Math for uint;

  bytes32 id;

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
    id = keccak256("12345");
  }

  function testLimitSwapFillAmounts_precision_2_3 () public {
    primitiveInternals.setLimitSwapFilledAmount(id, 2, 3);
    assertEq(primitiveInternals.getLimitSwapFilledAmount(id, 3), 2);
  }

  function testLimitSwapFillAmounts_precision_29_30 () public {
    primitiveInternals.setLimitSwapFilledAmount(id, 2999, 3000);
    assertEq(primitiveInternals.getLimitSwapFilledAmount(id, 3000), 2999);
  }

  function testLimitSwapFillAmounts_precision_largeDenominator () public {
    primitiveInternals.setLimitSwapFilledAmount(id, 1, 10**9);
    assertEq(primitiveInternals.getLimitSwapFilledAmount(id, 10**9), 1);
  }

  function testLimitSwapFillAmounts_precision_largeNumbers () public {
    primitiveInternals.setLimitSwapFilledAmount(id, 2 * 10**26, 3 * 10**26);
    assertEq(primitiveInternals.getLimitSwapFilledAmount(id, 3 * 10**26), 2 * 10**26);
  }

}
