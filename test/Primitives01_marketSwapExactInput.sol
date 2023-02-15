// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_marketSwapExactInput is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // function testMarketSwapExactInput () public {
  //   primitives.marketSwapExactInput(
  //     Call(address(0), new bytes(0)),
  //     address(0),
  //     WETH_Token,
  //     USDC_Token,
  //     1_300000000000000000,
  //     UnsignedMarketSwapData(
  //       address(0),
  //       0,
  //       new IdMerkleProof[](0),
  //       new IdMerkleProof[](0),
  //       Call(address(0), new bytes(0))
  //     )
  //   );
  // }

}
