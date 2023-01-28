// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Oracles/TwapAdapter.sol";
import "./Helper.sol";

contract TwapAdapter_price is TwapAdapter, Test, Helper  {

  function setUp () public {
    setupFork();
  }

  function testPrice () public {
    uint p = price(USDC, WETH);
    console.log(p);
  }

}
