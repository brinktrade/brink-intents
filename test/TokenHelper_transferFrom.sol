// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

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

    tokenHelper.transferFrom_internal(USDC, TokenStandard.ERC20, USDC_WHALE, RANDOM_1, 1800_000000, EMPTY_IDS_PROOF.ids);

    assertEq(USDC_ERC20.balanceOf(RANDOM_1), 1800_000000);
  }

  // when transfering ERC721 token ids, should execute the transfer
  function testTransferFrom_erc721_anyId () public {
    vm.prank(DOODLE_WHALE);
    DOODLES_ERC721.setApprovalForAll(address(tokenHelper), true);

    uint[] memory ids = new uint[](2);
    ids[0] = 476;
    ids[1] = 9107;
    tokenHelper.transferFrom_internal(DOODLES, TokenStandard.ERC721, DOODLE_WHALE, RANDOM_1, 0, ids);

    assertEq(DOODLES_ERC721.ownerOf(476), RANDOM_1);
    assertEq(DOODLES_ERC721.ownerOf(9107), RANDOM_1);
  }

  // when transfering one id for ERC1155 token, should execute the transfer
  function testTransferFrom_erc1155_oneId () public {
    vm.prank(THE_MEMES_WHALE);
    THE_MEMES_ERC1155.setApprovalForAll(address(tokenHelper), true);

    uint[] memory ids = new uint[](1);
    ids[0] = 14;

    tokenHelper.transferFrom_internal(THE_MEMES, TokenStandard.ERC1155, THE_MEMES_WHALE, RANDOM_1, 5, ids);

    assertEq(THE_MEMES_ERC1155.balanceOf(RANDOM_1, 14), 5);
  }

  // when transfering multiple id's for ERC1155 token, should execute the transfer for 1 of each id
  function testTransferFrom_erc1155_multipleIds () public {
    vm.prank(THE_MEMES_WHALE);
    THE_MEMES_ERC1155.setApprovalForAll(address(tokenHelper), true);

    uint[] memory ids = new uint[](2);
    ids[0] = 8;
    ids[1] = 14;

    tokenHelper.transferFrom_internal(THE_MEMES, TokenStandard.ERC1155, THE_MEMES_WHALE, RANDOM_1, 0, ids);

    assertEq(THE_MEMES_ERC1155.balanceOf(RANDOM_1, 8), 1);
    assertEq(THE_MEMES_ERC1155.balanceOf(RANDOM_1, 14), 1);
  }

  // when called with an unsupported token standard, should revert with UnsupportedTokenStandard()
  function testTransferFrom_unsupportedTokenStandard () public {
    vm.expectRevert(UnsupportedTokenStandard.selector);
    tokenHelper.transferFrom_internal(address(0), TokenStandard.ETH, ETH_WHALE, RANDOM_1, 0, EMPTY_IDS_PROOF.ids);
  }

}
