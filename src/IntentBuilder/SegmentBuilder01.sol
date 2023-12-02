// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "../Segments/Segments01.sol";
import "../TokenHelper/TokenHelper.sol";
import "../IntentTarget01.sol";

contract SegmentBuilder01 {

  function requireBitNotUsed (uint bitmapIndex, uint bit) external pure returns (bytes memory) {
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.requireBitNotUsed.selector,
        bitmapIndex,
        bit
      ),
      false
    ));
  }

  function requireBitUsed (uint bitmapIndex, uint bit) external pure returns (bytes memory) {
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.requireBitUsed.selector,
        bitmapIndex,
        bit
      ),
      false
    ));
  }

  function useBit (uint bitmapIndex, uint bit) external pure returns (bytes memory) {
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.useBit.selector,
        bitmapIndex,
        bit
      ),
      false
    ));
  }

  function requireBlockMined (uint blockNumber) external pure returns (bytes memory) {
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.requireBlockMined.selector,
        blockNumber
      ),
      false
    ));
  }

  function requireBlockNotMined (uint blockNumber) external pure returns (bytes memory) {
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.requireBlockNotMined.selector,
        blockNumber
      ),
      false
    ));
  }

  function blockInterval (uint64 id, uint128 initialStart, uint128 intervalMinSize, uint16 maxIntervals) external pure returns (bytes memory) {
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.blockInterval.selector,
        id,
        initialStart,
        intervalMinSize,
        maxIntervals
      ),
      false
    ));
  }

  function requireUint256LowerBound (IUint256Oracle uint256Oracle, bytes memory params, uint lowerBound) external pure returns (bytes memory) {
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.requireUint256LowerBound.selector,
        uint256Oracle,
        params,
        lowerBound
      ),
      false
    ));
  }

  function requireUint256UpperBound (IUint256Oracle uint256Oracle, bytes memory params, uint upperBound) external pure returns (bytes memory) {
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.requireUint256UpperBound.selector,
        uint256Oracle,
        params,
        upperBound
      ),
      false
    ));
  }

  function swap01 (
    address owner,
    Token memory tokenIn,
    Token memory tokenOut,
    ISwapAmount inputAmountContract,
    ISwapAmount outputAmountContract,
    bytes memory inputAmountParams,
    bytes memory outputAmountParams,
    ISolverValidator solverValidator
  ) external pure returns (bytes memory) {
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.swap01.selector,
        owner,
        tokenIn,
        tokenOut,
        inputAmountContract,
        outputAmountContract,
        inputAmountParams,
        outputAmountParams,
        solverValidator,
        new bytes(0)
      ),
      true
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
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.marketSwapExactInput.selector,
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

  function limitSwapExactInput(
    address owner,
    Token memory tokenIn,
    Token memory tokenOut,
    uint tokenInAmount,
    IPriceCurve priceCurve,
    bytes memory priceCurveParams,
    FillStateParams memory fillStateParams
  ) external pure returns (bytes memory) {
    return abi.encode(Segment(
      abi.encodeWithSelector(
        Segments01.limitSwapExactInput.selector,
        owner,
        tokenIn,
        tokenOut,
        tokenInAmount,
        priceCurve,
        priceCurveParams,
        fillStateParams,
        new bytes(0)
      ),
      true
    ));
  }

}
