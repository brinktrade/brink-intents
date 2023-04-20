// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TokenHelper_transferFrom is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
  }

  // when token is ERC721 and no Ids are provided, should revert with AtLeastOneIdRequired()
  function testTokenOwnership_erc721_noIds () public {
    vm.expectRevert(AtLeastOneIdRequired.selector);
    tokenHelper.tokenOwnership_internal(DOODLE_WHALE, TokenStandard.ERC721, DOODLES, new uint[](1));
  }

  // when token is ERC1155 and no Ids are provided, should revert with AtLeastOneIdRequired()
  function testTokenOwnership_erc1155_noIds () public {
    vm.expectRevert(AtLeastOneIdRequired.selector);
    tokenHelper.tokenOwnership_internal(THE_MEMES_MINNOW, TokenStandard.ERC1155, THE_MEMES, new uint[](1));
  }

  // when token is ERC721, should return balances
  function testTokenOwnership_erc721 () public {
    uint[] memory ids = new uint[](3);
    ids[0] = 2284; // owned
    ids[1] = 1170; // owned
    ids[2] = 9130; // not owned
    (uint balance, uint ownedIdCount, uint[] memory idBalances) = tokenHelper.tokenOwnership_internal(DOODLE_WHALE, TokenStandard.ERC721, DOODLES, ids);

    assertEq(balance, 2);
    assertEq(ownedIdCount, 2);
    assertEq(idBalances[0], 1);
    assertEq(idBalances[1], 1);
    assertEq(idBalances[2], 0);
  }

  // when token is ERC1155, should return balances
  function testTokenOwnership_erc1155 () public {
    vm.prank(THE_MEMES_WHALE);
    THE_MEMES_ERC1155.safeTransferFrom(THE_MEMES_WHALE, THE_MEMES_MINNOW, 5, 1, '');

    uint[] memory ids = new uint[](3);
    ids[0] = 8; // owns 2
    ids[1] = 14; // owns 0
    ids[2] = 5; // owns 1
    (uint balance, uint ownedIdCount, uint[] memory idBalances) = tokenHelper.tokenOwnership_internal(THE_MEMES_MINNOW, TokenStandard.ERC1155, THE_MEMES, ids);

    assertEq(balance, 3);
    assertEq(ownedIdCount, 2);
    assertEq(idBalances[0], 2);
    assertEq(idBalances[1], 0);
    assertEq(idBalances[2], 1);
  }

  // when token is ERC20, should return balance
  function testTokenOwnership_erc20 () public {
    (uint balance, uint ownedIdCount, uint[] memory idBalances) = tokenHelper.tokenOwnership_internal(USDC_WHALE, TokenStandard.ERC20, USDC, new uint[](0));
    
    assertEq(balance, 339671198690301);
    assertEq(ownedIdCount, 0);
    assertEq(idBalances.length, 0);
  }

  // when token standard is ETH, should return ETH balance
  function testTokenOwnership_eth () public {
    (uint balance, uint ownedIdCount, uint[] memory idBalances) = tokenHelper.tokenOwnership_internal(ETH_WHALE, TokenStandard.ETH, address(0), new uint[](0));
    
    assertEq(balance, 16590823125421596051145556);
    assertEq(ownedIdCount, 0);
    assertEq(idBalances.length, 0);
  }

}
