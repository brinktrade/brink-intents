// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "openzeppelin/utils/math/Math.sol";
import "../Interfaces/IPriceCurve.sol";

struct FillStateParams {
  uint64 id;
  uint128 startX96;
  bool sign;
}

contract LimitSwapIO {
  using Math for uint;

  uint256 internal constant Q96 = 0x1000000000000000000000000;

  // given an input amount to a limitSwapExactInput function, return the output amount
  function limitSwapExactInput_getOutput (
    uint input,
    uint filledInput,
    uint tokenInAmount,
    IPriceCurve priceCurve,
    bytes memory priceCurveParams
  ) public pure returns (uint output) {
    if (filledInput >= tokenInAmount) {
      return 0;
    }
    output = priceCurve.getOutput(
      tokenInAmount,
      filledInput,
      input,
      priceCurveParams
    );
  }

  // given an output to a limitSwapExactInput function, return the input
  function limitSwapExactInput_getInput () public pure returns (uint input) {
    revert("NOT IMPLEMENTED");
  }

  // given an input to a limitSwapExactOutput function, return the output
  function limitSwapExactOutput_getOutput (
  ) public pure returns (uint output) {
    revert("NOT IMPLEMENTED");
  }

  // given an ouput to a limitSwapExactOutput function, return the input
  function limitSwapExactOutput_getInput (
    uint output,
    uint filledOutput,
    uint tokenOutAmount,
    IPriceCurve priceCurve,
    bytes memory priceCurveParams
  ) public pure returns (uint input) {
    if (filledOutput >= tokenOutAmount) {
      return 0;
    }

    // the getOutput() function is used to calculate the input amount,
    // because for `limitSwapExactOutput` the price curve is inverted
    input = priceCurve.getOutput(
      tokenOutAmount,
      filledOutput,
      output,
      priceCurveParams
    );
  }

  // given fillState and total, return the amount unfilled
  function getUnfilledAmount (FillStateParams memory fillStateParams, int fillStateX96, uint totalAmount) public pure returns (uint unfilledAmount) {
    unfilledAmount = totalAmount - getFilledAmount(fillStateParams, fillStateX96, totalAmount);
  }

  // given fillState and total, return the amount filled
  function getFilledAmount (FillStateParams memory fillStateParams, int fillStateX96, uint totalAmount) public pure returns (uint fillAmount) {
    fillAmount = getFillPercentX96(fillStateParams, fillStateX96).mulDiv(totalAmount, Q96);
  }

  // given fillState, return the percent filled
  function getFillPercentX96 (FillStateParams memory fillStateParams, int fillStateX96) public pure returns (uint fillPercentX96) {
    int8 i = fillStateParams.sign ? int8(1) : -1;
    int j = fillStateParams.sign ? int(0) : int(Q96);
    fillPercentX96 = uint((fillStateX96 + int128(fillStateParams.startX96)) * i + j);
  }

}
