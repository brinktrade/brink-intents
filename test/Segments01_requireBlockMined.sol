// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_requireBlockMined is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testBlockIsNotMined () public {
    // when block is ahead of current block, revert with `BlockNotMined()`
    vm.expectRevert(BlockNotMined.selector);
    segments.requireBlockMined(BLOCK_JAN_25_2023 + 1);
  }

  function testBlockIsMining () public view {
    // when block is equal to current block, don't revert
    segments.requireBlockMined(BLOCK_JAN_25_2023);
  }

  function testBlockIsMined () public view {
    // when block is behind current block, don't revert
    segments.requireBlockMined(BLOCK_JAN_25_2023 - 1);
  }

}
