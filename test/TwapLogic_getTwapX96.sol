// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TwapAdapter_getTwapX96 is Test, Helper  {
  function setUp () public {
    setupAll();
  }

  // providing a single twapInterval of 1000s, should return TWAP for 1000s - 0s
  function testGetTwapX96_singleInterval () public {
    uint256 p = twapAdapter.getTwapX96(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000);
    assertEq(p, MAGIC_TWAP_PRICE_USDC_ETH_1000_0);
  }

  // providing two twapInterval values of 1000s and 0s, should return TWAP for 1000s - 0s
  function testGetTwapX96_twoIntervalToNow () public {
    uint256 p = twapAdapter.getTwapX96(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000, 0);
    assertEq(p, MAGIC_TWAP_PRICE_USDC_ETH_1000_0);
  }

  // providing two twapInterval values of 2000s and 1000s, should return TWAP for 2000s - 1000s
  function testGetTwapX96_twoIntervalPast () public {
    uint256 p = twapAdapter.getTwapX96(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 2000, 1000);
    assertEq(p, MAGIC_TWAP_PRICE_USDC_ETH_2000_1000);
  }

  // providing two secondsAgos array with 2000s and 1000s, should return TWAP for 2000s - 1000s
  function testGetTwapX96_secondsAgos () public {
    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = 2000;
    secondsAgos[1] = 1000;
    uint256 p = twapAdapter.getTwapX96(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), secondsAgos);
    assertEq(p, MAGIC_TWAP_PRICE_USDC_ETH_2000_1000);
  }

  // providing one secondsAgos array with 1000s, should return TWAP for 1000s - 0s
  function testGetTwapX96_oneSecondsAgos () public {
    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = 1000;
    uint256 p = twapAdapter.getTwapX96(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), secondsAgos);
    assertEq(p, MAGIC_TWAP_PRICE_USDC_ETH_1000_0);
  }

  // providing empty secondsAgos, should return current pool spot price
  function testGetTwapX96_emptySecondsAgos () public {
    uint256 p = twapAdapter.getTwapX96(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), new uint32[](0));
    (uint160 sqrtPriceX96, , , , , , ) = USDC_ETH_FEE500_UNISWAP_V3_POOL.slot0();
    assertEq(p, twapAdapter.getPriceX96FromSqrtPriceX96(sqrtPriceX96));
  }

  // providing twapInterval 0, should return current pool spot price
  function testGetTwapX96_twapInterval0 () public {
    uint256 p = twapAdapter.getTwapX96(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 0);
    (uint160 sqrtPriceX96, , , , , , ) = USDC_ETH_FEE500_UNISWAP_V3_POOL.slot0();
    assertEq(p, twapAdapter.getPriceX96FromSqrtPriceX96(sqrtPriceX96));
  }

  // providing more than 2 secondsAgos should revert
  function testGetTwapX96_moreThanTwoSecondsAgos () public {
    vm.expectRevert("Invalid secondsAgos values");
    uint32[] memory secondsAgos = new uint32[](3);
    secondsAgos[0] = 3000;
    secondsAgos[1] = 2000;
    secondsAgos[2] = 1000;
    twapAdapter.getTwapX96(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), secondsAgos);
  }

  // providing secondsAgos with negative diff should revert
  function testGetTwapX96_negativeDiffSecondsAgos () public {
    vm.expectRevert("Invalid secondsAgos values");
    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = 1000;
    secondsAgos[1] = 2000;
    twapAdapter.getTwapX96(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), secondsAgos);
  }
}
