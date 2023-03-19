// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract StrategyTarget01_execute_reverts is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when given an order index that is out of bounds, should revert with BadOrderIndex
  function testExecute_BadOrderIndex () public {
    Primitive[] memory primitives_order0 = new Primitive[](1);
    primitives_order0[0] = Primitive(new bytes(0), false);
    Order[] memory orders = new Order[](1);
    orders[0] = Order(primitives_order0);
    Strategy memory strategy = Strategy(
      address(primitives),
      orders,
      new bytes[](0),
      new bytes[](0)
    );

    vm.expectRevert(BadOrderIndex.selector);
    strategyTarget.execute(
      strategy,
      UnsignedData(
        1, // strategy only has order0, index 1 is out of bounds
        new bytes[](0)
      )
    );
  }

  // when an unsigned call is required but not provided, should revert with UnsignedCallRequired
  function testExecute_UnsignedCallRequired () public {
    Primitive[] memory primitives_order0 = new Primitive[](1);
    primitives_order0[0] = Primitive(new bytes(0), true); // require unsigned call
    Order[] memory orders = new Order[](1);
    orders[0] = Order(primitives_order0);
    Strategy memory strategy = Strategy(
      address(primitives),
      orders,
      new bytes[](0),
      new bytes[](0)
    );

    vm.expectRevert(UnsignedCallRequired.selector);
    strategyTarget.execute(
      strategy,
      UnsignedData(
        0,
        new bytes[](0) // no unsigned call provided
      )
    );
  }

}
