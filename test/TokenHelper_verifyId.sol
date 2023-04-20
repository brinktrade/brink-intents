// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TokenHelper_verfiyId is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when proof is valid, should return true
  function testVerifyId_validProof () public {
    assertEq(
      tokenHelper.verifyId_internal(
        merkleProofForDoodle9107().merkleProof_hashes,
        DOODLES_WHALE_MERKLE_ROOT,
        9107
      ),
      true
    );
  }

  // when proof is for something that exists in the tree but doesn't match the provided id, should return false
  function testVerifyId_proofIdMismatch () public {
    assertEq(
      tokenHelper.verifyId_internal(
        merkleProofForDoodle9107().merkleProof_hashes,
        DOODLES_WHALE_MERKLE_ROOT,
        9108
      ),
      false
    );
  }

  // when proof does not exist in the tree, should return false
  function testVerifyId_invalidProof () public {
    assertEq(
      tokenHelper.verifyId_internal(
        invalidMerkleProof().merkleProof_hashes,
        DOODLES_WHALE_MERKLE_ROOT,
        1234
      ),
      false
    );
  }

}
