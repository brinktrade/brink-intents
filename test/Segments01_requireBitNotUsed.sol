// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_requireBitNotUsed is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testRequireBitNotUsed () public {
    segments.requireBitNotUsed(0, 1);
  }

  function testRequireBitNotUsed_bitUsed () public {
    segments.useBit(0, 1);

    vm.expectRevert(BitUsed.selector);
    segments.requireBitNotUsed(0, 1);
  }

}
