// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "./PriceCurveBase.sol";

// quadratic curve defined as:
// y = ax^2 + b
// where x=input and y=price

contract QuadraticPriceCurve is PriceCurveBase {

  function calcOutput (uint input, bytes memory curveParams) public pure override returns (uint output) {
    (int a, int b) = abi.decode(curveParams, (int, int));
    uint priceX96 = uint(a * int(input)**2 + b) / Q96;
    output = input * priceX96 / Q96;
  }

  /** 
   * calc a and b for a quadratic curve (y = ax^2 + b)
   *
   * unit 1 on this curve will sell for priceX96_0
   * unit T on this curve will sell for priceX96_1
   *
   * a = (p0 - p1) / (3*T - 3*T^2)
   * b = p0 - a
   *
   * the curve is multiplied by Q96 to maintain precision
   */
  function calcCurveParams (bytes memory curvePriceData) public pure override returns (bytes memory curveParams) {
    (int totalInput, int priceX96_0, int priceX96_1) = abi.decode(curvePriceData, (int, int, int));
    int a = (priceX96_0 - priceX96_1) * int(Q96) / (3 * totalInput - 3 * totalInput**2);
    int b = priceX96_0 * int(Q96) - a;
    curveParams = abi.encode(a, b);
  }

}