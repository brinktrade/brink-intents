// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_requireBitUsed is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testRequireBitUsed () public {
    primitives.useBit(0, 1);
    primitives.requireBitUsed(0, 1);
  }

  function testRequireBitUsed_bitUsed () public {
    vm.expectRevert(BitNotUsed.selector);
    primitives.requireBitUsed(0, 1);
  }

}
