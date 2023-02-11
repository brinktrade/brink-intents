// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/Primitives/Primitives01.sol";

contract MockPrimitiveInternals is Primitives01 {
  function getSwapAmount (IUint256Oracle priceOracle, bytes memory priceOracleParams, uint token0Amount) external returns (uint output) {
    output = _getSwapAmount(priceOracle, priceOracleParams, token0Amount);
  }

  function getSwapAmountWithFee (IUint256Oracle priceOracle, bytes memory priceOracleParams, uint token0Amount, int24 feePercent, int feeMin) external returns (uint amount) {
    amount = _getSwapAmountWithFee(priceOracle, priceOracleParams, token0Amount, feePercent, feeMin);
  }
}
