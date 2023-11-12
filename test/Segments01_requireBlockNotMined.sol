// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_requireBlockNotMined is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testBlockIsNotMined () public view {
    // when block is ahead of current block, don't revert
    segments.requireBlockNotMined(BLOCK_JAN_25_2023 + 1);
  }

  function testBlockIsMining () public {
    // when block is equal to current block, revert with `BlockMined()`
    vm.expectRevert(BlockMined.selector);
    segments.requireBlockNotMined(BLOCK_JAN_25_2023);
  }

  function testBlockIsMined () public {
    // when block is behind current block, revert with `BlockMined()`
    vm.expectRevert(BlockMined.selector);
    segments.requireBlockNotMined(BLOCK_JAN_25_2023 - 1);
  }

}
