// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/Primitives/Primitives01.sol";

contract MockPrimitiveInternals is Primitives01 {
  function getMarketOutput (IUint256Oracle priceOracle, bytes memory priceOracleParams, uint input) external returns (uint output) {
    output = _getMarketOutput(priceOracle, priceOracleParams, input);
  }
}
