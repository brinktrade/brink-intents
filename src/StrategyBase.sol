// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

struct Call {
  address targetContract;
  bytes data;
}

abstract contract StrategyBase { }
