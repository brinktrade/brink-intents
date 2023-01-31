// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Primatives/Primatives01.sol";
import "./Helper.sol";

contract Primatives01_requireBlockNotMined is Primatives01, Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testBlockIsNotMined () public view {
    // when block is ahead of current block, don't revert
    requireBlockNotMined(defaultBlock + 1);
  }

  function testBlockIsMining () public {
    // when block is equal to current block, revert with `BlockMined()`
    vm.expectRevert(BlockMined.selector);
    requireBlockNotMined(defaultBlock);
  }

  function testBlockIsMined () public {
    // when block is behind current block, revert with `BlockMined()`
    vm.expectRevert(BlockMined.selector);
    requireBlockNotMined(defaultBlock - 1);
  }

}
