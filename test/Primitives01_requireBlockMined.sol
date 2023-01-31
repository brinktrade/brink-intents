// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Primitives/Primitives01.sol";
import "./Helper.sol";

contract Primitives01_requireBlockMined is Primitives01, Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testBlockIsNotMined () public {
    // when block is ahead of current block, revert with `BlockNotMined()`
    vm.expectRevert(BlockNotMined.selector);
    requireBlockMined(defaultBlock + 1);
  }

  function testBlockIsMining () public view {
    // when block is equal to current block, don't revert
    requireBlockMined(defaultBlock);
  }

  function testBlockIsMined () public view {
    // when block is behind current block, don't revert
    requireBlockMined(defaultBlock - 1);
  }

}
