// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TwapAdapter_getUint256 is Test, Helper  {
  function setUp () public {
    setupAll();
  }

  // calling getUint256() with calldata should return twapX96 price
  function testTwapAdapter_getUint256 () public {
    uint256 p = twapAdapter.getUint256(abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000));
    assertEq(p, MAGIC_TWAP_PRICE_USDC_ETH_1000_0);
  }
}
