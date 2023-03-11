// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Helper.sol";

contract PriceCurves_QuadraticPriceCurve_getOutput is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // testing with large input numbers (18 decimal ERC20 input)
  function testQuadraticPriceCurve_erc20_getOutput () public {
    uint ETH_USDC_1500_X96 = 1500 * Q96 / 10**(18-6);
    uint ETH_USDC_1600_X96 = 1600 * Q96 / 10**(18-6);

    uint total = 1000 * 10**18;

    // curveParams could also be calculated off-chain
    bytes memory curveParams = quadraticPriceCurve.calcCurveParams(
      abi.encode(int(total), int(ETH_USDC_1500_X96), int(ETH_USDC_1600_X96))
    );

    uint output0 = quadraticPriceCurve.getOutput(
      total,
      0,
      1 * 10**18,
      curveParams
    );
    
    // approaching ~1,500 USDC out
    assertEq(output0, 1500000033);

    uint output1 = quadraticPriceCurve.getOutput(
      total,
      999 * 10**18,
      1 * 10**18,
      curveParams
    );
    
    // approaching ~1,600 USDC out
    assertEq(output1, 1599899687);
  }

  // testing with small input numbers (for discrete NFT's)
  function testQuadraticPriceCurve_nft_getOutput () public {
    uint NFT_ETH_0_1_X96 = 1 * 10**17 * Q96; // 0.1 ETH
    uint NFT_ETH_0_2_X96 = 2 * 10**17 * Q96; // 0.2 ETH

    uint total = 15; // 15 NFT's in

    bytes memory curveParams = quadraticPriceCurve.calcCurveParams(
      abi.encode(int(total), int(NFT_ETH_0_1_X96), int(NFT_ETH_0_2_X96))
    );

    uint output0 = quadraticPriceCurve.getOutput(
      total,
      0,
      1,
      curveParams
    );
    
    // first NFT input should be exactly price0
    assertEq(output0, NFT_ETH_0_1_X96/Q96);

    uint output1 = quadraticPriceCurve.getOutput(
      total,
      14,
      1,
      curveParams
    );
    
    // last NFT input should be exactly price1
    assertEq(output1, NFT_ETH_0_2_X96/Q96);
  }

  function testQuadraticPriceCurve_getOutput_maxInputExceeded () public {
    vm.expectRevert(abi.encodeWithSelector(MaxInputExceeded.selector, 2));
    linearPriceCurve.getOutput(
      10, // 10 total
      8,  // 8 filled
      3, // reverts because only 2 remaining
      new bytes(0)
    );
  }

}
