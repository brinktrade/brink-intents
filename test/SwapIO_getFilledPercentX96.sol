// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";

contract SwapIO_getFilledAmount is Test, Helper  {
  using Math for uint;
  using SignedMath for int;

  uint64 id = 123;

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
  }

  function testGetFilledPercentX96_start0_stored0_positive () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(0), true), 0);
    assertEq(v, 0);
  }

  function testGetFilledPercentX96_start0_stored50_positive () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(0), true), int(toPercentX96(50)));
    assertEq(v, toPercentX96(50));
  }

  function testGetFilledPercentX96_start50_stored0_positive () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), 0);
    assertEq(v, toPercentX96(50));
  }

  function testGetFilledPercentX96_start50_stored50_positive () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), int(toPercentX96(50)));
    assertEq(v, toPercentX96(100));
  }

  function testGetFilledPercentX96_start50_storedNeg50_positive () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), -int(toPercentX96(50)));
    assertEq(v, 0);
  }

  function testGetFilledPercentX96_start50_stored25_positive () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), int(toPercentX96(25)));
    assertEq(v, toPercentX96(75));
  }

  function testGetFilledPercentX96_start50_storedNeg25_positive () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), true), -int(toPercentX96(25)));
    assertEq(v, toPercentX96(25));
  }

  function testGetFilledPercentX96_start50_stored0_negative () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), 0);
    assertEq(v, toPercentX96(50));
  }
  
  function testGetFilledPercentX96_start50_stored50_negative () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), int(toPercentX96(50)));
    assertEq(v, 0);
  }
  
  function testGetFilledPercentX96_start50_storedNeg50_negative () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), -int(toPercentX96(50)));
    assertEq(v, toPercentX96(100));
  }
  
  function testGetFilledPercentX96_start50_stored25_negative () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), int(toPercentX96(25)));
    assertEq(v, toPercentX96(25));
  }
  
  function testGetFilledPercentX96_start50_storedNeg25_negative () public {
    uint v = swapIO.getFilledPercentX96(FillStateParams(id, uint128(toPercentX96(50)), false), -int(toPercentX96(25)));
    assertEq(v, toPercentX96(75));
  }

  function toPercentX96 (uint v) internal pure returns (uint) {
    return v.mulDiv(Q96, 100);
  }

}
