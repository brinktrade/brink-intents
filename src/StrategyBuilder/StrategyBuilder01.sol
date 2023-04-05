// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../TokenHelper/TokenHelper.sol";

import "../StrategyTarget01.sol";
import "./PrimitiveBuilder01.sol";
import "./UnsignedDataBuilder01.sol";

error InvalidSignatureType();

enum SignatureType {
  EIP712,
  EIP1271
}

contract StrategyBuilder01 {

  address public immutable strategyTarget;
  address public immutable primitives;

  constructor (address _strategyTarget, address _primitives) {
    strategyTarget = _strategyTarget;
    primitives = _primitives;
  }

  function strategy (
    address account,
    uint chainId,
    SignatureType signatureType,
    bytes[][] memory orders
  ) public view returns (bytes memory data, bytes32 messageHash) {
    data = strategyData(orders);
    messageHash = getMessageHash(signatureType, data, account, chainId);
  }

  function strategy (
    address account,
    uint chainId,
    SignatureType signatureType,
    bytes[][] memory orders,
    Call[] memory beforeCalls,
    Call[] memory afterCalls
  ) public view returns (bytes memory data, bytes32 messageHash) {
    data = strategyData(orders, beforeCalls, afterCalls);
    messageHash = getMessageHash(signatureType, data, account, chainId);
  }

  function strategyData (
    bytes[][] memory orders
  ) public view returns (bytes memory data) {
    data = strategyData(orders, new Call[](0), new Call[](0));
  }

  function strategyData (
    bytes[][] memory orders,
    Call[] memory beforeCalls,
    Call[] memory afterCalls
  ) public view returns (bytes memory data) {
    // build array of Order structs from bytes input
    Order[] memory orderStructs = new Order[](orders.length);
    for (uint8 i = 0; i < orders.length; i++) {
      Primitive[] memory primitives = new Primitive[](orders[i].length);
      for (uint8 j = 0; j < orders[i].length; j++) {
        primitives[j] = abi.decode(orders[i][j], (Primitive));
      }
      orderStructs[i] = Order(primitives);
    }

    // encode strategy data without using Strategy struct
    bytes memory strategyData = abi.encode(
      primitives,
      orderStructs,
      beforeCalls,
      afterCalls
    );

    // create a memory pointer to the encoded strategy data, which starts after 64 bytes (after the two pointers)
    bytes32 strategyPtr = 0x0000000000000000000000000000000000000000000000000000000000000040;

    // create a memory pointer to where unsigned data will be appended,
    // which will be after 64 bytes (for the two pointers) plus the length of the encoded strategy
    bytes32 unsignedDataPtr = bytes32(strategyData.length + 0x40); 

    data = bytes.concat(
      StrategyTarget01.execute.selector, // bytes4: fn selector
      strategyPtr,        // bytes32: memory pointer to strategy data
      unsignedDataPtr,    // bytes32: memory pointer to unsigned data
      strategyData        // bytes: encoded strategy
    );
  }

  function getMessageHashEIP712 (
    bytes memory data,
    address account,
    uint chainId
  ) public view returns (bytes32 messageHash) {
    bytes32 dataHash = keccak256(
      abi.encode(
        keccak256("MetaDelegateCall(address to,bytes data)"), // META_DELEGATE_CALL_TYPEHASH
        strategyTarget,
        keccak256(data)
      )
    );
    messageHash = keccak256(abi.encodePacked(
      "\x19\x01",
      keccak256(abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256("BrinkAccount"),
        keccak256("1"),
        chainId,
        account
      )),
      dataHash
    ));
  }

  function getMessageHashEIP1271 (
    bytes memory data,
    address account,
    uint chainId
  ) public view returns (bytes32 messageHash) {
    revert("getMessageHashEIP1271: NOT IMPLEMENTED");
  }

  function getMessageHash (
    SignatureType signatureType,
    bytes memory data,
    address account,
    uint chainId
  ) public view returns (bytes32 messageHash) {
    if (signatureType == SignatureType.EIP712) {
      messageHash = getMessageHashEIP712(data, account, chainId);
    } else if (signatureType == SignatureType.EIP1271) {
      messageHash = getMessageHashEIP1271(data, account, chainId);
    } else {
      revert InvalidSignatureType();
    }
  }

}
