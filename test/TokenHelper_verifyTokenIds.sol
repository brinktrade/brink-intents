// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TokenHelper_verifyTokenIds is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when given an ERC20 token with no merkle root, should return true
  function testVerifyTokenIds_noMerkleRoot_erc20 () public {
    assertEq(tokenHelper.verifyTokenIds_internal(USDC_Token, EMPTY_IDS_MERKLE_PROOF), true);
  }

  // when given an ERC721 token with no merkle root, should return true
  function testVerifyTokenIds_noMerkleRoot_erc721 () public {
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_476, EMPTY_IDS_MERKLE_PROOF), true);
  }

  // when given a token with no merkle root and merkle proof ids, should return false
  function testVerifyTokenIds_noMerkleRoot_withMerkleIds () public {
    uint[] memory ids_476 = new uint[](1);
    ids_476[0] = 476;
    IdsMerkleProof memory idsMerkleProof = IdsMerkleProof(
      ids_476, new bytes32[](0), new bool[](0)
    );
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_476, idsMerkleProof), false);
  }

  // when given a token with a merkle root and a valid proof, should return true
  function testVerifyTokenIds_withMerkleRoot_validProof () public {  
    assertEq(
      tokenHelper.verifyIdsMerkleProof_internal(
        merkleProofForDoodle9107(),
        DOODLE_WHALE_MERKLE_ROOT
      ),
      true
    );
  }

  // when given a token with a merkle root and an invalid proof, should return false
  function testVerifyTokenIds_withMerkleRoot_invalidProof () public {
    revert("NOT IMPLEMENTED");
  }

}
