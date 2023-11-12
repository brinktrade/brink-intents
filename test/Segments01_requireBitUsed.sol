// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_requireBitUsed is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testRequireBitUsed () public {
    segments.useBit(0, 1);
    segments.requireBitUsed(0, 1);
  }

  function testRequireBitUsed_bitUsed () public {
    vm.expectRevert(BitNotUsed.selector);
    segments.requireBitUsed(0, 1);
  }

}
