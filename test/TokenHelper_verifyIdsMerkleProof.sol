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
    assertEq(
      tokenHelper.verifyIdsMerkleProof_internal(
        merkleProofForDoodle9107(),
        DOODLES_WHALE_MERKLE_ROOT
      ),
      true
    );
  }

  // when proof is a valid single proof, should return true
  function testVerifyIdsMerkleProof_validMultiProof () public {  
    assertEq(
      tokenHelper.verifyIdsMerkleProof_internal(
        merkleMultiProofForDoodles_9592_7754_9107(),
        DOODLES_WHALE_MERKLE_ROOT
      ),
      true
    );
  }

  // when no ids are provided, should return false
  function testVerifyIdsMerkleProof_noIds () public {
    IdsMerkleProof memory idsMerkleProof = merkleProofForDoodle9107();
    idsMerkleProof.ids[0] = 0;

    assertEq(
      tokenHelper.verifyIdsMerkleProof_internal(
        idsMerkleProof,
        DOODLES_WHALE_MERKLE_ROOT
      ),
      false
    );
  }

}
