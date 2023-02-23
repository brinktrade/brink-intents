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
    assertEq(tokenHelper.verifyTokenIds_internal(USDC_Token, EMPTY_IDS_PROOF), true);
  }

  // when given an ERC721 token with no merkle root, should return true
  function testVerifyTokenIds_noMerkleRoot_erc721 () public {
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token, EMPTY_IDS_PROOF), true);
  }

  // when given a token with no merkle root or token.id, should return true
  function testVerifyTokenIds_noMerkleRoot_noTokenId () public {
    uint[] memory ids = new uint[](1);
    ids[0] = 476;
    IdsProof memory idsProof = IdsProof(
      ids, new bytes32[](0), new bool[](0), new uint[](0), new uint[](0), new bytes[](0)
    );
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token, idsProof), true);
  }

  // when given a token with a merkle root and a valid proof, should return true
  function testVerifyTokenIds_withMerkleRoot_validProof () public {  
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_With_Merkle_Root, merkleProofForDoodle9107()), true);
  }

  // when given a token with a merkle root and an invalid proof, should return false
  function testVerifyTokenIds_withMerkleRoot_invalidProof () public {
    IdsProof memory idsProof = merkleProofForDoodle9107();
    idsProof.ids[0] = 476; // not in proof
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_With_Merkle_Root, idsProof), false);
  }

  // when given a token with id and matching merkleProofIds, should return true
  function testVerifyTokenIds_tokenWithId_matchingMerkleProofIds () public {
    uint[] memory ids = new uint[](1);
    ids[0] = 476;
    IdsProof memory idsProof = IdsProof(
      ids, new bytes32[](0), new bool[](0), new uint[](0), new uint[](0), new bytes[](0)
    );
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_476, idsProof), true);
  }

  // when given a token with id and unmatching merkleProofIds, should return false
  function testVerifyTokenIds_tokenWithId_unmatchingMerkleProofIds () public {
    uint[] memory ids = new uint[](1);
    ids[0] = 789;
    IdsProof memory idsProof = IdsProof(
      ids, new bytes32[](0), new bool[](0), new uint[](0), new uint[](0), new bytes[](0)
    );
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_476, idsProof), false);
  }

  // when given a token with id and more than one merkle proof ids, should return false
  function testVerifyTokenIds_tokenWithId_multipleMerkleProofIds () public {
    uint[] memory ids = new uint[](2);
    ids[0] = 476;
    ids[1] = 789;
    IdsProof memory idsProof = IdsProof(
      ids, new bytes32[](0), new bool[](0), new uint[](0), new uint[](0), new bytes[](0)
    );
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_476, idsProof), false);
  }

  // when given a token with id and zero merkle proof ids, should return false
  function testVerifyTokenIds_tokenWithId_zeroMerkleProofIds () public {
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_476, EMPTY_IDS_PROOF), false);
  }

  // when given a token that disallows flagged with valid signatures for status proof, should return true
  function testVerifyTokenIds_disallowFlagged_validSignatures () public {
    uint[] memory ids = new uint[](1);
    ids[0] = 476;
    IdsProof memory idsProof = IdsProof(
      ids, new bytes32[](0), new bool[](0), new uint[](1), new uint[](1), new bytes[](1)
    );
    idsProof.statusProof_lastTransferTimes[0] = 1676959331;
    idsProof.statusProof_timestamps[0] = 1677101603;
    idsProof.statusProof_signatures[0] = hex"64a07dbfacabcc58f056278bd8784b87f012c0805bbc022f99958182bb20d6c226bfbca2839fa33bdb412dce7944c1891d88fd55d747848cf0f72de6857f0d7c1b";
    assertEq(tokenHelper.verifyTokenIds_internal(DOODLES_Token_DisallowFlagged, idsProof), true);
  }

  // when given a token that disallows flagged with invalid signatures for status proof, should revert
  function testVerifyTokenIds_disallowFlagged_invalidSignatures () public {
    uint[] memory ids = new uint[](1);
    ids[0] = 476; // id does not match the status proof
    IdsProof memory idsProof = IdsProof(
      ids, new bytes32[](0), new bool[](0), new uint[](1), new uint[](1), new bytes[](1)
    );

    // will revert with ExceedsValidTime() because timestamp for status proof is 0
    vm.expectRevert(ExceedsValidTime.selector);
    tokenHelper.verifyTokenIds_internal(DOODLES_Token_DisallowFlagged, idsProof);
  }

}
