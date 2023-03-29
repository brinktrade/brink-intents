// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../Primitives/Primitives01.sol";
import "../TokenHelper/TokenHelper.sol";
import "../StrategyTarget01.sol";

contract OrderBuilder01 {

  function order (
    Primitive memory p1
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](1);
    primitives[0] = p1;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](2);
    primitives[0] = p1;
    primitives[1] = p2;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2,
    Primitive memory p3
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](3);
    primitives[0] = p1;
    primitives[1] = p2;
    primitives[2] = p3;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2,
    Primitive memory p3,
    Primitive memory p4
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](4);
    primitives[0] = p1;
    primitives[1] = p2;
    primitives[2] = p3;
    primitives[3] = p4;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2,
    Primitive memory p3,
    Primitive memory p4,
    Primitive memory p5
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](5);
    primitives[0] = p1;
    primitives[1] = p2;
    primitives[2] = p3;
    primitives[3] = p4;
    primitives[4] = p5;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2,
    Primitive memory p3,
    Primitive memory p4,
    Primitive memory p5,
    Primitive memory p6
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](6);
    primitives[0] = p1;
    primitives[1] = p2;
    primitives[2] = p3;
    primitives[3] = p4;
    primitives[4] = p5;
    primitives[5] = p6;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2,
    Primitive memory p3,
    Primitive memory p4,
    Primitive memory p5,
    Primitive memory p6,
    Primitive memory p7
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](7);
    primitives[0] = p1;
    primitives[1] = p2;
    primitives[2] = p3;
    primitives[3] = p4;
    primitives[4] = p5;
    primitives[5] = p6;
    primitives[6] = p7;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2,
    Primitive memory p3,
    Primitive memory p4,
    Primitive memory p5,
    Primitive memory p6,
    Primitive memory p7,
    Primitive memory p8
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](8);
    primitives[0] = p1;
    primitives[1] = p2;
    primitives[2] = p3;
    primitives[3] = p4;
    primitives[4] = p5;
    primitives[5] = p6;
    primitives[6] = p7;
    primitives[7] = p8;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2,
    Primitive memory p3,
    Primitive memory p4,
    Primitive memory p5,
    Primitive memory p6,
    Primitive memory p7,
    Primitive memory p8,
    Primitive memory p9
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](9);
    primitives[0] = p1;
    primitives[1] = p2;
    primitives[2] = p3;
    primitives[3] = p4;
    primitives[4] = p5;
    primitives[5] = p6;
    primitives[6] = p7;
    primitives[7] = p8;
    primitives[8] = p9;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2,
    Primitive memory p3,
    Primitive memory p4,
    Primitive memory p5,
    Primitive memory p6,
    Primitive memory p7,
    Primitive memory p8,
    Primitive memory p9,
    Primitive memory p10
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](10);
    primitives[0] = p1;
    primitives[1] = p2;
    primitives[2] = p3;
    primitives[3] = p4;
    primitives[4] = p5;
    primitives[5] = p6;
    primitives[6] = p7;
    primitives[7] = p8;
    primitives[8] = p9;
    primitives[9] = p10;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2,
    Primitive memory p3,
    Primitive memory p4,
    Primitive memory p5,
    Primitive memory p6,
    Primitive memory p7,
    Primitive memory p8,
    Primitive memory p9,
    Primitive memory p10,
    Primitive memory p11
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](11);
    primitives[0] = p1;
    primitives[1] = p2;
    primitives[2] = p3;
    primitives[3] = p4;
    primitives[4] = p5;
    primitives[5] = p6;
    primitives[6] = p7;
    primitives[7] = p8;
    primitives[8] = p9;
    primitives[9] = p10;
    primitives[10] = p11;
    return Order(primitives);
  }

  function order (
    Primitive memory p1,
    Primitive memory p2,
    Primitive memory p3,
    Primitive memory p4,
    Primitive memory p5,
    Primitive memory p6,
    Primitive memory p7,
    Primitive memory p8,
    Primitive memory p9,
    Primitive memory p10,
    Primitive memory p11,
    Primitive memory p12
  ) external pure returns (Order memory) {
    Primitive[] memory primitives = new Primitive[](12);
    primitives[0] = p1;
    primitives[1] = p2;
    primitives[2] = p3;
    primitives[3] = p4;
    primitives[4] = p5;
    primitives[5] = p6;
    primitives[6] = p7;
    primitives[7] = p8;
    primitives[8] = p9;
    primitives[9] = p10;
    primitives[10] = p11;
    primitives[11] = p12;
    return Order(primitives);
  }

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
