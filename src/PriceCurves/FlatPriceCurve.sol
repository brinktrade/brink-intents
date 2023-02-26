// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../Interfaces/IPriceCurve.sol";

error MaxInputExceeded(uint remainingInput);

contract FlatPriceCurve is IPriceCurve {

  uint256 internal constant Q96 = 0x1000000000000000000000000;

  function getOutput (
    uint totalInput,
    uint basePriceX96,
    uint filledInput,
    uint input
  ) public pure returns (uint output) {
    uint remainingInput = totalInput - filledInput;
    if (input > remainingInput) {
      revert MaxInputExceeded(remainingInput);
    }

    output = input * basePriceX96 / Q96;
  }

}
