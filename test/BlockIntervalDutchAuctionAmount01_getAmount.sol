// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";
import "./Mocks/MockBlockIntervalDutchAuctionAmount01.sol";

contract BlockIntervalDutchAuctionAmount01_getAmount is Test, Helper  {

  MockBlockIntervalDutchAuctionAmount01 testContract;
  uint inputAmount;
  uint64 blockIntervalId;
  uint128 firstAuctionStartBlock;
  uint128 auctionDelayBlocks;
  uint128 auctionDurationBlocks;
  int24 startPercentE6;
  int24 endPercentE6;
  address priceX96Oracle;
  bytes priceX96OracleParams;

  function setUp () public {
    setupAll();
    testContract = new MockBlockIntervalDutchAuctionAmount01();
    
    // default auction params:
    inputAmount = 1_000000000000000000;
    blockIntervalId = 12345;
    firstAuctionStartBlock = uint128(BLOCK_JAN_25_2023); // blockNumer: 16_485_101
    auctionDelayBlocks = 7_200; // ~1 day between auctions
    auctionDurationBlocks = 75; // ~15 minute auction duration
    startPercentE6 = 150000; // start at 15% above oracle price (150000 = 0.15 * 10**6)
    endPercentE6 = -150000; // end at 15% below oracle price (-150000 = -0.15 * 10**6);
    priceX96Oracle = address(twapInverseAdapter02); // using inverse adapter for ETH->DAI swap, because pool is DAI-ETH
    priceX96OracleParams = abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 60); // DAI-ETH 0.3% Fee Pool: 60 second TWAP
  }

  // test output amount when the first auction starts
  function testBlockIntervalDutchAuctionAmount01_getAmount_firstAuctionStart () public {
    // get expected output: should be startPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionStartOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(startPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      firstAuctionStartBlock,
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, auctionStartOutputAmount);
  }

  // test output amount when first auction is active
  function testBlockIntervalDutchAuctionAmount01_getAmount_firstAuctionActive () public {
    // get expected output: should be at approximately the midpoint between startPercent and endPercent,
    // relative to priceOracle reported output amount
    uint auctionMidwayOutputAmount = 1552515387436826869931; // ~1552.515 DAI

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      firstAuctionStartBlock - 37, // set firstAuctionStartBlock so that the current forked block is about halfway through 75 block auction
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, auctionMidwayOutputAmount);
  }

  // test output amount when first auction is complete
  function testBlockIntervalDutchAuctionAmount01_getAmount_firstAuctionComplete () public {
    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionEndOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(endPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      firstAuctionStartBlock - 75, // set firstAuctionStartBlock so that the current forked block is all the way through 75 block auction
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, auctionEndOutputAmount);
  }

  // test output amount when first auction is complete and end percent is -100%. Amount should be 0
  function testBlockIntervalDutchAuctionAmount01_getAmount_firstAuctionComplete_negative100End () public {
    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      firstAuctionStartBlock - 75, // set firstAuctionStartBlock so that the current forked block is all the way through 75 block auction
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      -1000000, // -100% = -1.00 * 10**6
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, 0);
  }

  // test output amount when first auction is complete and end percent is -150%. Amount should be 0 (no overflow)
  function testBlockIntervalDutchAuctionAmount01_getAmount_firstAuctionComplete_negative150End () public {
    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      firstAuctionStartBlock - 75, // set firstAuctionStartBlock so that the current forked block is all the way through 75 block auction
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      -1500000, // -150% = -1.50 * 10**6
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, 0);
  }

  // test output amount when previous auction was filled and auction delay period is active
  function testBlockIntervalDutchAuctionAmount01_getAmount_previousAuctionFilled_auctionDelayActive () public {
    // set previous auction filled (block interval state set) so that current forked block is about halfway through the uaction delay period
    uint128 prevAuctionFilledBlock = uint128(BLOCK_JAN_25_2023) - (auctionDelayBlocks / 2);
    testContract.setBlockIntervalState(blockIntervalId, prevAuctionFilledBlock , 17); // set counter to 17, doesn't matter for this case

    // get expected output: should be startPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionStartOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(startPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      0, // firstAuctionStartBlock should not matter for this case
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, auctionStartOutputAmount);
  }

  // test output amount when previous auction was filled and auction has started
  function testBlockIntervalDutchAuctionAmount01_getAmount_previousAuctionFilled_auctionStarted () public {
    // set previous auction filled (block interval state set) so that current forked block is 1 block into the auction
    uint128 prevAuctionFilledBlock = uint128(BLOCK_JAN_25_2023) - (auctionDelayBlocks + 1);
    testContract.setBlockIntervalState(blockIntervalId, prevAuctionFilledBlock , 17);

    // get expected output: should be startPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionStartOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(startPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      0, // firstAuctionStartBlock should not matter for this case
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96Oracle,
      priceX96OracleParams
    ));

    // auction output amount should be slightly lower than start amount
    assertEq(outputAmount < auctionStartOutputAmount, true);
    assertEq(outputAmount > auctionStartOutputAmount - 10*10**18, true);
  }

  // test output amount when previous auction was filled and auction has almost ended
  function testBlockIntervalDutchAuctionAmount01_getAmount_previousAuctionFilled_auctionEnding () public {
    // set previous auction filled (block interval state set) so that current forked block is 1 block before the auction ends
    uint128 prevAuctionFilledBlock = uint128(BLOCK_JAN_25_2023) - (auctionDelayBlocks + auctionDurationBlocks - 1);
    testContract.setBlockIntervalState(blockIntervalId, prevAuctionFilledBlock , 17);

    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionEndOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(endPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      0, // firstAuctionStartBlock should not matter for this case
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96Oracle,
      priceX96OracleParams
    ));

    // auction output amount should be slightly higher than end amount
    assertEq(outputAmount > auctionEndOutputAmount, true);
    assertEq(outputAmount < auctionEndOutputAmount + 10*10**18, true);
  }

  // test output amount when previous auction was filled and auction has almost ended
  function testBlockIntervalDutchAuctionAmount01_getAmount_previousAuctionFilled_auctionEnded () public {
    // set previous auction filled (block interval state set) so that current forked block is 10k blocks after the auction ended
    uint128 prevAuctionFilledBlock = uint128(BLOCK_JAN_25_2023) - (auctionDelayBlocks + auctionDurationBlocks + 10_000);
    testContract.setBlockIntervalState(blockIntervalId, prevAuctionFilledBlock , 17);

    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionEndOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(endPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      0, // firstAuctionStartBlock should not matter for this case
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96Oracle,
      priceX96OracleParams
    ));

    // auction output amount should be equal to the end amount
    assertEq(outputAmount, auctionEndOutputAmount);
  }

  // test output amount when price output is a decimal and auction has started
  function testBlockIntervalDutchAuctionAmount01_getAmount_decimalPrice_auctionStart () public {
    uint usdcInputAmount = 1500 * 10**6;

    // USDC/ETH TWAP price will be a decimal * 2**96
    uint price = twapAdapter02.getUint256(abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * usdcInputAmount / 2**96;
    uint auctionStartOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(startPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      usdcInputAmount,
      blockIntervalId,
      firstAuctionStartBlock,
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      address(twapAdapter02),
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000)
    ));

    assertEq(outputAmount, auctionStartOutputAmount);
  }

  // test output amount when first auction is active
  function testBlockIntervalDutchAuctionAmount01_getAmount_decimalPrice_auctionActive () public {
    uint usdcInputAmount = 1500 * 10**6;

    // get expected output: should be at approximately the midpoint between startPercent and endPercent,
    // relative to priceOracle reported output amount
    uint auctionMidwayOutputAmount = 969944936533639121; // ~0.9699 WETH

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      usdcInputAmount,
      blockIntervalId,
      firstAuctionStartBlock - 37, // set firstAuctionStartBlock so that the current forked block is about halfway through 75 block auction
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      address(twapAdapter02),
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000)
    ));

    assertEq(outputAmount, auctionMidwayOutputAmount);
  }

  // test output amount when first auction is complete
  function testBlockIntervalDutchAuctionAmount01_getAmount_decimalPrice_auctionComplete () public {
    uint usdcInputAmount = 1500 * 10**6;
    
    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapAdapter02.getUint256(abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * usdcInputAmount / 2**96;
    uint auctionEndOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(endPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      usdcInputAmount,
      blockIntervalId,
      firstAuctionStartBlock - 75, // set firstAuctionStartBlock so that the current forked block is all the way through 75 block auction
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      address(twapAdapter02),
      abi.encode(address(USDC_ETH_FEE500_UNISWAP_V3_POOL), 1000)
    ));

    assertEq(outputAmount, auctionEndOutputAmount);
  }

  // test input amount (increasing) when the first auction starts
  function testBlockIntervalDutchAuctionAmount01_getAmount_inputIncreasing_auctionStarted () public {
    // auction goes from -15% to 15% relative to price oracle
    int24 startPercentE6_inputIncreasing = -150000;
    int24 endPercentE6_inputIncreasing = 150000;

    // get expected output: should be 15% below priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionStartOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(startPercentE6_inputIncreasing) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      firstAuctionStartBlock,
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6_inputIncreasing,
      endPercentE6_inputIncreasing,
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, auctionStartOutputAmount);
  }

  // test output amount when first auction is active
  function testBlockIntervalDutchAuctionAmount01_getAmount_inputIncreasing_auctionActive () public {
    // auction goes from -15% to 15% relative to price oracle
    int24 startPercentE6_inputIncreasing = -150000;
    int24 endPercentE6_inputIncreasing = 150000;

    // get expected output: should be at approximately the midpoint between startPercent and endPercent,
    // relative to priceOracle reported output amount
    uint auctionMidwayOutputAmount = 1546314628574787629319; // ~1546.31 DAI

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      firstAuctionStartBlock - 37, // set firstAuctionStartBlock so that the current forked block is about halfway through 75 block auction
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6_inputIncreasing,
      endPercentE6_inputIncreasing,
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, auctionMidwayOutputAmount);
  }

  // test output amount when first auction is complete
  function testBlockIntervalDutchAuctionAmount01_getAmount_inputIncreasing_auctionComplete () public {
    // auction goes from -15% to 15% relative to price oracle
    int24 startPercentE6_inputIncreasing = -150000;
    int24 endPercentE6_inputIncreasing = 150000;

    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionEndOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(endPercentE6_inputIncreasing) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      firstAuctionStartBlock - 75, // set firstAuctionStartBlock so that the current forked block is all the way through 75 block auction
      auctionDelayBlocks,
      auctionDurationBlocks,
      startPercentE6_inputIncreasing,
      endPercentE6_inputIncreasing,
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, auctionEndOutputAmount);
  }

  // test auctionDurationBlocks set to 0, before auction starts
  function testBlockIntervalDutchAuctionAmount01_getAmount_auctionDurationZero_beforeAuction () public {
    // get expected output: should be startPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionStartOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(startPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      firstAuctionStartBlock,
      auctionDelayBlocks,
      0,
      startPercentE6,
      endPercentE6,
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, auctionStartOutputAmount);
  }

  // test auctionDurationBlocks set to 0, after auction ends
  function testBlockIntervalDutchAuctionAmount01_getAmount_auctionDurationZero_afterAuction () public {
    // get expected output: should be endPercentE6 away from priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint oracleReportedOutputAmount = price * inputAmount / 2**96;
    uint auctionEndOutputAmount = uint(int(oracleReportedOutputAmount) + int(oracleReportedOutputAmount) * int(endPercentE6) / int(10**6));

    // get actual output amount
    uint outputAmount = testContract.getAmount(abi.encode(
      inputAmount,
      blockIntervalId,
      firstAuctionStartBlock - 1,
      auctionDelayBlocks,
      0,
      startPercentE6,
      endPercentE6,
      priceX96Oracle,
      priceX96OracleParams
    ));

    assertEq(outputAmount, auctionEndOutputAmount);
  }
}
