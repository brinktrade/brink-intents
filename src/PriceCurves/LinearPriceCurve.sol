// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "./PriceCurveBase.sol";

// linear curve defined as:
// y = ax + b
// where x=input and y=price

contract LinearPriceCurve is PriceCurveBase {

  function calcOutput (uint input, bytes memory curveParams) public pure override returns (uint output) {
    (int a, int b) = abi.decode(curveParams, (int, int));
    uint priceX96 = uint(a * int(input) + b) / Q96;
    output = input * priceX96 / Q96;
  }

  // calc m and b for a linear (y=ax+b) curve starting at priceX96_0 and ending at priceX96_1
  // the first unit on this curve will sell for priceX96_0
  // the last unit on this curve will sell for priceX96_1
  // m = (priceX96_1 - priceX96_0) / (2 * totalInput - 2)
  // b = priceX96_0 - a
  function calcCurveParams (bytes memory curvePriceData) public pure override returns (bytes memory curveParams) {
    (int totalInput, int priceX96_0, int priceX96_1) = abi.decode(curvePriceData, (int, int, int));
    int a = (priceX96_1 - priceX96_0) * int(Q96) / (2 * totalInput - 2);
    int b = priceX96_0 * int(Q96) - a;
    curveParams = abi.encode(a, b);
  }

}