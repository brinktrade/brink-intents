// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_invertLimitSwapFills is Test, Helper  {

  bytes32 id0;
  bytes32 id1;

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
    id0 = keccak256("0000");
    id1 = keccak256("1111");
  }

  // // when swap0 is 2/3 filled, sets swap1 to 1/3 filled
  // function testInvertLimitSwapFills_from_2_3 () public {
  //   primitiveInternals.setLimitSwapFilledAmount(id0, 2, 3);
  //   primitiveInternals.invertLimitSwapFills(id0, id1);
  //   assertEq(primitiveInternals.getLimitSwapFilledAmount(id1, 3), 1);
  // }

  // // when swap0 is 1/100 filled, sets swap1 to 99/100 filled
  // function testInvertLimitSwapFills_from_1_100 () public {
  //   primitiveInternals.setLimitSwapFilledAmount(id0, 1, 100);
  //   primitiveInternals.invertLimitSwapFills(id0, id1);
  //   assertEq(primitiveInternals.getLimitSwapFilledAmount(id1, 100), 99);
  // }

  // // when swap0 is 99/100 filled, sets swap1 to 1/100 filled
  // function testInvertLimitSwapFills_from_99_100 () public {
  //   primitiveInternals.setLimitSwapFilledAmount(id0, 99, 100);
  //   primitiveInternals.invertLimitSwapFills(id0, id1);
  //   assertEq(primitiveInternals.getLimitSwapFilledAmount(id1, 100), 1);
  // }

  // // when swap0 is 0% filled, sets swap1 to 100% filled
  // function testInvertLimitSwapFills_from_0 () public {
  //   primitiveInternals.invertLimitSwapFills(id0, id1);
  //   assertEq(primitiveInternals.getLimitSwapFilledAmount(id1, 1000), 1000);
  // }

  // // when swap0 is 100% filled, sets swap1 to 0% filled
  // function testInvertLimitSwapFills_from_100 () public {
  //   primitiveInternals.setLimitSwapFilledAmount(id0, 1000, 1000);
  //   primitiveInternals.invertLimitSwapFills(id0, id1);
  //   assertEq(primitiveInternals.getLimitSwapFilledAmount(id1, 1000), 0);
  // }

  // // when swap0 and swap1 are the same, should revert with SwapIdsAreEqual()
  // function testInvertLimitSwapFills_sameIds () public {
  //   vm.expectRevert(SwapIdsAreEqual.selector);
  //   primitiveInternals.invertLimitSwapFills(id0, id0);
  // }

}
