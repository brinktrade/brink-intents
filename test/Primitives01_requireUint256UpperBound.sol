// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Primitives/Primitives01.sol";
import "./Helper.sol";

contract Primitives01_requireUint256UpperBound is Primitives01, Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // when oracleUint256 is below upperBoundUint256, should revert
  function testRequireUint256UpperBound_uint256IsBelow () public {
    vm.expectRevert(abi.encodeWithSelector(Uint256UpperBoundNotMet.selector, MAGIC_TWAP_PRICE_USDC_ETH_1000_0));
    primitives.requireUint256UpperBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0 + 1);
  }

  // when oracleUint256 is equal to upperBoundUint256, should not revert
  function testRequireUint256UpperBound_uint256IsEqual () public {
    primitives.requireUint256UpperBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0);
  }

  // when oracleUint256 is above upperBoundUint256, should not revert
  function testRequireUint256UpperBound_uint256IsAbove () public {
    primitives.requireUint256UpperBound(twapAdapter, abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), uint32(1000)), MAGIC_TWAP_PRICE_USDC_ETH_1000_0 - 1);
  }

}
