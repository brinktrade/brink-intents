// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_requireUint256LowerBound is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when oracleUint256 is zero, should revert
  function testRequireUint256LowerBound_uint256IsZero () public {
    vm.expectRevert(OracleUint256ReadZero.selector);
    primitives.requireUint256LowerBound(mockPriceOracle, abi.encode(0), 500);
  }

  // when oracleUint256 is below lowerBoundUint256, should not revert
  function testRequireUint256LowerBound_uint256IsBelow () public {
    primitives.requireUint256LowerBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0 + 1);
  }

  // when oracleUint256 is equal to lowerBoundUint256, should not revert
  function testRequireUint256LowerBound_uint256IsEqual () public {
    primitives.requireUint256LowerBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0);
  }

  // when oracleUint256 is above lowerBoundUint256, should revert
  function testRequireUint256LowerBound_uint256IsAbove () public {
    vm.expectRevert(abi.encodeWithSelector(Uint256LowerBoundNotMet.selector, MAGIC_TWAP_PRICE_USDC_ETH_1000_0));
    primitives.requireUint256LowerBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0 - 1);
  }
}
