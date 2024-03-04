// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

abstract contract DutchAuctionAmountBase {
  uint256 public constant Q96 = 0x1000000000000000000000000;

  function getAuctionAmount (
    uint128 blockNumber,
    uint oppositeTokenAmount,
    uint128 auctionStartBlock,
    uint128 auctionDurationBlocks,
    int24 startPercentE6,
    int24 endPercentE6,
    uint priceX96
  ) public pure returns (uint amount) {
    int24 percentE6;
    uint128 auctionEndBlock = auctionStartBlock + auctionDurationBlocks;

    if (blockNumber <= auctionStartBlock) {
      // if current block is less than or equal to start block, percent is equal to the start percent
      percentE6 = startPercentE6;
    } else if (blockNumber > auctionStartBlock && blockNumber < auctionEndBlock) {
      // if current block is between start and end block, percent is on a linear range between start and end percent
      // calc percent between startPercentE6 and endPercentE6, based on where current block is relative to start block and end block
      percentE6 = _calcPercentOnLinearRange(auctionStartBlock, auctionEndBlock, blockNumber, startPercentE6, endPercentE6);
    } else {
      // if current block is greater than or equal to auctionEnd
      percentE6 = endPercentE6;
    }

    // unadjustedAmount is the amount based on oppositeTokenAmount and price, before adjusting by percentE6
    int unadjustedAmount = int(oppositeTokenAmount * priceX96 / Q96);

    // amount is adjusted by percentE6, which could be positive or negative
    int amountInt = unadjustedAmount + (unadjustedAmount * percentE6 / int(10**6));

    // if amount is less than 0, set to 0
    if (amountInt < 0) {
      amountInt = 0;
    }
    amount = uint(amountInt);
  }

  function _calcPercentOnLinearRange (
    uint128 startBlock, uint128 endBlock, uint128 currentBlock, int24 startPercent, int24 endPercent
  ) internal pure returns (int24 percent) {
    uint128 blocksTotal = endBlock - startBlock;
    uint128 blocksElapsed = currentBlock - startBlock;
    int24 percentRange = endPercent - startPercent;
    int percentElapsedX96 = int(uint(blocksElapsed)) * int(Q96) / int(uint(blocksTotal));
    percent = startPercent + int24(int(percentRange) * percentElapsedX96 / int(Q96));
  }
}