// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/TokenHelper/TokenHelper.sol";

contract MockTokenHelperInternals is TokenHelper {
  function transferFrom_internal (address tokenAddress, TokenStandard tokenStandard, address from, address to, uint amount, uint[] memory ids) external {
    transferFrom(tokenAddress, tokenStandard, from, to, amount, ids);
  }

  // returns total balance and number of NFT ids owned
  function tokenOwnership_internal (
    address owner,
    TokenStandard tokenStandard,
    address tokenAddress,
    uint[] memory ids
  ) external view returns (uint, uint, uint[] memory) {
    return tokenOwnership(owner, tokenStandard, tokenAddress, ids);
  }

  function verifyTokenIds_internal (Token memory token, IdsProof memory idsProof) external view returns (bool valid) {
    return verifyTokenIds(token, idsProof);
  }

  function verifyTokenIdsNotFlagged_internal (
    address tokenAddress,
    uint[] memory ids,
    uint[] memory lastTransferTimes,
    uint[] memory timestamps,
    bytes[] memory signatures
  ) external view {
    verifyTokenIdsNotFlagged(tokenAddress, ids, lastTransferTimes, timestamps, signatures);
  }

  function verifyIdsMerkleProof_internal (IdsProof memory idsProof, bytes32 root) external pure returns (bool) {
    return verifyIdsMerkleProof(idsProof, root);
  }

  function verifyId_internal (bytes32[] memory proof, bytes32 root, uint id) external pure returns (bool) {
    return verifyId(proof, root, id);
  }

  function verifyIds_internal (bytes32[] memory proof, bool[] memory proofFlags, bytes32 root, uint[] memory ids) external pure returns (bool) {
    return verifyIds(proof, proofFlags, root, ids);
  }
}
