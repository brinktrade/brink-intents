// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "../Interfaces/ISwapAmount.sol";
import "../Interfaces/IUint256Oracle.sol";
import "../Utils/BlockIntervalUtil.sol";
import "./DutchAuctionAmountBase.sol";

contract DutchAuctionAmount01 is ISwapAmount, DutchAuctionAmountBase {
  /**
   * @dev returns the amount for a single dutch auction.
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
   * - auctionStartBlock: The block when the dutch auction will start
   * - auctionDurationBlocks: The number of blocks for amount to change from the start percent to the end percent relative to oracle
   * - startPercentE6: Percentage of the PriceOracle reported amount where the auction curve should start, multiplied by 10**6
   * - endPercentE6: Percentage of the PriceOracle reported amount where the auction curve should end, multiplied by 10**6
   * - priceX96Oracle: IUint256Oracle that should report the price
   * - priceX96OracleParams: params for the priceX96Oracle.getUint256() call 
   * 
   */
  function getAmount (bytes memory params) public view returns (uint amount) {
    (
      uint oppositeTokenAmount,
      uint128 auctionStartBlock,
      uint128 auctionDurationBlocks,
      int24 startPercentE6,
      int24 endPercentE6,
      address priceX96Oracle,
      bytes memory priceX96OracleParams
    ) = abi.decode(params, (uint, uint128, uint128, int24, int24, address, bytes));

    // get the oracle price. Price is expected to be multiplied by 2**96.
    uint priceX96 = IUint256Oracle(priceX96Oracle).getUint256(priceX96OracleParams);

    amount = getAuctionAmount(
      uint128(block.number),
      oppositeTokenAmount,
      auctionStartBlock,
      auctionDurationBlocks,
      startPercentE6,
      endPercentE6,
      priceX96
    );
  }
}