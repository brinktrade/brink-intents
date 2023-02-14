// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/TokenHelper/TokenHelper.sol";

contract MockTokenHelperInternals is TokenHelper {
  function transferFrom_internal (Token memory token, address from, address to, uint amount, uint tokenId, IdsMerkleProof memory idsMerkleProof) external {
    transferFrom(token, from, to, amount, tokenId, idsMerkleProof);
  }

  function balanceOf_internal(Token memory token, address owner, IdsMerkleProof memory idsMerkleProof) external view returns (uint) {
    return balanceOf(token, owner, idsMerkleProof);
  }

  // returns total balance and number of NFT ids owned
  function checkTokenOwnership_internal (
    address owner,
    Token memory token,
    IdsMerkleProof memory idsMerkleProof
  ) external view returns (uint, uint) {
    return checkTokenOwnership(owner, token, idsMerkleProof);
  }

  function verifyIdsMerkleProof_internal (IdsMerkleProof memory idsMerkleProof, bytes32 root) external pure returns (bool) {
    return verifyIdsMerkleProof(idsMerkleProof, root);
  }

  function verifyId_internal (bytes32[] memory proof, bytes32 root, uint id) external pure returns (bool) {
    return verifyId(proof, root, id);
  }

  function verifyIds_internal (bytes32[] memory proof, bool[] memory proofFlags, bytes32 root, uint[] memory ids) external pure returns (bool) {
    return verifyIds(proof, proofFlags, root, ids);
  }
}
