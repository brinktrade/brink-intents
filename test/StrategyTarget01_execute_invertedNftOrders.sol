// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract StrategyTarget01_execute_invertedNftOrders is Test, Helper  {

  /*
    tests for an inverted NFT market making (aka "range order"):

    Market make 6 DOODLE's, from range from 0.8 ETH -> 1.3 ETH, w/ spread fee of 0.05 ETH,
    Assume current "floor" is 1.2, so start with buy side at 1.1 ETH, and sell side at 1.25 ETH 

    order_0: limitSwapExactOutput linearCurve(1.3 ETH -> 0.8 ETH) -> 6 DOODLES, start at 1.1 ETH -> 1 DOODLES
    order_1: limitSwapExactInput 6 DOODLES -> linearCurve(0.85 ETH -> 1.35 ETH), start at 1 DOODLES -> 1.25 ETH
  */

  bytes nftBuyCurveParams;
  bytes nftSellCurveParams;
  FillStateParams nftBuyFillStateParams;
  FillStateParams nftSellFillStateParams;

  uint nftTotal = 6;
  uint ethTotal = 66 * 10**17; // 6.6 ETH
  
  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
  }

  function createInvertedNftStrategy () public returns (Strategy memory strategy) {      
    nftBuyCurveParams;
    nftSellCurveParams;
    nftBuyFillStateParams = DEFAULT_FILL_STATE_PARAMS;
    nftSellFillStateParams = DEFAULT_FILL_STATE_PARAMS;

    {
      {
        // setup linear "buy" curve for 6 NFT's, with prices of 1.3 ETH to 0.8 ETH, delta of 0.1 ETH. total "input" is 6.3 ETH
        // the curve will be inverted by the limitSwapExactOutput function, so the output is NFT and input is ETH
        uint BUY_NFT_ETH_p0_X96 = 13 * Q96 * 10**17; // 1.3 ETH
        uint BUY_NFT_ETH_p1_X96 = 8 * Q96 * 10**17; // 0.8 ETH
        nftBuyCurveParams = linearPriceCurve.calcCurveParams(
          abi.encode(int(nftTotal), int(BUY_NFT_ETH_p0_X96), int(BUY_NFT_ETH_p1_X96))
        );
      }

      {
        // setup linear "sell" curve for 6 NFT's, with prices of 0.85 ETH to 1.35 ETH, delta of 0.1 ETH. total "output" is 6.6 ETH
        uint SELL_NFT_ETH_p0_X96 = 85 * Q96 * 10**16; // 0.85 ETH
        uint SELL_NFT_ETH_p1_X96 = 135 * Q96 * 10**16; // 1.35 ETH
        nftSellCurveParams = linearPriceCurve.calcCurveParams(
          abi.encode(int(nftTotal), int(SELL_NFT_ETH_p0_X96), int(SELL_NFT_ETH_p1_X96))
        );
      }

      {
        // start the buy side at 33% of the curve (4 of 6 NFT's remaining to buy)
        nftBuyFillStateParams.id = 123;
        nftBuyFillStateParams.startX96 = uint128(2 * Q96 / 6) + 1; // +1 to avoid rounding errors
        nftBuyFillStateParams.sign = true; 
      }

      {
        // start the sell side at 66% of the curve (2 of 6 NFT's remaining to sell)
        nftSellFillStateParams.id = 123;
        nftSellFillStateParams.startX96 = uint128(2 * Q96 / 6);  // don't add 1 for inverted
        nftSellFillStateParams.sign = false; // inverts the calculation of fillPercent, so 33% fillState = 66% (100% - 33%)
      }

      // setup the "buy" NFT order
      Primitive[] memory primitives_order0 = new Primitive[](1);
      primitives_order0[0] = Primitive(
        abi.encodeWithSelector(
          Primitives01.limitSwapExactOutput.selector,
          TRADER_1,
          WETH_Token,
          DOODLES_Token,
          nftTotal,
          linearPriceCurve,
          nftBuyCurveParams,
          nftBuyFillStateParams,
          new bytes(0)
        ),
        true
      );

      // setup the "sell" NFT order
      Primitive[] memory primitives_order1 = new Primitive[](1);
      primitives_order1[0] = Primitive(
        abi.encodeWithSelector(
          Primitives01.limitSwapExactInput.selector,
          TRADER_1,
          DOODLES_Token,
          WETH_Token,
          nftTotal,
          linearPriceCurve,
          nftSellCurveParams,
          nftSellFillStateParams,
          new bytes(0)
        ),
        true
      );

      Order[] memory orders = new Order[](2);
      orders[0] = Order(primitives_order0);
      orders[1] = Order(primitives_order1);

      strategy = Strategy(
        address(primitives),
        orders,
        new bytes[](0),
        new bytes[](0)
      );
    }

    // approve max ETH needed for the strategy, and approvalAll DOODLES
    vm.prank(TRADER_1);
    WETH_ERC20.approve(address(strategyTarget), ethTotal);
    vm.prank(TRADER_1);
    DOODLES_ERC721.setApprovalForAll(address(strategyTarget), true);
  }

  function testExecute_invertedNftOrders_buyAndSell () public {
    Strategy memory strategy = createInvertedNftStrategy();
    
    // fill an NFT "buy" for TRADER_1
    bytes[] memory unsignedFillCalls = new bytes[](1);
    uint[] memory ids = new uint[](1);
    ids[0] = 5268;
    IdsProof memory idsProof = EMPTY_IDS_PROOF;
    idsProof.ids = ids;
    unsignedFillCalls[0] = abi.encode(
      address(filler),
      1,
      EMPTY_IDS_PROOF,
      idsProof,
      Call(
        address(filler),
        abi.encodeWithSelector(filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, ids)
      )
    );

    uint nftBuyCost = buyCost(1);
    uint nftSellCost = sellCost(1);
    assertEq(nftBuyCost, 11 * 10**17); // 1.1 ETH
    assertEq(nftSellCost, 125 * 10**16); // 1.25 ETH

    startBalances(address(filler));
    startBalances(TRADER_1);
    strategyTarget.execute(
      strategy,
      UnsignedData(
        0, // the "buy" NFT order (limitSwapExactOutput)
        unsignedFillCalls
      )
    );
    endBalances(address(filler));
    endBalances(TRADER_1);
    assertEq(diffBalance(WETH, TRADER_1), -int(nftBuyCost));           // paid 1.1 ETH
    assertEq(diffBalance(WETH, address(filler)), int(nftBuyCost));
    assertEq(diffBalance(DOODLES, TRADER_1), 1);                // received 1 DOODLES
    assertEq(diffBalance(DOODLES, address(filler)), -1);

    nftBuyCost = buyCost(1);
    nftSellCost = sellCost(1);
    assertEq(nftBuyCost, 1 * 10**18); // 1 ETH
    assertEq(nftSellCost, 115 * 10**16); // 1.1 ETH

    // fill an NFT "sell" for TRADER_1, for the NFT that was just bought
    unsignedFillCalls[0] = abi.encode(
      address(filler),
      1,
      idsProof,
      EMPTY_IDS_PROOF,
      Call(
        address(filler),
        abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, nftSellCost, new bytes(0))
      )
    );
    startBalances(address(filler));
    startBalances(TRADER_1);
    strategyTarget.execute(
      strategy,
      UnsignedData(
        1, // the "sell" NFT order (limitSwapExactInput)
        unsignedFillCalls
      )
    );
    endBalances(address(filler));
    endBalances(TRADER_1);
    assertEq(diffBalance(DOODLES, TRADER_1), -1);                 // sold 1 DOODLES
    assertEq(diffBalance(DOODLES, address(filler)), 1);
    assertEq(diffBalance(WETH, TRADER_1), int(nftSellCost));          // received 1.15 ETH
    assertEq(diffBalance(WETH, address(filler)), -int(nftSellCost));

    // back to original prices
    nftBuyCost = buyCost(1);
    nftSellCost = sellCost(1);
    assertEq(nftBuyCost, 11 * 10**17); // 1.1 ETH
    assertEq(nftSellCost, 125 * 10**16); // 1.25 ETH
  }

  function testExecute_invertedNftOrders_buyAll () public {
    Strategy memory strategy = createInvertedNftStrategy();
    
    // fill all NFT "buy" orders for TRADER_1
    bytes[] memory unsignedFillCalls = new bytes[](1);
    uint[] memory ids = new uint[](4);
    ids[0] = 5268;
    ids[1] = 4631;
    ids[2] = 3989;
    ids[3] = 1170;
    IdsProof memory idsProof = EMPTY_IDS_PROOF;
    idsProof.ids = ids;
    unsignedFillCalls[0] = abi.encode(
      address(filler),
      4,
      EMPTY_IDS_PROOF,
      idsProof,
      Call(
        address(filler),
        abi.encodeWithSelector(filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, ids)
      )
    );

    uint nftBuyCost_4 = buyCost(4);
    uint nftSellCost_1 = sellCost(1);
    assertEq(nftBuyCost_4, 38 * 10**17); // 3.8 ETH
    assertEq(nftSellCost_1, 125 * 10**16); // 1.25 ETH

    startBalances(address(filler));
    startBalances(TRADER_1);
    strategyTarget.execute(
      strategy,
      UnsignedData(
        0, // the "buy" NFT order (limitSwapExactOutput)
        unsignedFillCalls
      )
    );
    endBalances(address(filler));
    endBalances(TRADER_1);
    assertEq(diffBalance(WETH, TRADER_1), -int(nftBuyCost_4));           // paid 3.8 ETH
    assertEq(diffBalance(WETH, address(filler)), int(nftBuyCost_4));
    assertEq(diffBalance(DOODLES, TRADER_1), 4);                          // received 4 DOODLES
    assertEq(diffBalance(DOODLES, address(filler)), -4);

    uint nftBuyCost = buyCost(1);
    uint nftSellCost = sellCost(1);
    assertEq(nftBuyCost, 0); // NO MORE BUYS
    assertEq(nftSellCost, 85 * 10**16); // 0.85 ETH
  }

  function buyCost (uint nftAmount) public returns (uint cost) {
    cost = limitSwapExactOutput_loadInput(
      address(strategyTarget),
      nftAmount,
      nftTotal,
      linearPriceCurve,
      nftBuyCurveParams,
      nftBuyFillStateParams
    );
  }

  function sellCost (uint nftAmount) public returns (uint cost) {
    cost = limitSwapExactInput_loadOutput(
      address(strategyTarget),
      nftAmount,
      nftTotal,
      linearPriceCurve,
      nftSellCurveParams,
      nftSellFillStateParams
    );
  }

}
