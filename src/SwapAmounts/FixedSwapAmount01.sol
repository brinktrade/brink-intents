// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "../Interfaces/ISwapAmount.sol";

contract FixedSwapAmount01 is ISwapAmount {
  function getAmount (bytes memory params) public view returns (uint amount) {
    amount = abi.decode(params, (uint));
  }
}
