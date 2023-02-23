// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/Primitives/Primitives01.sol";

contract MockPrimitiveInternals is Primitives01 {
  function fillSwap (Token memory tokenIn, Token memory tokenOut, address owner, address recipient, uint tokenInAmount, uint tokenOutAmount, IdsProof memory tokenInIdsProof, IdsProof memory tokenOutIdsProof, Call memory fillCall) external {
    _fillSwap(tokenIn, tokenOut, owner, recipient, tokenInAmount, tokenOutAmount, tokenInIdsProof, tokenOutIdsProof, fillCall);
  }
}
