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
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token, EMPTY_IDS_MERKLE_PROOF), true);
  }

  // when given a token with no merkle root or token.id, should return true
  function testVerifyTokenIds_noMerkleRoot_noTokenId () public {
    uint[] memory ids = new uint[](1);
    ids[0] = 476;
    IdsMerkleProof memory idsMerkleProof = IdsMerkleProof(
      ids, new bytes32[](0), new bool[](0)
    );
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token, idsMerkleProof), true);
  }

  // when given a token with a merkle root and a valid proof, should return true
  function testVerifyTokenIds_withMerkleRoot_validProof () public {  
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_With_Merkle_Root, merkleProofForDoodle9107()), true);
  }

  // when given a token with a merkle root and an invalid proof, should return false
  function testVerifyTokenIds_withMerkleRoot_invalidProof () public {
    IdsMerkleProof memory idsMerkleProof = merkleProofForDoodle9107();
    idsMerkleProof.ids[0] = 476; // not in proof
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_With_Merkle_Root, idsMerkleProof), false);
  }

  // when given a token with id and matching merkleProofIds, should return true
  function testVerifyTokenIds_tokenWithId_matchingMerkleProofIds () public {
    uint[] memory ids = new uint[](1);
    ids[0] = 476;
    IdsMerkleProof memory idsMerkleProof = IdsMerkleProof(
      ids, new bytes32[](0), new bool[](0)
    );
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_476, idsMerkleProof), true);
  }

  // when given a token with id and unmatching merkleProofIds, should return false
  function testVerifyTokenIds_tokenWithId_unmatchingMerkleProofIds () public {
    uint[] memory ids = new uint[](1);
    ids[0] = 789;
    IdsMerkleProof memory idsMerkleProof = IdsMerkleProof(
      ids, new bytes32[](0), new bool[](0)
    );
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_476, idsMerkleProof), false);
  }

  // when given a token with id and more than one merkle proof ids, should return false
  function testVerifyTokenIds_tokenWithId_multipleMerkleProofIds () public {
    uint[] memory ids = new uint[](2);
    ids[0] = 476;
    ids[1] = 789;
    IdsMerkleProof memory idsMerkleProof = IdsMerkleProof(
      ids, new bytes32[](0), new bool[](0)
    );
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_476, idsMerkleProof), false);
  }

  // when given a token with id and zero merkle proof ids, should return false
  function testVerifyTokenIds_tokenWithId_zeroMerkleProofIds () public {
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_476, EMPTY_IDS_MERKLE_PROOF), false);
  }

}
