// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "../src/Libraries/Bit.sol";
import "./Helper.sol";

contract Primitives01_useBit is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testUseBit_bitNotUsed () public {
    bytes32 bitmap0 = vm.load(address(primitives), bytes32(Bit.INITIAL_BMP_PTR + 0));
    assertEq(bitmap0, 0x0000000000000000000000000000000000000000000000000000000000000000);
    primitives.useBit(0, 1);
    bitmap0 = vm.load(address(primitives), bytes32(Bit.INITIAL_BMP_PTR + 0));
    assertEq(bitmap0, 0x0000000000000000000000000000000000000000000000000000000000000001);

  }

  function testUseBit_bitUsed () public {
    primitives.useBit(0, 1);
    vm.expectRevert(BitUsed.selector);
    primitives.useBit(0, 1);
  }

}
