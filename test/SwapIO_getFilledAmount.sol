// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";

contract SwapIO_getFilledAmount is Test, Helper  {

  using Math for uint;

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
  }

  function testLimitSwapFilledAmounts_precision_2_3 () public {
    segmentInternals.setFilledAmount(DEFAULT_FILL_STATE_PARAMS, 2, 3);
    int fillStateX96 = segmentInternals.getFillStateX96(DEFAULT_FILL_STATE_PARAMS.id);
    assertEq(segmentInternals.getFilledAmount(DEFAULT_FILL_STATE_PARAMS, fillStateX96, 3), 2);
  }

  function testLimitSwapFilledAmounts_precision_29_30 () public {
    segmentInternals.setFilledAmount(DEFAULT_FILL_STATE_PARAMS, 2999, 3000);
    int fillStateX96 = segmentInternals.getFillStateX96(DEFAULT_FILL_STATE_PARAMS.id);
    assertEq(segmentInternals.getFilledAmount(DEFAULT_FILL_STATE_PARAMS, fillStateX96, 3000), 2999);
  }

  function testLimitSwapFilledAmounts_precision_largeDenominator () public {
    segmentInternals.setFilledAmount(DEFAULT_FILL_STATE_PARAMS, 1, 10**9);
    int fillStateX96 = segmentInternals.getFillStateX96(DEFAULT_FILL_STATE_PARAMS.id);
    assertEq(segmentInternals.getFilledAmount(DEFAULT_FILL_STATE_PARAMS, fillStateX96, 10**9), 1);
  }

  function testLimitSwapFilledAmounts_precision_largeNumbers () public {
    segmentInternals.setFilledAmount(DEFAULT_FILL_STATE_PARAMS, 2 * 10**26, 3 * 10**26);
    int fillStateX96 = segmentInternals.getFillStateX96(DEFAULT_FILL_STATE_PARAMS.id);
    assertEq(segmentInternals.getFilledAmount(DEFAULT_FILL_STATE_PARAMS, fillStateX96, 3 * 10**26), 2 * 10**26);
  }

}
