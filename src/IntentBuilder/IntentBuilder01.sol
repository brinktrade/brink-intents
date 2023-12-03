// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "../TokenHelper/TokenHelper.sol";

import "../IntentTarget01.sol";
import "./SegmentBuilder01.sol";
import "./UnsignedDataBuilder01.sol";

error InvalidSignatureType();

enum SignatureType {
  EIP712,
  EIP1271
}

contract IntentBuilder01 {

  function declaration (
    address account,
    uint chainId,
    SignatureType signatureType,
    bytes[][] memory intents,
    address segmentsContract,
    address intentTarget
  ) public view returns (bytes memory data, bytes32 messageHash) {
    data = declarationData(intents, segmentsContract);
    messageHash = getMessageHash(signatureType, data, account, chainId, intentTarget);
  }

  function declaration (
    address account,
    uint chainId,
    SignatureType signatureType,
    bytes[][] memory intents,
    address segmentsContract,
    address intentTarget,
    Call[] memory beforeCalls,
    Call[] memory afterCalls
  ) public view returns (bytes memory data, bytes32 messageHash) {
    data = declarationData(intents, segmentsContract, beforeCalls, afterCalls);
    messageHash = getMessageHash(signatureType, data, account, chainId, intentTarget);
  }

  function declarationData (
    bytes[][] memory intents,
    address segmentsContract
  ) public view returns (bytes memory data) {
    data = declarationData(intents, segmentsContract, new Call[](0), new Call[](0));
  }

  function declarationData (
    bytes[][] memory intents,
    address segmentsContract,
    Call[] memory beforeCalls,
    Call[] memory afterCalls
  ) public view returns (bytes memory data) {
    // build array of Intent structs from bytes input
    Intent[] memory intentStructs = new Intent[](intents.length);
    for (uint8 i = 0; i < intents.length; i++) {
      Segment[] memory segments = new Segment[](intents[i].length);
      for (uint8 j = 0; j < intents[i].length; j++) {
        segments[j] = abi.decode(intents[i][j], (Segment));
      }
      intentStructs[i] = Intent(segments);
    }

    // encode intents data without using Intent struct
    bytes memory intentsData = abi.encode(
      segmentsContract,
      intentStructs,
      beforeCalls,
      afterCalls
    );

    // create a memory pointer to the encoded intent data, which starts after 64 bytes (after the two pointers)
    bytes32 intentPtr = 0x0000000000000000000000000000000000000000000000000000000000000040;

    // create a memory pointer to where unsigned data will be appended,
    // which will be after 64 bytes (for the two pointers) plus the length of the encoded intent
    bytes32 unsignedDataPtr = bytes32(intentsData.length + 0x40); 

    data = bytes.concat(
      IntentTarget01.execute.selector, // bytes4: fn selector
      intentPtr,        // bytes32: memory pointer to intent data
      unsignedDataPtr,    // bytes32: memory pointer to unsigned data
      intentsData        // bytes: encoded intent
    );
  }

  function getMessageHashEIP712 (
    bytes memory data,
    address account,
    uint chainId,
    address intentTarget
  ) public view returns (bytes32 messageHash) {
    bytes32 dataHash = keccak256(
      abi.encode(
        keccak256("MetaDelegateCall(address to,bytes data)"), // META_DELEGATE_CALL_TYPEHASH
        intentTarget,
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
    uint chainId,
    address intentTarget
  ) public view returns (bytes32 messageHash) {
    revert("getMessageHashEIP1271: NOT IMPLEMENTED");
  }

  function getMessageHash (
    SignatureType signatureType,
    bytes memory data,
    address account,
    uint chainId,
    address intentTarget
  ) public view returns (bytes32 messageHash) {
    if (signatureType == SignatureType.EIP712) {
      messageHash = getMessageHashEIP712(data, account, chainId, intentTarget);
    } else if (signatureType == SignatureType.EIP1271) {
      messageHash = getMessageHashEIP1271(data, account, chainId, intentTarget);
    } else {
      revert InvalidSignatureType();
    }
  }

}
