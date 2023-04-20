// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "./PriceCurveBase.sol";

contract FlatPriceCurve is PriceCurveBase {

  function calcOutput (uint input, bytes memory curveParams) public pure override returns (uint output) {
    uint basePriceX96 = abi.decode(curveParams, (uint));
    output = input * basePriceX96 / Q96;
  }

  // the only param for flat curve is uint basePriceX96, no calculations needed
  function calcCurveParams (bytes memory curvePriceData) public pure override returns (bytes memory curveParams) {
    curveParams = curvePriceData;
  }

}
