// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_testBlockInterval is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when initial state is 0, should allow execution
  function testBlockInterval_initialStart0 () public {
    uint64 id = 12345;
    uint128 initialStart = 0;
    uint128 intervalMinSize = 100;
    uint16 maxIntervals = 0;

    segments.blockInterval(id, initialStart, intervalMinSize, maxIntervals);

    (uint128 start, uint16 counter) = segments.getBlockIntervalState(id);
    assertEq(uint(start), block.number);
    assertEq(counter, 1);
  }

  // should allow multiple executions when intervalMinSize is met
  function testBlockInterval_multipleExecutions () public {
    uint64 id = 12345;
    uint128 initialStart = 0;
    uint128 intervalMinSize = 100;
    uint16 maxIntervals = 2;

    segments.blockInterval(id, initialStart, intervalMinSize, maxIntervals);
    vm.roll(block.number + 100);
    segments.blockInterval(id, initialStart, intervalMinSize, maxIntervals);

    (uint128 start, uint16 counter) = segments.getBlockIntervalState(id);
    assertEq(uint(start), block.number);
    assertEq(counter, 2);
  }

  // when max intervals is set and and number of executions exceeds max intervals, should revert with MaxBlockIntervals()
  function testBlockInterval_maxBlockIntervals () public {
    uint64 id = 12345;
    uint128 initialStart = 0;
    uint128 intervalMinSize = 100;
    uint16 maxIntervals = 2;

    segments.blockInterval(id, initialStart, intervalMinSize, maxIntervals);
    vm.roll(block.number + 100);
    segments.blockInterval(id, initialStart, intervalMinSize, maxIntervals);
    vm.roll(block.number + 250);

    // run a 3rd time when maxIntervals is 2
    vm.expectRevert(MaxBlockIntervals.selector);
    segments.blockInterval(id, initialStart, intervalMinSize, maxIntervals);

    (uint128 start, uint16 counter) = segments.getBlockIntervalState(id);
    assertEq(uint(start), block.number - 250);
    assertEq(counter, 2);
  }

  // when initial start is set and intervalMinSize is not met, should revert with BlockIntervalTooShort()
  function testBlockInterval_blockIntervalTooShortAfterInitialStart () public {
    uint64 id = 12345;
    uint128 initialStart = uint128(block.number) - 99;
    uint128 intervalMinSize = 100;
    uint16 maxIntervals = 0;

    // revert when interval too short
    vm.expectRevert(BlockIntervalTooShort.selector);
    segments.blockInterval(id, initialStart, intervalMinSize, maxIntervals);
    (uint128 start, uint16 counter) = segments.getBlockIntervalState(id);
    assertEq(uint(start), 0);
    assertEq(counter, 0);

    // succeed when interval is long enough
    vm.roll(block.number + 1);
    segments.blockInterval(id, initialStart, intervalMinSize, maxIntervals);
    (start, counter) = segments.getBlockIntervalState(id);
    assertEq(uint(start), block.number);
    assertEq(counter, 1);
  }

  // when intervalMinSize is not met after last execution, should revert with BlockIntervalTooShort()
  function testBlockInterval_blockIntervalTooShortAfterExecution () public {
    uint64 id = 12345;
    uint128 initialStart = 0;
    uint128 intervalMinSize = 100;
    uint16 maxIntervals = 0;

    // initial run
    segments.blockInterval(id, initialStart, intervalMinSize, maxIntervals);
    (uint128 start, uint16 counter) = segments.getBlockIntervalState(id);
    uint blockNum = block.number;
    assertEq(uint(start), blockNum);
    assertEq(counter, 1);

    // revert when interval too short
    vm.roll(block.number + 99);
    vm.expectRevert(BlockIntervalTooShort.selector);
    segments.blockInterval(id, initialStart, intervalMinSize, maxIntervals);
    (start, counter) = segments.getBlockIntervalState(id);
    assertEq(uint(start), blockNum);
    assertEq(counter, 1);
  }
}
