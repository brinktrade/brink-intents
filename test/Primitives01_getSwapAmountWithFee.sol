// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_getMarketOutput is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  /*
   * positive fee is used for fee in input token, which is added to the user's input amount
   * negative fee is used for fee in output token, which is subtracted from the user's output amount
   */

  // when given a positive fee and 0 min, expect the returned amount to be increased by the fee %
  function testGetSwapAmountWithFee_positiveFee_zeroMin () public {
    uint amount = primitiveInternals.getSwapAmountWithFee(
      twapAdapter,
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)),
      180 * 10**6,
      10000, // 1%
      0
    );
    // output = 116160954314453473 (~0.1162 ETH), + 1% fee = 117322563857598007 (~0.1173 ETH)
    assertEq(amount, 117322563857598007);
  }

  // when min fee exceeds the % fee, expect the returned amount to be increased by the min fee
  function testGetSwapAmountWithFee_positiveFee_minExceeded () public {
    uint amount = primitiveInternals.getSwapAmountWithFee(
      twapAdapter,
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)),
      180 * 10**6,
      10000, // 1%
      2500000000000000 // 0.0025 ETH min
    );
    // output = 116160954314453473 (~0.1162 ETH), + min = 118660954314453473 (~0.1187 ETH)
    assertEq(amount, 118660954314453473);
  }

  // when given a negative fee and 0 min, expect the returned amount to be decreased by the fee %
  function testGetSwapAmountWithFee_negativeFee_zeroMin () public {
    uint amount = primitiveInternals.getSwapAmountWithFee(
      twapAdapter,
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)),
      180 * 10**6,
      -10000, // -1%
      0
    );
    // output = 116160954314453473 (~0.1162 ETH), - 1% fee = 114999344771308939 (~0.1150 ETH)
    assertEq(amount, 114999344771308939);
  }

  // when min fee exceeds the % fee (both negative), expect the returned amount to be decreased by the min fee
  function testGetSwapAmountWithFee_negativeFee_minExceeded () public {
    uint amount = primitiveInternals.getSwapAmountWithFee(
      twapAdapter,
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)),
      180 * 10**6,
      -10000, // -1%
      -2500000000000000
    );
    // output = 116160954314453473 (~0.1162 ETH), - 1% fee = 113660954314453473 (~0.1137 ETH)
    assertEq(amount, 113660954314453473);
  }

  function testGetSwapAmountWithFee_zeroFee () public {
    uint amount = primitiveInternals.getSwapAmountWithFee(
      twapAdapter,
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)),
      180 * 10**6,
      0,
      0
    );
    // output = 116160954314453473 (~0.1162 ETH)
    assertEq(amount, 116160954314453473);
  }

}
