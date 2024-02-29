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
}
