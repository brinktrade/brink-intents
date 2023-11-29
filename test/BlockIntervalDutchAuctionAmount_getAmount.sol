// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";
import "./Mocks/MockBlockIntervalDutchAuctionAmount.sol";

contract BlockIntervalDutchAuctionAmount_getAmount is Test, Helper  {

  MockBlockIntervalDutchAuctionAmount testContract;

  function setUp () public {
    setupAll();
    testContract = new MockBlockIntervalDutchAuctionAmount();
  }

  // output amount when the first auction starts
  function testBlockIntervalDutchAuctionAmount_getAmount_firstAuctionStart () public {
    // auction params:
    uint inputAmount = 1_000000000000000000;
    uint64 blockIntervalId = 12345;
    uint128 firstAuctionStartBlock = uint128(BLOCK_JAN_25_2023); // blockNumer: 16_485_101
    uint128 auctionDelayBlocks = 7_200; // ~1 day between auctions
    uint128 auctionDurationBlocks = 75; // ~15 minute auction duration
    int24 startPercentE6 = 150000; // start at 15% above oracle price (150000 = 0.15 * 10**6)
    int24 endPercentE6 = -1000000; // end at 100% below oracle price (-1000000 = -1.00 * 10**6);
    address priceX96Oracle = address(twapInverseAdapter02); // using inverse adapter for ETH->DAI swap, because pool is DAI-ETH
    bytes memory priceX96OracleParams = abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 60); // DAI-ETH 0.3% Fee Pool: 60 second TWAP

    // get expected output: should be startPercentE6 above priceOracle reported output amount
    uint price = twapInverseAdapter02.getUint256(abi.encode(address(DAI_ETH_FEE3000_UNISWAP_V3_POOL), 1000));
    uint expectedOracleReportedOutputAmount = price * inputAmount / 2**96;
    uint expectedOutputAmount = uint(int(expectedOracleReportedOutputAmount) + int(expectedOracleReportedOutputAmount) * int(startPercentE6) / int(10**6));

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

    assertEq(outputAmount, expectedOutputAmount);
  }


}
