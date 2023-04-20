// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_requireBitNotUsed is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testRequireBitNotUsed () public {
    primitives.requireBitNotUsed(0, 1);
  }

  function testRequireBitNotUsed_bitUsed () public {
    primitives.useBit(0, 1);

    vm.expectRevert(BitUsed.selector);
    primitives.requireBitNotUsed(0, 1);
  }

}
