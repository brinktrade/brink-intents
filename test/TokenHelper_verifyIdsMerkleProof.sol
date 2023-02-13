// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TokenHelper_verifyIdsMerkleProof is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when proof is a valid single proof, should return true
  function testVerifyIdsMerkleProof_validSingleProof () public {
    uint[] memory ids = new uint[](1);
    ids[0] = 9107;

    IdsMerkleProof memory idsMerkleProof = IdsMerkleProof(
      ids,
      merkleProofForDoodle9107(),
      new bool[](0)
    );
  
    assertEq(
      tokenHelper.verifyIdsMerkleProof_internal(
        idsMerkleProof,
        DOODLE_WHALE_MERKLE_ROOT
      ),
      true
    );
  }

  // when proof is a valid single proof, should return true
  function testVerifyIdsMerkleProof_validMultiProof () public {
    (bytes32[] memory proof, bool[] memory proofFlags) = merkleMultiProofForDoodles_9592_7754_9107();
    uint[] memory ids = new uint[](3);
    ids[0] = 9592;
    ids[1] = 7754;
    ids[2] = 9107;

    IdsMerkleProof memory idsMerkleProof = IdsMerkleProof(
      ids,
      proof,
      proofFlags
    );
  
    assertEq(
      tokenHelper.verifyIdsMerkleProof_internal(
        idsMerkleProof,
        DOODLE_WHALE_MERKLE_ROOT
      ),
      true
    );
  }

  // when no ids are provided, should return false
  function testVerifyIdsMerkleProof_noIds () public {
    IdsMerkleProof memory idsMerkleProof = IdsMerkleProof(
      new uint[](0),
      merkleProofForDoodle9107(),
      new bool[](0)
    );

    assertEq(
      tokenHelper.verifyIdsMerkleProof_internal(
        idsMerkleProof,
        DOODLE_WHALE_MERKLE_ROOT
      ),
      false
    );
  }

}
