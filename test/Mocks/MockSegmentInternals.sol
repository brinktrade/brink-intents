// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "../../src/Segments/Segments01.sol";

contract MockSegmentInternals is Segments01 {
  function fillSwap (Token memory tokenIn, Token memory tokenOut, address owner, address recipient, uint tokenInAmount, uint tokenOutAmount, IdsProof memory tokenInIdsProof, IdsProof memory tokenOutIdsProof, Call memory fillCall) external {
    _fillSwap(tokenIn, tokenOut, owner, recipient, tokenInAmount, tokenOutAmount, tokenInIdsProof, tokenOutIdsProof, fillCall);
  }

  function setFilledAmount(FillStateParams memory fillStateParams, uint filledAmount, uint totalAmount) external {
    _setFilledAmount(fillStateParams, filledAmount, totalAmount);
  }

  function setFilledPercentX96(FillStateParams memory fillStateParams, uint filledPercentX96) external {
    _setFilledPercentX96(fillStateParams, filledPercentX96);
  }
}
