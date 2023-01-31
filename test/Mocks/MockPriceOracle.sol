// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/Interfaces/IPriceOracle.sol";

contract MockPriceOracle is IPriceOracle {
  function price(bytes memory params) external pure override returns (uint256) {
    return abi.decode(params, (uint256));
  }
}
