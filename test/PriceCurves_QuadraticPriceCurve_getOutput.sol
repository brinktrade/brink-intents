// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

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
    assertEq(output1, 1599900034);
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

  // testing with large price input values, should not overflow
  function testQuadraticPriceCurve_largePriceInput_getOutput () public {
    uint price0 = 1 * 10**18 * 10**18 * Q96;
    uint price1 = 2 * 10**18 * 10**18 * Q96;
    uint total = 15;

    bytes memory curveParams = quadraticPriceCurve.calcCurveParams(
      abi.encode(int(total), int(price0), int(price1))
    );

    uint output0 = quadraticPriceCurve.getOutput(total, 0, 1, curveParams);
    assertEq(output0, price0/Q96);

    uint output1 = quadraticPriceCurve.getOutput(total, 14, 1, curveParams);
    assertEq(output1, price1/Q96);
  }

  // testing with large total value and small price values, should not overflow
  function testQuadraticPriceCurve_largeTotal_getOutput () public {
    uint price0 = 10 * Q96 / 10**(18-6);
    uint price1 = 25 * Q96 / 10**(18-6);
    uint total = 15_000_000_000_000 * 10**18;

    uint input = 1 * 10**18;

    bytes memory curveParams = quadraticPriceCurve.calcCurveParams(
      abi.encode(int(total), int(price0), int(price1))
    );

    // first 1 (10**18) input, should be swapped at price0
    uint output0 = quadraticPriceCurve.getOutput(total, 0, input, curveParams);
    assertEq(output0/input, price0/Q96);

    // last 1 (10**18) input, should be swapped at a price approaching price1
    uint output1 = quadraticPriceCurve.getOutput(total, total-input, input, curveParams);
    assertEq(output1/input, (price1-1)/Q96);
  }

  function testQuadraticPriceCurve_getOutput_maxInputExceeded () public {
    vm.expectRevert(abi.encodeWithSelector(MaxInputExceeded.selector, 2));
    quadraticPriceCurve.getOutput(
      10, // 10 total
      8,  // 8 filled
      3, // reverts because only 2 remaining
      new bytes(0)
    );
  }

}
