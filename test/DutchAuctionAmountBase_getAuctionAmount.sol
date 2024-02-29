// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";
import "./Mocks/MockDutchAuctionAmountBase.sol";

contract MockDutchAuctionAmountBase_getAuctionAmount is Test, Helper  {

  MockDutchAuctionAmountBase testContract;
  uint inputAmount;
  uint128 auctionStartBlock;
  uint128 auctionDurationBlocks;
  int24 startPercentE6;
  int24 endPercentE6;
  address priceX96Oracle;
  bytes priceX96OracleParams;
  uint priceX96;

  function setUp () public {
    setupAll();
    testContract = new MockDutchAuctionAmountBase();
    
    // default auction params:
    inputAmount = 1_000000000000000000;
    auctionStartBlock = uint128(BLOCK_JAN_25_2023); // blockNumer: 16_485_101
    auctionDurationBlocks = 75; // ~15 minute auction duration
    startPercentE6 = 150000; // start at 15% above oracle price (150000 = 0.15 * 10**6)
    endPercentE6 = -150000; // end at 15% below oracle price (-150000 = -0.15 * 10**6);
    priceX96Oracle = address(twapInverseAdapter02); // using inverse adapter for ETH->DAI swap, because pool is DAI-ETH
    priceX96OracleParams = abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 60); // DAI-ETH 0.3% Fee Pool: 60 second TWAP
    // get the oracle price. Price is expected to be multiplied by 2**96.
    priceX96 = IUint256Oracle(priceX96Oracle).getUint256(priceX96OracleParams);
  }

  // test output amount when the auction starts
  function testDutchAuctionAmountBase_getAuctionAmount_auctionStart() public {
    // get expected output: should be startPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionStartOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(startPercentE6) / int(10**6));

    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      inputAmount,
      auctionStartBlock,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96
    );

    assertEq(outputAmount, auctionStartOutputAmount);
  }

  // test output amount when the auction is active
  function testDutchAuctionAmountBase_getAuctionAmount_auctionActive () public {
    // get expected output: should be at approximately the midpoint between startPercent and endPercent,
    // relative to priceOracle reported output amount
    uint auctionMidwayOutputAmount = 1552515387436826869931; // ~1552.515 DAI

    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      inputAmount,
      auctionStartBlock - 37, // set auctionStartBlock so that the current forked block is about halfway through 75 block auction
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96
    );

    assertEq(outputAmount, auctionMidwayOutputAmount);
  }

  // test output amount when the auction is complete
  function testDutchAuctionAmountBase_getAuctionAmount_auctionComplete () public {
    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionEndOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(endPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      inputAmount,
      auctionStartBlock - 75, // set auctionStartBlock so that the current forked block is all the way through 75 block auction
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96
    );

    assertEq(outputAmount, auctionEndOutputAmount);
  }

  // test output amount when auction is complete and end percent is -100%. Amount should be 0
  function testDutchAuctionAmountBase_getAuctionAmount_auctionComplete_negative100End () public {
    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      inputAmount,
      auctionStartBlock - 75, // set auctionStartBlock so that the current forked block is all the way through 75 block auction
      auctionDurationBlocks,
      startPercentE6,
      -1000000, // -100% = -1.00 * 10**6
      priceX96
    );

    assertEq(outputAmount, 0);
  }

  // test output amount when auction is complete and end percent is -150%. Amount should be 0 (no overflow)
  function testDutchAuctionAmountBase_getAuctionAmount_negative150End () public {
    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      inputAmount,
      auctionStartBlock - 75, // set auctionStartBlock so that the current forked block is all the way through 75 block auction
      auctionDurationBlocks,
      startPercentE6,
      -1500000, // -100% = -1.00 * 10**6
      priceX96
    );

    assertEq(outputAmount, 0);
  }

  // test output amount when price output is a decimal and auction has started
  function testDutchAuctionAmountBase_getAuctionAmount_decimalPrice_auctionStart () public {
    uint usdcInputAmount = 1500 * 10**6;

    // USDC/ETH TWAP price will be a decimal * 2**96
    uint price = twapAdapter02.getUint256(abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * usdcInputAmount / 2**96;
    uint auctionStartOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(startPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      usdcInputAmount,
      auctionStartBlock,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      price
    );

    assertEq(outputAmount, auctionStartOutputAmount);
  }

  // test output amount when price output is a decimal and auction is active
  function testDutchAuctionAmountBase_getAuctionAmount_decimalPrice_auctionActive () public {
    uint usdcInputAmount = 1500 * 10**6;
    
    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapAdapter02.getUint256(abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000));
    
    // get expected output: should be at approximately the midpoint between startPercent and endPercent,
    // relative to priceOracle reported output amount
    uint auctionMidwayOutputAmount = 969944936533639121; // ~0.9699 WETH

    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      usdcInputAmount,
      auctionStartBlock - 37, // set auctionStartBlock so that the current forked block is about halfway through 75 block auction
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      price
    );

    assertEq(outputAmount, auctionMidwayOutputAmount);
  }

  // test output amount when price output is a decimal and auction is complete
  function testDutchAuctionAmountBase_getAuctionAmount_decimalPrice_auctionComplete () public {
    uint usdcInputAmount = 1500 * 10**6;
    
    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapAdapter02.getUint256(abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * usdcInputAmount / 2**96;
    uint auctionEndOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(endPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      usdcInputAmount,
      auctionStartBlock - 75,// set auctionStartBlock so that the current forked block is all the way through 75 block auction
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      price
    );

    assertEq(outputAmount, auctionEndOutputAmount);
  }

  // test input amount (increasing) when the auction starts
  function testDutchAuctionAmountBase_getAuctionAmount_inputIncreasing_auctionStarted () public {
    // auction goes from -15% to 15% relative to price oracle
    int24 startPercentE6_inputIncreasing = -150000;
    int24 endPercentE6_inputIncreasing = 150000;

    // get expected output: should be 15% below priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionStartOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(startPercentE6_inputIncreasing) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      inputAmount,
      auctionStartBlock,
      auctionDurationBlocks,
      startPercentE6_inputIncreasing,
      endPercentE6_inputIncreasing,
      price
    );

    assertEq(outputAmount, auctionStartOutputAmount);
  }

  // test input amount (increasing) when the auction is active
  function testDutchAuctionAmountBase_getAuctionAmount_inputIncreasing_auctionActive () public {
    // auction goes from -15% to 15% relative to price oracle
    int24 startPercentE6_inputIncreasing = -150000;
    int24 endPercentE6_inputIncreasing = 150000;

    // get expected output: should be 15% below priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    
    // get expected output: should be at approximately the midpoint between startPercent and endPercent,
    // relative to priceOracle reported output amount
    uint auctionMidwayOutputAmount = 1546314628574787629319; // ~1546.31 DAI

    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      inputAmount,
      auctionStartBlock - 37, // set auctionStartBlock so that the current forked block is about halfway through 75 block auction
      auctionDurationBlocks,
      startPercentE6_inputIncreasing,
      endPercentE6_inputIncreasing,
      price
    );

    assertEq(outputAmount, auctionMidwayOutputAmount);
  }

  // test input amount (increasing) when the auction is complete
  function testDutchAuctionAmountBase_getAuctionAmount_inputIncreasing_auctionComplete () public {
    // auction goes from -15% to 15% relative to price oracle
    int24 startPercentE6_inputIncreasing = -150000;
    int24 endPercentE6_inputIncreasing = 150000;

    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionEndOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(endPercentE6_inputIncreasing) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      inputAmount,
      auctionStartBlock - 75, // set auctionStartBlock so that the current forked block is all the way through 75 block auction
      auctionDurationBlocks,
      startPercentE6_inputIncreasing,
      endPercentE6_inputIncreasing,
      price
    );

    assertEq(outputAmount, auctionEndOutputAmount);
  }

  // test auctionDurationBlocks set to 0, before auction starts
  function testDutchAuctionAmountBase_getAuctionAmount_auctionDurationZero_beforeAuction () public {
    // get expected output: should be startPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionStartOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(startPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      inputAmount,
      auctionStartBlock,
      0,
      startPercentE6,
      endPercentE6,
      price
    );

    assertEq(outputAmount, auctionStartOutputAmount);
  }

  // test auctionDurationBlocks set to 0, after auction ends
  function testDutchAuctionAmountBase_getAuctionAmount_auctionDurationZero_afterAuction () public {
    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionEndOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(endPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAuctionAmount(
      uint128(block.number),
      inputAmount,
      auctionStartBlock - 1,
      0,
      startPercentE6,
      endPercentE6,
      price
    );

    assertEq(outputAmount, auctionEndOutputAmount);
  }
}