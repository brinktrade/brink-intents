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
    IdsMerkleProof memory idsMerkleProof = merkleMultiProofForDoodles_9592_7754_9107();
    assertEq(
      tokenHelper.verifyIds_internal(
        idsMerkleProof.proof,
        idsMerkleProof.proofFlags,
        DOODLES_WHALE_MERKLE_ROOT,
        idsMerkleProof.ids
      ),
      true
    );
  }

  // when proof is invalid, should return false
  function testVerifyIds_invalidProof () public {
    IdsMerkleProof memory idsMerkleProof = merkleMultiProofForDoodles_9592_7754_9107();
    idsMerkleProof.ids[0] = 9878; // not in the proof
    assertEq(
      tokenHelper.verifyIds_internal(
        idsMerkleProof.proof,
        idsMerkleProof.proofFlags,
        DOODLES_WHALE_MERKLE_ROOT,
        idsMerkleProof.ids
      ),
      false
    );
  }

}
