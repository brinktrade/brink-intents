// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract FlatPriceCurve_getOutput is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testFlatPriceCurve_getOutput () public {
    uint output = flatPriceCurve.getOutput(
      10_000000000000000000,
      MAGIC_TWAP_PRICE_ETH_USDC_1000_0,
      9_000000000000000000,
      950000000000000000 // 0.95 ETH
    );
    assertEq(output, 1472095343); // ~1549.57 USDC
  }

  function testFlatPriceCurve_getOutput_maxInputExceeded () public {
    vm.expectRevert(abi.encodeWithSelector(MaxInputExceeded.selector, 1_000000000000000000));
    flatPriceCurve.getOutput(
      10_000000000000000000,
      MAGIC_TWAP_PRICE_ETH_USDC_1000_0,
      9_000000000000000000,
      2_000000000000000000 // more than 1 ETH remaining input
    );
  }

}
