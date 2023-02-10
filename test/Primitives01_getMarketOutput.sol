// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_getMarketOutput is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testGetMarketOutput () public {
    uint o = primitiveInternals.getMarketOutput(
      twapAdapter,
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)),
      0
    );
    assertEq(o, 123456);
  }

}
