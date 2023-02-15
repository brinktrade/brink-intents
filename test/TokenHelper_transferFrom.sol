// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TokenHelper_transferFrom is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
  }

  // when transfering an ERC20, should execute the transfer
  function testTransferFrom_erc20 () public {
    vm.prank(USDC_WHALE);
    USDC_ERC20.approve(address(tokenHelper), 1800_000000);

    tokenHelper.transferFrom_internal(USDC_Token, USDC_WHALE, RANDOM_1, 1800_000000, 0, EMPTY_IDS_MERKLE_PROOF);

    assertEq(USDC_ERC20.balanceOf(RANDOM_1), 1800_000000);
  }

  // when transfering ERC721 token with no restrictions on ID, should execute the transfer
  function testTransferFrom_erc721_anyId () public {
    vm.prank(DOODLE_WHALE);
    DOODLES_ERC721.setApprovalForAll(address(tokenHelper), true);

    tokenHelper.transferFrom_internal(DOODLES_Token, DOODLE_WHALE, RANDOM_1, 0, 476, EMPTY_IDS_MERKLE_PROOF);

    assertEq(DOODLES_ERC721.ownerOf(476), RANDOM_1);
  }

  // when transfering ERC721 token that allows a specific ID, should execute the transfer
  function testTransferFrom_erc721_specificId_valid () public {
    vm.prank(DOODLE_WHALE);
    DOODLES_ERC721.setApprovalForAll(address(tokenHelper), true);

    tokenHelper.transferFrom_internal(DOODLES_Token_476, DOODLE_WHALE, RANDOM_1, 0, 476, EMPTY_IDS_MERKLE_PROOF);

    assertEq(DOODLES_ERC721.ownerOf(476), RANDOM_1);
  }

  // when transfering the wrong ID for ERC721 token that allows a specific ID, should revert with IdNotAllowed()
  function testTransferFrom_erc721_specificId_invalid () public {
    vm.prank(DOODLE_WHALE);
    DOODLES_ERC721.setApprovalForAll(address(tokenHelper), true);

    vm.expectRevert(IdNotAllowed.selector);
    tokenHelper.transferFrom_internal(DOODLES_Token_476, DOODLE_WHALE, RANDOM_1, 0, 368, EMPTY_IDS_MERKLE_PROOF);

    assertEq(DOODLES_ERC721.ownerOf(476), DOODLE_WHALE);
  }

  // when transfering ERC721 token with a merkle root of ids, should transfer all ids
  function testTransferFrom_erc721_idsMerkle_validProof () public {
    vm.prank(DOODLE_WHALE);
    DOODLES_ERC721.setApprovalForAll(address(tokenHelper), true);

    tokenHelper.transferFrom_internal(DOODLES_Token_With_Merkle_Root, DOODLE_WHALE, RANDOM_1, 0, 0, merkleMultiProofForDoodles_9592_7754_9107());

    assertEq(DOODLES_ERC721.ownerOf(9592), RANDOM_1);
    assertEq(DOODLES_ERC721.ownerOf(7754), RANDOM_1);
    assertEq(DOODLES_ERC721.ownerOf(9107), RANDOM_1);
  }

  // when transfering ERC721 token with a merkle root of ids with an invalid proof, should revert with InvalidIds()
  function testTransferFrom_erc721_idsMerkle_invalidProof () public {
    IdsMerkleProof memory idsMerkleProof = merkleMultiProofForDoodles_9592_7754_9107();
    idsMerkleProof.ids[0] = 9878; // not in the proof

    vm.prank(DOODLE_WHALE);
    DOODLES_ERC721.setApprovalForAll(address(tokenHelper), true);

    vm.expectRevert(InvalidIds.selector);
    tokenHelper.transferFrom_internal(DOODLES_Token_With_Merkle_Root, DOODLE_WHALE, RANDOM_1, 0, 0, idsMerkleProof);
  }

  // when transfering ERC1155 token with no restrictions on ID, should execute the transfer
  function testTransferFrom_erc1155_anyId () public {
    vm.prank(THE_MEMES_WHALE);
    THE_MEMES_ERC1155.setApprovalForAll(address(tokenHelper), true);

    tokenHelper.transferFrom_internal(THE_MEMES_Token, THE_MEMES_WHALE, RANDOM_1, 5, 14, EMPTY_IDS_MERKLE_PROOF);

    assertEq(THE_MEMES_ERC1155.balanceOf(RANDOM_1, 14), 5);
  }

  // when transfering ERC1155 token that allows a specific ID, should execute the transfer
  function testTransferFrom_erc1155_specificId_valid () public {
    vm.prank(THE_MEMES_WHALE);
    THE_MEMES_ERC1155.setApprovalForAll(address(tokenHelper), true);

    tokenHelper.transferFrom_internal(THE_MEMES_FIRSTGM_Token, THE_MEMES_WHALE, RANDOM_1, 23, 8, EMPTY_IDS_MERKLE_PROOF);

    assertEq(THE_MEMES_ERC1155.balanceOf(RANDOM_1, 8), 23);
  }

  // when transfering the wrong ID for ERC1155 token that allows a specific ID, should revert with IdNotAllowed()
  function testTransferFrom_erc1155_specificId_invalid () public {
    vm.prank(THE_MEMES_WHALE);
    THE_MEMES_ERC1155.setApprovalForAll(address(tokenHelper), true);

    vm.expectRevert(IdNotAllowed.selector);
    tokenHelper.transferFrom_internal(THE_MEMES_FIRSTGM_Token, THE_MEMES_WHALE, RANDOM_1, 23, 14, EMPTY_IDS_MERKLE_PROOF);
  }

  // when transfering ERC1155 token with a merkle root of ids, should transfer all ids
  function testTransferFrom_erc1155_idsMerkle_validProof () public {
    vm.prank(THE_MEMES_WHALE);
    THE_MEMES_ERC1155.setApprovalForAll(address(tokenHelper), true);

    tokenHelper.transferFrom_internal(THE_MEMES_Token_With_Merkle_root, THE_MEMES_WHALE, RANDOM_1, 0, 0, merkleMultiProofForTheMemes_14_8());

    assertEq(THE_MEMES_ERC1155.balanceOf(RANDOM_1, 8), 1);
    assertEq(THE_MEMES_ERC1155.balanceOf(RANDOM_1, 14), 1);
  }

  // when transfering ERC1155 token with a merkle root of ids with an invalid proof, should revert with InvalidIds()
  function testTransferFrom_erc1155_idsMerkle_invalidProof () public {
    IdsMerkleProof memory idsMerkleProof = merkleMultiProofForTheMemes_14_8();
    idsMerkleProof.ids[0] = 64; // not in proof

    vm.prank(THE_MEMES_WHALE);
    THE_MEMES_ERC1155.setApprovalForAll(address(tokenHelper), true);

    vm.expectRevert(InvalidIds.selector);
    tokenHelper.transferFrom_internal(THE_MEMES_Token_With_Merkle_root, THE_MEMES_WHALE, RANDOM_1, 0, 0, idsMerkleProof);
  }

  // when called with an unsupported token standard, should revert with UnsupportedTokenStandard()
  function testTransferFrom_unsupportedTokenStandard () public {
    vm.expectRevert(UnsupportedTokenStandard.selector);
    tokenHelper.transferFrom_internal(ETH_TOKEN, ETH_WHALE, RANDOM_1, 0, 0, EMPTY_IDS_MERKLE_PROOF);
  }

}
