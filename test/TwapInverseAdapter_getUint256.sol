// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TwapAdapter_getUint256 is Test, Helper  {
  function setUp () public {
    setupAll();
  }

  // calling getUint256() with calldata should return the inverse of the twapX96 price
  function testTwapInverseAdapter_getUint256 () public {
    uint256 p = twapInverseAdapter.getUint256(abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000));
    assertEq(p, MAGIC_TWAP_PRICE_ETH_USDC_1000_0);
  }
}
