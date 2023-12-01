// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "../../src/SwapAmounts/BlockIntervalDutchAuctionAmount01.sol";

contract MockBlockIntervalDutchAuctionAmount01 is BlockIntervalDutchAuctionAmount01 {

  function setBlockIntervalState(uint64 id, uint128 start, uint16 counter) public {
    _setBlockIntervalState(id, start, counter);
  }

}
