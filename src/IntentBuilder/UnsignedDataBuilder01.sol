
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "../Segments/Segments01.sol";
import "../TokenHelper/TokenHelper.sol";

contract UnsignedDataBuilder01 {

  function unsignedSwapData (
    address recipient,
    IdsProof memory tokenInIdsProof,
    IdsProof memory tokenOutIdsProof,
    Call memory fillCall,
    bytes memory signature
  ) external pure returns (bytes memory) {
    return abi.encode(recipient, tokenInIdsProof, tokenOutIdsProof, fillCall, signature);
  }

  function unsignedMarketSwapData (
    address recipient,
    IdsProof memory tokenInIdsProof,
    IdsProof memory tokenOutIdsProof,
    Call memory fillCall
  ) external pure returns (bytes memory) {
    return abi.encode(recipient, tokenInIdsProof, tokenOutIdsProof, fillCall);
  }

  function unsignedLimitSwapData (
    address recipient,
    uint amount,
    IdsProof memory tokenInIdsProof,
    IdsProof memory tokenOutIdsProof,
    Call memory fillCall
  ) external pure returns (bytes memory) {
    return abi.encode(recipient, amount, tokenInIdsProof, tokenOutIdsProof, fillCall);
  }

  function unsignedSwapDataHash (
    address recipient,
    IdsProof memory tokenInIdsProof,
    IdsProof memory tokenOutIdsProof,
    Call memory fillCall
  ) public pure returns (bytes32 dataHash) {
    dataHash = keccak256(abi.encode(recipient, tokenInIdsProof, tokenOutIdsProof, fillCall));
  }

  function unsignedData (
    uint8 intentIndex,
    bytes memory unsignedCall1
  ) public pure returns (bytes memory) {
    bytes[] memory unsignedCalls = new bytes[](1);
    unsignedCalls[0] = unsignedCall1;
    return abi.encode(intentIndex, unsignedCalls);
  }

  function unsignedData (
    uint8 intentIndex,
    bytes memory unsignedCall1,
    bytes memory unsignedCall2
  ) public pure returns (bytes memory) {
    bytes[] memory unsignedCalls = new bytes[](2);
    unsignedCalls[0] = unsignedCall1;
    unsignedCalls[1] = unsignedCall2;
    return abi.encode(intentIndex, unsignedCalls);
  }

  function unsignedData (
    uint8 intentIndex,
    bytes memory unsignedCall1,
    bytes memory unsignedCall2,
    bytes memory unsignedCall3
  ) public pure returns (bytes memory) {
    bytes[] memory unsignedCalls = new bytes[](3);
    unsignedCalls[0] = unsignedCall1;
    unsignedCalls[1] = unsignedCall2;
    unsignedCalls[2] = unsignedCall3;
    return abi.encode(intentIndex, unsignedCalls);
  }

  function unsignedData (
    uint8 intentIndex,
    bytes memory unsignedCall1,
    bytes memory unsignedCall2,
    bytes memory unsignedCall3,
    bytes memory unsignedCall4
  ) public pure returns (bytes memory) {
    bytes[] memory unsignedCalls = new bytes[](4);
    unsignedCalls[0] = unsignedCall1;
    unsignedCalls[1] = unsignedCall2;
    unsignedCalls[2] = unsignedCall3;
    unsignedCalls[3] = unsignedCall4;
    return abi.encode(intentIndex, unsignedCalls);
  }

  function unsignedData (
    uint8 intentIndex,
    bytes memory unsignedCall1,
    bytes memory unsignedCall2,
    bytes memory unsignedCall3,
    bytes memory unsignedCall4,
    bytes memory unsignedCall5
  ) public pure returns (bytes memory) {
    bytes[] memory unsignedCalls = new bytes[](5);
    unsignedCalls[0] = unsignedCall1;
    unsignedCalls[1] = unsignedCall2;
    unsignedCalls[2] = unsignedCall3;
    unsignedCalls[3] = unsignedCall4;
    unsignedCalls[4] = unsignedCall5;
    return abi.encode(intentIndex, unsignedCalls);
  }

  function unsignedData (
    uint8 intentIndex,
    bytes memory unsignedCall1,
    bytes memory unsignedCall2,
    bytes memory unsignedCall3,
    bytes memory unsignedCall4,
    bytes memory unsignedCall5,
    bytes memory unsignedCall6
  ) public pure returns (bytes memory) {
    bytes[] memory unsignedCalls = new bytes[](6);
    unsignedCalls[0] = unsignedCall1;
    unsignedCalls[1] = unsignedCall2;
    unsignedCalls[2] = unsignedCall3;
    unsignedCalls[3] = unsignedCall4;
    unsignedCalls[4] = unsignedCall5;
    unsignedCalls[5] = unsignedCall6;
    return abi.encode(intentIndex, unsignedCalls);
  }

  function unsignedData (
    uint8 intentIndex,
    bytes memory unsignedCall1,
    bytes memory unsignedCall2,
    bytes memory unsignedCall3,
    bytes memory unsignedCall4,
    bytes memory unsignedCall5,
    bytes memory unsignedCall6,
    bytes memory unsignedCall7
  ) public pure returns (bytes memory) {
    bytes[] memory unsignedCalls = new bytes[](7);
    unsignedCalls[0] = unsignedCall1;
    unsignedCalls[1] = unsignedCall2;
    unsignedCalls[2] = unsignedCall3;
    unsignedCalls[3] = unsignedCall4;
    unsignedCalls[4] = unsignedCall5;
    unsignedCalls[5] = unsignedCall6;
    unsignedCalls[6] = unsignedCall7;
    return abi.encode(intentIndex, unsignedCalls);
  }

  function unsignedData (
    uint8 intentIndex,
    bytes memory unsignedCall1,
    bytes memory unsignedCall2,
    bytes memory unsignedCall3,
    bytes memory unsignedCall4,
    bytes memory unsignedCall5,
    bytes memory unsignedCall6,
    bytes memory unsignedCall7,
    bytes memory unsignedCall8
  ) public pure returns (bytes memory) {
    bytes[] memory unsignedCalls = new bytes[](8);
    unsignedCalls[0] = unsignedCall1;
    unsignedCalls[1] = unsignedCall2;
    unsignedCalls[2] = unsignedCall3;
    unsignedCalls[3] = unsignedCall4;
    unsignedCalls[4] = unsignedCall5;
    unsignedCalls[5] = unsignedCall6;
    unsignedCalls[6] = unsignedCall7;
    unsignedCalls[7] = unsignedCall8;
    return abi.encode(intentIndex, unsignedCalls);
  }

  function unsignedData (
    uint8 intentIndex,
    bytes memory unsignedCall1,
    bytes memory unsignedCall2,
    bytes memory unsignedCall3,
    bytes memory unsignedCall4,
    bytes memory unsignedCall5,
    bytes memory unsignedCall6,
    bytes memory unsignedCall7,
    bytes memory unsignedCall8,
    bytes memory unsignedCall9
  ) public pure returns (bytes memory) {
    bytes[] memory unsignedCalls = new bytes[](9);
    unsignedCalls[0] = unsignedCall1;
    unsignedCalls[1] = unsignedCall2;
    unsignedCalls[2] = unsignedCall3;
    unsignedCalls[3] = unsignedCall4;
    unsignedCalls[4] = unsignedCall5;
    unsignedCalls[5] = unsignedCall6;
    unsignedCalls[6] = unsignedCall7;
    unsignedCalls[7] = unsignedCall8;
    unsignedCalls[8] = unsignedCall9;
    return abi.encode(intentIndex, unsignedCalls);
  }

  function unsignedData (
    uint8 intentIndex,
    bytes memory unsignedCall1,
    bytes memory unsignedCall2,
    bytes memory unsignedCall3,
    bytes memory unsignedCall4,
    bytes memory unsignedCall5,
    bytes memory unsignedCall6,
    bytes memory unsignedCall7,
    bytes memory unsignedCall8,
    bytes memory unsignedCall9,
    bytes memory unsignedCall10
  ) public pure returns (bytes memory) {
    bytes[] memory unsignedCalls = new bytes[](10);
    unsignedCalls[0] = unsignedCall1;
    unsignedCalls[1] = unsignedCall2;
    unsignedCalls[2] = unsignedCall3;
    unsignedCalls[3] = unsignedCall4;
    unsignedCalls[4] = unsignedCall5;
    unsignedCalls[5] = unsignedCall6;
    unsignedCalls[6] = unsignedCall7;
    unsignedCalls[7] = unsignedCall8;
    unsignedCalls[8] = unsignedCall9;
    unsignedCalls[9] = unsignedCall10;
    return abi.encode(intentIndex, unsignedCalls);
  }

}
