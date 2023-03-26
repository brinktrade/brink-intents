// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_setFilledPercentX96 is Test, Helper  {
  using Math for uint;
  using SignedMath for int;

  uint64 id = 123;

  function setUp () public {
    setupAll();
  }

  function testSetFilledPercentX96_start0_actual0_positive () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(0), true), 0);
    assertEq(primitiveInternals.getFillStateX96(id), 0);
  }

  function testSetFilledPercentX96_start0_actual50_positive () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(0), true), toPercentX96(50));
    assertEq(primitiveInternals.getFillStateX96(id), int(toPercentX96(50)));
  }

  function testSetFilledPercentX96_start50_actual100_positive () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), toPercentX96(100));
    assertEq(primitiveInternals.getFillStateX96(id), int(toPercentX96(50)));
  }

  function testSetFilledPercentX96_start50_actual0_positive () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), 0);
    assertEq(primitiveInternals.getFillStateX96(id), -int(toPercentX96(50)));
  }

  function testSetFilledPercentX96_start50_actual75_positive () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), toPercentX96(75));
    assertEq(primitiveInternals.getFillStateX96(id), int(toPercentX96(25)));
  }

  function testSetFilledPercentX96_start50_actual25_positive () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), toPercentX96(25));
    assertEq(primitiveInternals.getFillStateX96(id), -int(toPercentX96(25)));
  }

  function testSetFilledPercentX96_start50_actual50_negative () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), toPercentX96(50));
    assertEq(primitiveInternals.getFillStateX96(id), 0);
  }

  function testSetFilledPercentX96_start50_actual0_negative () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), 0);
    assertEq(primitiveInternals.getFillStateX96(id), int(toPercentX96(50)));
  }

  function testSetFilledPercentX96_start50_actual100_negative () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), toPercentX96(100));
    assertEq(primitiveInternals.getFillStateX96(id), -int(toPercentX96(50)));
  }

  function testSetFilledPercentX96_start50_actual25_negative () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), toPercentX96(25));
    assertEq(primitiveInternals.getFillStateX96(id), int(toPercentX96(25)));
  }

  function testSetFilledPercentX96_start50_actual75_negative () public {
    primitiveInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), toPercentX96(75));
    assertEq(primitiveInternals.getFillStateX96(id), -int(toPercentX96(25)));
  }

  function toPercentX96 (uint v) internal pure returns (uint) {
    return v.mulDiv(Q96, 100);
  }
}
