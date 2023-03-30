// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../StrategyTarget01.sol";

contract OrdersBuilder01 {

  function orders (
    Order memory o1
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](1);
    orders[0] = o1;
  }

  function orders (
    Order memory o1,
    Order memory o2
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](2);
    orders[0] = o1;
    orders[1] = o2;
  }

  function orders (
    Order memory o1,
    Order memory o2,
    Order memory o3
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](3);
    orders[0] = o1;
    orders[1] = o2;
    orders[2] = o3;
  }

  function orders (
    Order memory o1,
    Order memory o2,
    Order memory o3,
    Order memory o4
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](4);
    orders[0] = o1;
    orders[1] = o2;
    orders[2] = o3;
    orders[3] = o4;
  }

  function orders (
    Order memory o1,
    Order memory o2,
    Order memory o3,
    Order memory o4,
    Order memory o5
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](5);
    orders[0] = o1;
    orders[1] = o2;
    orders[2] = o3;
    orders[3] = o4;
    orders[4] = o5;
  }

  function orders (
    Order memory o1,
    Order memory o2,
    Order memory o3,
    Order memory o4,
    Order memory o5,
    Order memory o6
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](6);
    orders[0] = o1;
    orders[1] = o2;
    orders[2] = o3;
    orders[3] = o4;
    orders[4] = o5;
    orders[5] = o6;
  }

  function orders (
    Order memory o1,
    Order memory o2,
    Order memory o3,
    Order memory o4,
    Order memory o5,
    Order memory o6,
    Order memory o7
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](7);
    orders[0] = o1;
    orders[1] = o2;
    orders[2] = o3;
    orders[3] = o4;
    orders[4] = o5;
    orders[5] = o6;
    orders[6] = o7;
  }

  function orders (
    Order memory o1,
    Order memory o2,
    Order memory o3,
    Order memory o4,
    Order memory o5,
    Order memory o6,
    Order memory o7,
    Order memory o8
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](8);
    orders[0] = o1;
    orders[1] = o2;
    orders[2] = o3;
    orders[3] = o4;
    orders[4] = o5;
    orders[5] = o6;
    orders[6] = o7;
    orders[7] = o8;
  }

  function orders (
    Order memory o1,
    Order memory o2,
    Order memory o3,
    Order memory o4,
    Order memory o5,
    Order memory o6,
    Order memory o7,
    Order memory o8,
    Order memory o9
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](9);
    orders[0] = o1;
    orders[1] = o2;
    orders[2] = o3;
    orders[3] = o4;
    orders[4] = o5;
    orders[5] = o6;
    orders[6] = o7;
    orders[7] = o8;
    orders[8] = o9;
  }

  function orders (
    Order memory o1,
    Order memory o2,
    Order memory o3,
    Order memory o4,
    Order memory o5,
    Order memory o6,
    Order memory o7,
    Order memory o8,
    Order memory o9,
    Order memory o10
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](10);
    orders[0] = o1;
    orders[1] = o2;
    orders[2] = o3;
    orders[3] = o4;
    orders[4] = o5;
    orders[5] = o6;
    orders[6] = o7;
    orders[7] = o8;
    orders[8] = o9;
    orders[9] = o10;
  }

  function orders (
    Order memory o1,
    Order memory o2,
    Order memory o3,
    Order memory o4,
    Order memory o5,
    Order memory o6,
    Order memory o7,
    Order memory o8,
    Order memory o9,
    Order memory o10,
    Order memory o11
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](11);
    orders[0] = o1;
    orders[1] = o2;
    orders[2] = o3;
    orders[3] = o4;
    orders[4] = o5;
    orders[5] = o6;
    orders[6] = o7;
    orders[7] = o8;
    orders[8] = o9;
    orders[9] = o10;
    orders[10] = o11;
  }

  function orders (
    Order memory o1,
    Order memory o2,
    Order memory o3,
    Order memory o4,
    Order memory o5,
    Order memory o6,
    Order memory o7,
    Order memory o8,
    Order memory o9,
    Order memory o10,
    Order memory o11,
    Order memory o12
  ) external pure returns (Order[] memory orders) {
    orders = new Order[](12);
    orders[0] = o1;
    orders[1] = o2;
    orders[2] = o3;
    orders[3] = o4;
    orders[4] = o5;
    orders[5] = o6;
    orders[6] = o7;
    orders[7] = o8;
    orders[8] = o9;
    orders[9] = o10;
    orders[10] = o11;
    orders[11] = o12;
  }

}
