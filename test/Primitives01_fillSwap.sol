// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Primitives01_fillSwap is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
  }

  // erc20 to erc20 swap
  function testFillSwap_erc20 () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(primitiveInternals), 1450_000000);

    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, 1_000000000000000000, new uint[](0));

    startBalances(address(filler));
    startBalances(TRADER_1);

    primitiveInternals.fillSwap(
      USDC_Token,
      WETH_Token,
      TRADER_1,
      address(filler),
      1450_000000,
      1_000000000000000000,
      EMPTY_IDS_MERKLE_PROOF,
      EMPTY_IDS_MERKLE_PROOF,
      Call(address(filler), fillCall)
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), -1450_000000);
    assertEq(diffBalance(USDC, address(filler)), 1450_000000);
    assertEq(diffBalance(WETH, TRADER_1), 1_000000000000000000);
    assertEq(diffBalance(WETH, address(filler)), -1_000000000000000000);
  }

  // erc20 to erc721 (any id) swap
  function testFillSwap_erc721_anyIds_out () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(primitiveInternals), 500_000000);

    uint[] memory ids = new uint[](2);
    ids[0] = 5268;
    ids[1] = 4631;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, ids);

    IdsMerkleProof memory outIds = EMPTY_IDS_MERKLE_PROOF;
    outIds.ids = ids;

    startBalances(address(filler));
    startBalances(TRADER_1);

    primitiveInternals.fillSwap(
      USDC_Token,
      DOODLES_Token,
      TRADER_1,
      address(filler),
      500_000000,
      2,
      EMPTY_IDS_MERKLE_PROOF,
      outIds,
      Call(address(filler), fillCall)
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), -500_000000);
    assertEq(diffBalance(USDC, address(filler)), 500_000000);
    assertEq(diffBalance(DOODLES, TRADER_1), 2);
    assertEq(diffBalance(DOODLES, 5268, TRADER_1), 1);
    assertEq(diffBalance(DOODLES, 4631, TRADER_1), 1);
    assertEq(diffBalance(DOODLES, address(filler)), -2);
    assertEq(diffBalance(DOODLES, 5268, address(filler)), -1);
    assertEq(diffBalance(DOODLES, 4631, address(filler)), -1);
  }

}
