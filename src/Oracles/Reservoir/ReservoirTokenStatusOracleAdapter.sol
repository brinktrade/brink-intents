// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import '../../Interfaces/ITokenStatusOracle.sol';
import './ReservoirOracle.sol';

contract ReservoirTokenStatusOracleAdapter is ITokenStatusOracle, ReservoirOracle {

  bytes32 private constant TOKEN_TYPE_HASH = keccak256("Token(address contract,uint256 tokenId)");

  function getBool(bytes memory params) external view returns (bool) {
    (
      address contractAddr,
      uint tokenId,
      bool isFlagged,
      uint lastTransferTime,
      uint timestamp,
      bytes memory signature
    ) = abi.decode(params, (address, uint, bool, uint, uint, bytes));
    verifyTokenStatus(contractAddr, tokenId, isFlagged, lastTransferTime, timestamp, signature);
    return isFlagged;
  }

  function verifyTokenStatus(
    address contractAddr,
    uint tokenId,
    bool isFlagged,
    uint lastTransferTime,
    uint timestamp,
    bytes memory signature
  ) public view {
    _validateTimestamp(timestamp);

    bytes32 messageId = keccak256(
      abi.encode(
        TOKEN_TYPE_HASH,
        contractAddr,
        tokenId
      )
    );

    bytes memory payload = abi.encode(isFlagged, lastTransferTime);

    _validateSigner(_recover(messageId, payload, timestamp, signature));
  }
}
