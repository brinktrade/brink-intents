// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TokenHelper_verifyIdsMerkleProof is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when proof is a valid single proof, should return true
  function testVerifyIdsProof_validSingleProof () public {
    IdsProof memory idsProof = merkleProofForDoodle9107();
    assertEq(
      tokenHelper.verifyIdsMerkleProof_internal(
        idsProof.ids,
        idsProof.merkleProof_hashes,
        idsProof.merkleProof_flags,
        DOODLES_WHALE_MERKLE_ROOT
      ),
      true
    );
  }

  // when proof is a valid single proof, should return true
  function testVerifyIdsProof_validMultiProof () public {  
    IdsProof memory idsProof = merkleMultiProofForDoodles_9592_7754_9107();
    assertEq(
      tokenHelper.verifyIdsMerkleProof_internal(
        idsProof.ids,
        idsProof.merkleProof_hashes,
        idsProof.merkleProof_flags,
        DOODLES_WHALE_MERKLE_ROOT
      ),
      true
    );
  }

  // when no ids are provided, should return false
  function testVerifyIdsProof_noIds () public {
    IdsProof memory idsProof = merkleProofForDoodle9107();
    idsProof.ids[0] = 0;

    assertEq(
      tokenHelper.verifyIdsMerkleProof_internal(
        idsProof.ids,
        idsProof.merkleProof_hashes,
        idsProof.merkleProof_flags,
        DOODLES_WHALE_MERKLE_ROOT
      ),
      false
    );
  }

}
