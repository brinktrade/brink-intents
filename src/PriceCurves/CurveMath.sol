// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "@openzeppelin/contracts/utils/math/SignedMath.sol";

contract CurveMath {
  using SignedMath for int256;

  // calculates a multiplier to use when dividing two integers to maximize precision while avoiding arithmetic overflow
  function calcMultiplier (int numerator, int denominator) public pure returns (uint multiplier) {
    multiplier = 1;
    // calc the magnitudes of the numerator and denominator
    uint8 nMag = uint8(magnitude(numerator.abs()));
    uint8 dMag = uint8(magnitude(denominator.abs()));

    // calc the difference in numerator and denominator magnitudes
    int8 magDiff = int8(int8(nMag) - int8(dMag));

    // if the the numerator is not at least 18 intents of magnitude larger than the denominator
    if (magDiff < 18) {
      // set the multiplier magnitude so that the numerator mag + multiplier mag is 18 greater than the denominator mag.
      // if numerator mag + multiplier mag is greater than 75, set the multiplier mag to 75 - numerator mag, to prevent overflow.
      uint8 mMag = minUint8(uint8(18 - magDiff), 75 - nMag);
      multiplier = 10**mMag;
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

  function minUint8(uint8 a, uint8 b) public pure returns (uint8) {
    return a < b ? a : b;
  }

}
