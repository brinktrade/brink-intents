// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Primatives/Primatives01.sol";
import "./Helper.sol";

contract Primatives01_requirePriceUpperBound is Primatives01, Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when oraclePrice is below upperBoundPrice, should revert
  function testRequirePriceUpperBound_priceIsBelow () public {
    vm.expectRevert(abi.encodeWithSelector(PriceUpperBoundNotMet.selector, MAGIC_TWAP_PRICE_USDC_ETH_1000_0));
    primatives.requirePriceUpperBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0 + 1);
  }

  // when oraclePrice is equal to upperBoundPrice, should not revert
  function testRequirePriceUpperBound_priceIsEqual () public {
    primatives.requirePriceUpperBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0);
  }

  // when oraclePrice is above upperBoundPrice, should not revert
  function testRequirePriceUpperBound_priceIsAbove () public {
    primatives.requirePriceUpperBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0 - 1);
  }

}
