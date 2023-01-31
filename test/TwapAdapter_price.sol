// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TwapAdapter_getTwapX96 is Test, Helper  {
  function setUp () public {
    setupAll();
  }

  // calling price() with calldata should return twapX96 price
  function testGetTwapX96_price () public {
    uint256 p = twapAdapter.price(abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000));
    assertEq(p, MAGIC_TWAP_PRICE_USDC_ETH_1000_0);
  }
}
