// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Primatives/Primatives01.sol";
import "./Helper.sol";

contract Primatives01_requirePriceLowerBound is Primatives01, Test, Helper  {

  function setUp () public {
    setupFork();
  }

  // when price is below to the provided value, should revert
  function testRequirePriceLowerBound_priceIsBelow () public {

  }

  // when price is equal to the provided value, should not revert
  function testRequirePriceLowerBound_priceIsEqual () public {

  }

  // when price is above the provided value, should not revert
  function testRequirePriceLowerBound_priceIsAbove () public {

  }

}
