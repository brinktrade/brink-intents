// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "../../src/Interfaces/IUint256Oracle.sol";

contract MockPriceOracle is IUint256Oracle {
  function getUint256(bytes memory params) external pure override returns (uint256) {
    return abi.decode(params, (uint256));
  }
}
