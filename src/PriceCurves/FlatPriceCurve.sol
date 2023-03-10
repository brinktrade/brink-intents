// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../Interfaces/IPriceCurve.sol";
import "./PriceCurveBase.sol";

contract FlatPriceCurve is IPriceCurve {

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

    uint basePriceX96 = abi.decode(curveParams, (uint));

    output = input * basePriceX96 / Q96;
  }

}
