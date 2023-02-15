// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TokenHelper_verfiyId is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when proof is valid, should return true
  function testVerifyIds_validProof () public {
    (bytes32[] memory proof, bool[] memory proofFlags) = merkleMultiProofForDoodles_9592_7754_9107();
    uint[] memory ids = new uint[](3);
    ids[0] = 9592;
    ids[1] = 7754;
    ids[2] = 9107;
    assertEq(
      tokenHelper.verifyIds_internal(
        proof,
        proofFlags,
        DOODLE_WHALE_MERKLE_ROOT,
        ids
      ),
      true
    );
  }

  // when proof is invalid, should return false
  function testVerifyIds_invalidProof () public {
    (bytes32[] memory proof, bool[] memory proofFlags) = merkleMultiProofForDoodles_9592_7754_9107();
    uint[] memory ids = new uint[](3);
    ids[0] = 9878; // not in the proof
    ids[1] = 7754;
    ids[2] = 9107;
    assertEq(
      tokenHelper.verifyIds_internal(
        proof,
        proofFlags,
        DOODLE_WHALE_MERKLE_ROOT,
        ids
      ),
      false
    );
  }

}
