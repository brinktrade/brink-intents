// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "../../src/SwapAmounts/BlockIntervalDutchAuctionAmount02.sol";

contract MockBlockIntervalDutchAuctionAmount02 is BlockIntervalDutchAuctionAmount02 {

  function setBlockIntervalState(uint64 id, uint128 start, uint16 counter) public {
    _setBlockIntervalState(id, start, counter);
  }

}
