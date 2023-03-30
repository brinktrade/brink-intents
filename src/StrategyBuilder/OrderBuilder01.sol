// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../Primitives/Primitives01.sol";
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

}
