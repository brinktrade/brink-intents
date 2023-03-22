// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_bindLimitSwapFills is Test, Helper  {

  bytes32 id0;
  bytes32 id1;
  bytes32 id2;

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
    id0 = keccak256("0000");
    id1 = keccak256("1111");
    id2 = keccak256("2222");
  }

  // when swap0 is 2/3 filled, sets bound swaps to 2/3 filled
  function testBindLimitSwapFills_from_2_3 () public {
    primitiveInternals.setLimitSwapFilledAmount(id0, 2, 3);

    bytes32[] memory ids = new bytes32[](3);
    ids[0] = id0;
    ids[1] = id1;
    ids[2] = id2;
    primitiveInternals.bindLimitSwapFills(ids);
    assertEq(primitiveInternals.getLimitSwapFilledAmount(id1, 3), 2);
    assertEq(primitiveInternals.getLimitSwapFilledAmount(id1, 3), 2);
    assertEq(primitiveInternals.getLimitSwapFilledAmount(id2, 3), 2);
  }

  // when swap0 is 0% filled, sets bound swaps to 0% filled
  function testBindLimitSwapFills_from_0 () public {
    primitiveInternals.setLimitSwapFilledAmount(id1, 2, 3);
    primitiveInternals.setLimitSwapFilledAmount(id2, 2, 3);
    bytes32[] memory ids = new bytes32[](3);
    ids[0] = id0;
    ids[1] = id1;
    ids[2] = id2;
    primitiveInternals.bindLimitSwapFills(ids);
    assertEq(primitiveInternals.getLimitSwapFilledAmount(id1, 100), 0);
    assertEq(primitiveInternals.getLimitSwapFilledAmount(id1, 100), 0);
    assertEq(primitiveInternals.getLimitSwapFilledAmount(id2, 100), 0);
  }

  // when swap0 and swap1 are the same, should revert with SwapIdsAreEqual()
  function testBindLimitSwapFills_sameIds () public {
    bytes32[] memory ids = new bytes32[](2);
    ids[0] = id0;
    ids[1] = id0;
    vm.expectRevert(SwapIdsAreEqual.selector);
    primitiveInternals.bindLimitSwapFills(ids);
  }

  // when given only 1 swap id, should revert with InvalidSwapIdsLength()
  function testBindLimitSwapFills_InvalidSwapIdsLength () public {
    bytes32[] memory ids = new bytes32[](1);
    ids[0] = id0;
    vm.expectRevert(InvalidSwapIdsLength.selector);
    primitiveInternals.bindLimitSwapFills(ids);
  }

}
