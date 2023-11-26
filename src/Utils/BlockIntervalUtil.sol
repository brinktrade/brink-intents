// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

contract BlockIntervalUtil {
  function getBlockIntervalState (uint64 id) public view returns (uint128 start, uint16 counter) {
    bytes32 position = keccak256(abi.encode(id, "blockInterval"));
    bytes32 slot;
    assembly { slot := sload(position) }
    start = uint128(uint256(slot));
    counter = uint16(uint256(slot >> 128)); 
  }
}
