// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import 'forge-std/console.sol';
import '../../Interfaces/IBoolOracle.sol';
import './ReservoirOracle.sol';

contract ReservoirTokenStatusOracleAdapter is IBoolOracle, ReservoirOracle {

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

    return isFlagged;
  }
}
