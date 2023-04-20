// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TokenHelper_verfiyId is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when proof is valid, should return true
  function testVerifyIds_validProof () public {
    IdsProof memory idsProof = merkleMultiProofForDoodles_9592_7754_9107();
    assertEq(
      tokenHelper.verifyIds_internal(
        idsProof.merkleProof_hashes,
        idsProof.merkleProof_flags,
        DOODLES_WHALE_MERKLE_ROOT,
        idsProof.ids
      ),
      true
    );
  }

  // when proof is invalid, should return false
  function testVerifyIds_invalidProof () public {
    IdsProof memory idsProof = merkleMultiProofForDoodles_9592_7754_9107();
    idsProof.ids[0] = 9878; // not in the proof
    assertEq(
      tokenHelper.verifyIds_internal(
        idsProof.merkleProof_hashes,
        idsProof.merkleProof_flags,
        DOODLES_WHALE_MERKLE_ROOT,
        idsProof.ids
      ),
      false
    );
  }

}
