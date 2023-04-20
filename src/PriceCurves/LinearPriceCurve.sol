// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "./PriceCurveBase.sol";
import "./CurveMath.sol";

// linear curve defined as:
// y = ax + b
// where x=input and y=price

contract LinearPriceCurve is PriceCurveBase, CurveMath {

  function calcOutput (uint input, bytes memory curveParams) public pure override returns (uint output) {
    (int a, int b, uint multiplier) = abi.decode(curveParams, (int, int, uint));
    uint priceX96 = uint(a * int(input) + b) / multiplier;
    output = input * priceX96 / Q96;
  }

  /** 
   * calc a and b for a linear curve (y = ax + b)
   *
   * unit 1 on this curve will sell for p0
   * unit T-1 on this curve will sell for p1
   *
   * a = (p1 - p0) / (2*T - 2)
   * b = p0 - a
   *
   * the curve is multiplied by `multiplier` to maintain precision
   *
   * this calculation can be done off-chain, it does not need to be gas optimized
   */
  function calcCurveParams (bytes memory curvePriceData) public pure override returns (bytes memory curveParams) {
    (int totalInput, int priceX96_0, int priceX96_1) = abi.decode(curvePriceData, (int, int, int));
    int n = priceX96_1 - priceX96_0;
    int d = 2 * totalInput - 2;
    uint multiplier = calcMultiplier(n, d);
    int a = n * int(multiplier) / d;
    int b = priceX96_0 * int(multiplier) - a;
    curveParams = abi.encode(a, b, multiplier);
  }

}