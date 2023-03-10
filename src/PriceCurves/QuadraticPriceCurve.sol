// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../Interfaces/IPriceCurve.sol";
import "./PriceCurveBase.sol";

// quadratic curve defined as:
// y = ax^2 + b
// where x=input and y=price

// contract QuadraticPriceCurve is IPriceCurve {
contract QuadraticPriceCurve {

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

    (int a, int b) = abi.decode(curveParams, (int, int));

    uint filledOutput = calcOutput(filledInput, a, b);
    uint totalOutput = calcOutput(filledInput + input, a, b);

    output = totalOutput - filledOutput;
  }

  function calcOutput (uint input, int a, int b) public pure returns (uint output) {
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
  function calcCurveParams (int totalInput, int priceX96_0, int priceX96_1) public pure returns (int a, int b) {
    a = (priceX96_0 - priceX96_1) * int(Q96) / (3 * totalInput - 3 * totalInput**2);
    b = priceX96_0 * int(Q96) - a;
  }

}