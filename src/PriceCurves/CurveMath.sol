// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "openzeppelin/utils/math/SignedMath.sol";

contract CurveMath {
  using SignedMath for int256;

  function calcMultiplier (int numerator, int denominator) public pure returns (uint multiplier) {
    multiplier = 1;
    int8 magDiff = int8(
      int(magnitude(numerator.abs())) - int(magnitude(denominator.abs()))
    );
    if (magDiff < 18) {
      multiplier = 10**(uint8(18-magDiff));
    }
  }
  
  function magnitude (uint x) public pure returns (uint) {
    require (x > 0);

    uint a = 0;
    uint b = 77;

    while (b > a) {
      uint m = a + b + 1 >> 1;
      if (x >= pow10 (m)) a = m;
      else b = m - 1;
    }

    return a;
  }

  function pow10 (uint x) public pure returns (uint) {
    uint result = 1;
    uint y = 10;
    while (x > 0) {
      if (x % 2 == 1) {
        result *= y;
        x -= 1;
      } else {
        y *= y;
        x >>= 1;
      }
    }
    return result;
  }

}
