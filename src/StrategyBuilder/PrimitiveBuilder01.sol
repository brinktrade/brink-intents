// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../Primitives/Primitives01.sol";
import "../TokenHelper/TokenHelper.sol";
import "../StrategyTarget01.sol";

contract PrimitiveBuilder01 {

  function useBit (uint bitmapIndex, uint bit) external pure returns (bytes memory) {
    return abi.encode(Primitive(
      abi.encodeWithSelector(
        Primitives01.useBit.selector,
        bitmapIndex,
        bit
      ),
      false
    ));
  }
  
  function marketSwapExactInput(
    IUint256Oracle priceOracle,
    bytes memory priceOracleParams,
    address owner,
    Token memory tokenIn,
    Token memory tokenOut,
    uint tokenInAmount,
    uint24 feePercent,
    uint feeMinTokenOut
  ) external pure returns (bytes memory) {
    return abi.encode(Primitive(
      abi.encodeWithSelector(
        Primitives01.marketSwapExactInput.selector,
        priceOracle,
        priceOracleParams,
        owner,
        tokenIn,
        tokenOut,
        tokenInAmount,
        feePercent,
        feeMinTokenOut,
        new bytes(0)
      ),
      true
    ));
  }

}
