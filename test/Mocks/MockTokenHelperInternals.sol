// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/TokenHelper/TokenHelper.sol";

contract MockTokenHelperInternals is TokenHelper {
  function transferFrom_internal (Token memory token, address from, address to, uint amount, uint id, IdMerkleProof[] memory idMerkleProofs) external {
    transferFrom(token, from, to, amount, id, idMerkleProofs);
  }

  function balanceOf_internal(Token memory token, address owner, IdMerkleProof[] memory idMerkleProofs) external view returns (uint) {
    return balanceOf(token, owner, idMerkleProofs);
  }

  // returns total balance and number of NFT ids owned
  function checkTokenOwnership_internal (
    address owner,
    Token memory token,
    IdMerkleProof[] memory idMerkleProofs
  ) external view returns (uint, uint) {
    return checkTokenOwnership(owner, token, idMerkleProofs);
  }

  function verifyId_internal (bytes32[] memory proof, bytes32 root, uint id) external pure returns (bool) {
    return verifyId(proof, root, id);
  }
}
