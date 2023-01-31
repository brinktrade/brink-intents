// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Primatives/Primatives01.sol";
import "./Helper.sol";

contract Primatives01_requirePriceLowerBound is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when oraclePrice is zero, should revert
  function testRequirePriceLowerBound_priceIsZero () public {
    vm.expectRevert(OraclePriceReadZero.selector);
    primatives.requirePriceLowerBound(mockPriceOracle, abi.encode(0), 500);
  }

  // when oraclePrice is below lowerBoundPrice, should not revert
  function testRequirePriceLowerBound_priceIsBelow () public {
    primatives.requirePriceLowerBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0 + 1);
  }

  // when oraclePrice is equal to lowerBoundPrice, should not revert
  function testRequirePriceLowerBound_priceIsEqual () public {
    primatives.requirePriceLowerBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0);
  }

  // when oraclePrice is above lowerBoundPrice, should revert
  function testRequirePriceLowerBound_priceIsAbove () public {
    vm.expectRevert(abi.encodeWithSelector(PriceLowerBoundNotMet.selector, MAGIC_TWAP_PRICE_USDC_ETH_1000_0));
    primatives.requirePriceLowerBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0 - 1);
  }
}
