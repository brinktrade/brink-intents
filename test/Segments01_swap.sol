// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_swap is Test, Helper  {

  VmSafe.Wallet public solverSignerWallet;
  VmSafe.Wallet public invalidSolverSignerWallet;

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();

    solverSignerWallet = createWallet(0);
    invalidSolverSignerWallet = createWallet(1);
    vm.prank(solverValidatorAdmin);
    solverValidator01.setSolverValidity(solverSignerWallet.addr, true);
  }

  function test_swap_successCase () public {
    uint usdcInputAmount = 1450_000000;

    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segments), usdcInputAmount);

    uint wethOutputAmount = usdcInputAmount * MAGIC_TWAP_PRICE_USDC_ETH_1000_0 / Q96;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, wethOutputAmount, new uint[](0));

    assertEq(limitSwap_loadFilledAmount(address(segments), DEFAULT_FILL_STATE_PARAMS, usdcInputAmount), 0);
    startBalances(address(filler));
    startBalances(TRADER_1);

    // solverSignerWallet signs the "unsigned" swap data, which is the solution data they provide that has not been signed by the intent signer
    bytes32 dataHash = segments.unsignedSwapDataHash(
      address(filler),
      usdcInputAmount,
      EMPTY_IDS_PROOF,
      EMPTY_IDS_PROOF,
      Call(address(filler), fillCall)
    );
    UnsignedSwapData memory unsignedSwapData = UnsignedSwapData(
      address(filler),
      usdcInputAmount,
      EMPTY_IDS_PROOF,
      EMPTY_IDS_PROOF,
      Call(address(filler), fillCall),
      signEIP191(solverSignerWallet, dataHash)
    );

    // execute the swap segment
    segments.swap(
      TRADER_1,
      USDC_Token,
      WETH_Token,
      usdcInputAmount,
      flatPriceCurve,
      abi.encode(MAGIC_TWAP_PRICE_USDC_ETH_1000_0),
      DEFAULT_FILL_STATE_PARAMS,
      solverValidator01,
      unsignedSwapData
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(limitSwap_loadFilledAmount(address(segments), DEFAULT_FILL_STATE_PARAMS, usdcInputAmount), usdcInputAmount);
    
    assertEq(diffBalance(USDC, TRADER_1), -int(usdcInputAmount));
    assertEq(diffBalance(USDC, address(filler)), int(usdcInputAmount));
    assertEq(diffBalance(WETH, TRADER_1), int(wethOutputAmount));
    assertEq(diffBalance(WETH, address(filler)), -int(wethOutputAmount));
  }

  // when solution data is signed by an invalid solver
  function test_swap_invalidSolver () public {
    uint usdcInputAmount = 1450_000000;

    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segments), usdcInputAmount);

    uint wethOutputAmount = usdcInputAmount * MAGIC_TWAP_PRICE_USDC_ETH_1000_0 / Q96;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, wethOutputAmount, new uint[](0));

    // solverSignerWallet signs the "unsigned" swap data, which is the solution data they provide that has not been signed by the intent signer
    bytes32 dataHash = segments.unsignedSwapDataHash(
      address(filler),
      usdcInputAmount,
      EMPTY_IDS_PROOF,
      EMPTY_IDS_PROOF,
      Call(address(filler), fillCall)
    );
    UnsignedSwapData memory unsignedSwapData = UnsignedSwapData(
      address(filler),
      usdcInputAmount,
      EMPTY_IDS_PROOF,
      EMPTY_IDS_PROOF,
      Call(address(filler), fillCall),
      signEIP191(invalidSolverSignerWallet, dataHash)
    );

    // execute the swap segment and expect InvalidSolver revert
    vm.expectRevert(abi.encodeWithSelector(InvalidSolver.selector, invalidSolverSignerWallet.addr));
    segments.swap(
      TRADER_1,
      USDC_Token,
      WETH_Token,
      usdcInputAmount,
      flatPriceCurve,
      abi.encode(MAGIC_TWAP_PRICE_USDC_ETH_1000_0),
      DEFAULT_FILL_STATE_PARAMS,
      solverValidator01,
      unsignedSwapData
    );
  }
}