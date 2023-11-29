// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "../Interfaces/ISwapAmount.sol";
import "../Interfaces/IUint256Oracle.sol";
import "../Utils/BlockIntervalUtil.sol";

contract BlockIntervalDutchAuctionAmount is ISwapAmount, BlockIntervalUtil {

  uint256 public constant Q96 = 0x1000000000000000000000000;

  /**
   * @dev returns the amount for a recurring dutch auction based on the blockInterval segment state.
   *
   * This can be used with input or output amount to create a "dutch auction" where the auction starts on a price that is
   * more favorable to the intent signer, and ends on a price that is more favorable to the solver.
   
   * In the case of "output", this would be a decreasing required amount. In the case of "input", this would be an increasing
   * allowed amount.
   *
   * "auction" in variable names refers to the linear graph when amount is changing from startPercentE6 to endPercentE6. The settlement
   * of a swap could occur before or after this range.
   *
   * Expects these encoded bytes params:
   * - blockIntervalId: The id provided to the blockInterval segment
   * - firstAuctionStartBlock: The block when the first dutch auction will start
   * - auctionDelayBlocks: The number of blocks to wait for the next auction to start after the previous auction has closed. Should be
   *                       set to the same value as intervalMinSize of blockInterval
   * - auctionDurationBlocks: The number of blocks for amount to change from the start percent to the end percent relative to oracle
   * - startPercentE6: Percentage of the PriceOracle reported amount where the auction curve should start, multiplied by 10**6
   * - endPercentE6: Percentage of the PriceOracle reported amount where the auction curve should end, multiplied by 10**6
   * - priceX96Oracle: IUint256Oracle that should report the price
   * - priceX96OracleParams: params for the priceX96Oracle.getUint256() call
   *
   * When used with the blockInterval segment, getAmount() returns a dynamic value starting at a percentage above or below
   * a reported price value, and ending at a percentage above or below a reported price value. 
   * 
   */
  function getAmount (bytes memory params) public view returns (uint amount) {
    (
      uint oppositeTokenAmount,
      uint64 blockIntervalId,
      uint128 firstAuctionStartBlock,
      uint128 auctionDelayBlocks,
      uint128 auctionDurationBlocks,
      int24 startPercentE6,
      int24 endPercentE6,
      address priceX96Oracle,
      bytes memory priceX96OracleParams
    ) = abi.decode(params, (uint, uint64, uint128, uint128, uint128, int24, int24, address, bytes));

    int24 percentE6;
    {
      // get the block when the last blockInterval ended
      uint128 auctionStartBlock;
      (uint128 prevBlockIntervalEndBlock,) = getBlockIntervalState(blockIntervalId);
      if (prevBlockIntervalEndBlock == 0) {
        // if there is no state for blockInterval, this is the first block interval 
        auctionStartBlock = firstAuctionStartBlock;
      } else {
        // if there is state for blockInterval, set auctionStartBlock to the previous interval end + auction delay blocks
        auctionStartBlock = prevBlockIntervalEndBlock + auctionDelayBlocks;
      }
      uint128 auctionEndBlock = auctionStartBlock + auctionDurationBlocks;

      uint128 blockNum = uint128(block.number);
      if (blockNum <= auctionStartBlock) {
        // if current block is less than or equal to start block, percent is equal to the start percent
        percentE6 = startPercentE6;
      } else if (blockNum > auctionStartBlock && blockNum < auctionEndBlock) {
        // if current block is between start and end block, percent is on a linear range between start and end percent
        // calc percent between startPercentE6 and endPercentE6, based on where current block is relative to start block and end block
        percentE6 = _calcPercentOnLinearRange(auctionStartBlock, auctionEndBlock, blockNum, startPercentE6, endPercentE6);
      } else if (blockNum >= auctionEndBlock) {
        // if current block is greater than auctionEnd
        percentE6 = endPercentE6;
      }
    }

    // get price from oracle
    uint priceX96 = IUint256Oracle(priceX96Oracle).getUint256(priceX96OracleParams);

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
