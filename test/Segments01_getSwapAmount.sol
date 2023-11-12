// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_getSwapAmount is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testGetSwapAmount_notInverse () public {
    // 180 USDC -> 0.11616095431445347 ETH
    uint o = segments.getSwapAmount(
      twapAdapter,
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)),
      180 * 10**6
    );
    assertEq(o, 116160954314453473);
  }

  function testGetSwapAmount_inverse () public {
    // 0.15 ETH -> 232.436106 USDC
    uint o = segments.getSwapAmount(
      twapInverseAdapter,
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)),
      15 * 10**16
    );
    assertEq(o, 232436106);
  }

}
