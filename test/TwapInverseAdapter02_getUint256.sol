// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TwapInverseAdapter02_getUint256 is Test, Helper  {
  function setUp () public {
    setupAll();
  }

  // calling getUint256() on a pool where token0 value > token1 value should return the inverse of the twapX96 price
  function testTwapInverseAdapter02_token0_more_than_token1_getUint256 () public {
    uint256 p = twapInverseAdapter02.getUint256(abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000));
    assertEq(p, MAGIC_TWAP_PRICE_ETH_USDC_1000_0);
  }

  // calling getUint256() on a pool token0 value < token1 value should return the inverse of the twapX96 price
  function testTwapInverseAdapter02_token0_less_than_token1_getUint256 () public {
    uint256 p = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    assertEq(p, MAGIC_TWAP_PRICE_ETH_DAI_1000_0);
  }
}
