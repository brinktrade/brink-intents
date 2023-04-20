// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import '../../Interfaces/IUint256Oracle.sol';
import './ReservoirOracle.sol';

contract ReservoirFloorPriceOracleAdapter is IUint256Oracle, ReservoirOracle {

  bytes32 private constant COLLECTION_PRICE_HASH = keccak256("ContractWideCollectionPrice(uint8 kind,uint256 twapSeconds,address contract)");

  function getUint256(bytes memory params) external view returns (uint256) {
    (
      uint8 priceKind,
      uint twapSeconds,
      address contractAddr,
      uint floorPrice,
      uint timestamp,
      bytes memory signature
    ) = abi.decode(params, (uint8, uint, address, uint, uint, bytes));

    _validateTimestamp(timestamp);

    bytes32 messageId = keccak256(
      abi.encode(
        COLLECTION_PRICE_HASH,
        priceKind,
        twapSeconds,
        contractAddr
      )
    );

    bytes memory payload = abi.encode(0x0, floorPrice);

    _validateSigner(_recover(messageId, payload, timestamp, signature));

    return floorPrice * Q96;
  }
}
