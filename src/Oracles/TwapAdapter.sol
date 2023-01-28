// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../Interfaces/IUniswapPoolDerivedState.sol";

contract TwapAdapter is IUniswapPoolDerivedState {

  function price(IUniswapPoolDerivedState pool) public view returns (uint) {
    return 123;
  }
}
