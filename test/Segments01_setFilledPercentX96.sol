// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_setFilledPercentX96 is Test, Helper  {
  using Math for uint;
  using SignedMath for int;

  uint64 id = 123;

  function setUp () public {
    setupAll();
  }

  function testSetFilledPercentX96_start0_actual0_positive () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(0), true), 0);
    assertEq(segmentInternals.getFillStateX96(id), 0);
  }

  function testSetFilledPercentX96_start0_actual50_positive () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(0), true), toPercentX96(50));
    assertEq(segmentInternals.getFillStateX96(id), int(toPercentX96(50)));
  }

  function testSetFilledPercentX96_start50_actual100_positive () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), toPercentX96(100));
    assertEq(segmentInternals.getFillStateX96(id), int(toPercentX96(50)));
  }

  function testSetFilledPercentX96_start50_actual0_positive () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), 0);
    assertEq(segmentInternals.getFillStateX96(id), -int(toPercentX96(50)));
  }

  function testSetFilledPercentX96_start50_actual75_positive () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), toPercentX96(75));
    assertEq(segmentInternals.getFillStateX96(id), int(toPercentX96(25)));
  }

  function testSetFilledPercentX96_start50_actual25_positive () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), toPercentX96(25));
    assertEq(segmentInternals.getFillStateX96(id), -int(toPercentX96(25)));
  }

  function testSetFilledPercentX96_start50_actual50_negative () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), toPercentX96(50));
    assertEq(segmentInternals.getFillStateX96(id), 0);
  }

  function testSetFilledPercentX96_start50_actual0_negative () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), 0);
    assertEq(segmentInternals.getFillStateX96(id), int(toPercentX96(50)));
  }

  function testSetFilledPercentX96_start50_actual100_negative () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), toPercentX96(100));
    assertEq(segmentInternals.getFillStateX96(id), -int(toPercentX96(50)));
  }

  function testSetFilledPercentX96_start50_actual25_negative () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), toPercentX96(25));
    assertEq(segmentInternals.getFillStateX96(id), int(toPercentX96(25)));
  }

  function testSetFilledPercentX96_start50_actual75_negative () public {
    segmentInternals.setFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), toPercentX96(75));
    assertEq(segmentInternals.getFillStateX96(id), -int(toPercentX96(25)));
  }

  function toPercentX96 (uint v) internal pure returns (uint) {
    return v.mulDiv(Q96, 100);
  }
}
