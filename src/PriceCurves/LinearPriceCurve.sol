// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../Interfaces/IPriceCurve.sol";
import "./PriceCurveBase.sol";

// linear curve defined as:
// y = mx + b
// where x=input and y=price

contract LinearPriceCurve is IPriceCurve {

  uint256 internal constant Q96 = 0x1000000000000000000000000;

  function getOutput (
    uint totalInput,
    uint filledInput,
    uint input,
    bytes memory curveParams
  ) public pure returns (uint output) {
    uint remainingInput = totalInput - filledInput;
    if (input > remainingInput) {
      revert MaxInputExceeded(remainingInput);
    }

    (int m, int b) = abi.decode(curveParams, (int, int));

    uint filledOutput = calcOutput(filledInput, m, b);
    uint totalOutput = calcOutput(filledInput + input, m, b);

    output = totalOutput - filledOutput;
  }

  function calcOutput (uint input, int m, int b) public pure returns (uint output) {
    uint priceX96 = uint(m * int(input) + b) / Q96;
    output = input * priceX96 / Q96;
  }

  // calc m and b for a linear (y=mx+b) curve starting at priceX96_0 and ending at priceX96_1
  // the first unit on this curve will sell for priceX96_0
  // the last unit on this curve will sell for priceX96_1
  // m = (priceX96_1 - priceX96_0) / (2 * totalInput - 2)
  // b = priceX96_0 - m
  function calcCurveParams (int totalInput, int priceX96_0, int priceX96_1) public pure returns (int m, int b) {
    m = (priceX96_1 - priceX96_0) * int(Q96) / (2 * totalInput - 2);
    b = priceX96_0 * int(Q96) - m;
  }

}