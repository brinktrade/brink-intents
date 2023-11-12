// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract IntentTarget01_execute_invertedNftIntents is Test, Helper  {

  /*
    tests for an inverted NFT market making (aka "range intent"):

    Market make 6 DOODLE's, from range from 0.8 ETH -> 1.3 ETH, w/ spread fee of 0.05 ETH,
    Assume current "floor" is 1.2, so start with buy side at 1.1 ETH, and sell side at 1.25 ETH 

    intent_0: limitSwapExactOutput linearCurve(1.3 ETH -> 0.8 ETH) -> 6 DOODLES, start at 1.1 ETH -> 1 DOODLES
    intent_1: limitSwapExactInput 6 DOODLES -> linearCurve(0.85 ETH -> 1.35 ETH), start at 1 DOODLES -> 1.25 ETH
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

  function createInvertedNftIntent () public returns (Declaration memory declaration) {      
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

      // setup the "buy" NFT intent
      Segment[] memory segments_intent0 = new Segment[](1);
      segments_intent0[0] = Segment(
        abi.encodeWithSelector(
          Segments01.limitSwapExactOutput.selector,
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

      // setup the "sell" NFT intent
      Segment[] memory segments_intent1 = new Segment[](1);
      segments_intent1[0] = Segment(
        abi.encodeWithSelector(
          Segments01.limitSwapExactInput.selector,
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

      Intent[] memory intents = new Intent[](2);
      intents[0] = Intent(segments_intent0);
      intents[1] = Intent(segments_intent1);

      declaration = Declaration(
        address(segments),
        intents,
        new bytes[](0),
        new bytes[](0)
      );
    }

    // approve max ETH needed for the declared intents, and approvalAll DOODLES
    vm.prank(TRADER_1);
    WETH_ERC20.approve(address(intentTarget), ethTotal);
    vm.prank(TRADER_1);
    DOODLES_ERC721.setApprovalForAll(address(intentTarget), true);
  }

  // sell 1 DOODLE to TRADER_1, then buy the DOODLE from TRADER_1.
  // TRADER_1 should profit exactly 0.05 ETH, and buy/sell prices should go back to the originals
  function testExecute_invertedNftIntents_fill1Buy_then_fill1Sell () public {
    Declaration memory declaration = createInvertedNftIntent();

    uint TRADER_1_initialBalance = WETH_ERC20.balanceOf(TRADER_1);

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
    intentTarget.execute(
      declaration,
      UnsignedData(
        0, // the "buy" NFT intent (limitSwapExactOutput)
        unsignedFillCalls
      )
    );
    endBalances(address(filler));
    endBalances(TRADER_1);
    assertEq(diffBalance(WETH, TRADER_1), -int(nftBuyCost));          // paid 1.1 ETH
    assertEq(diffBalance(WETH, address(filler)), int(nftBuyCost));
    assertEq(diffBalance(DOODLES, TRADER_1), 1);                      // received 1 DOODLES
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
    intentTarget.execute(
      declaration,
      UnsignedData(
        1, // the "sell" NFT intent (limitSwapExactInput)
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

    // TRADER_1 should profit exactly 0.05 ETH
    uint TRADER_1_finalBalance = WETH_ERC20.balanceOf(TRADER_1);
    assertEq(TRADER_1_finalBalance - TRADER_1_initialBalance, 5 * 10**16); // 0.05 ETH
  }

  // fill all 4 NFT "buy" intents for TRADER_1
  // TRADER_1 should pay exactly 3.8 ETH (1.1 ETH + 1.0 ETH + 0.9 ETH + 0.8 ETH) and receive 4 DOODLES
  // buy cost should go to zero (no more buys), sell cost should go to min of 0.85 ETH
  function testExecute_invertedNftIntents_fillAllBuys () public {
    Declaration memory declaration = createInvertedNftIntent();
    
    // fill all NFT "buy" intents for TRADER_1
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
    intentTarget.execute(
      declaration,
      UnsignedData(
        0, // the "buy" NFT intent (limitSwapExactOutput)
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

  // fill all 2 NFT "sell" intents for TRADER_1
  // TRADER_1 should pay exactly 2.6 ETH (1.25 ETH + 1.35 ETH) and receive 2 DOODLES
  // sell cost should go to 0 (no more sells), buy cost should go to max of 1.3 ETH
  function testExecute_invertedNftIntents_fillAllSells () public {
    Declaration memory declaration = createInvertedNftIntent();
    
    // fill all NFT "sell" intents for TRADER_1
    bytes[] memory unsignedFillCalls = new bytes[](1);
    uint[] memory ids = new uint[](2);
    ids[0] = 3643;
    ids[1] = 3206;
    IdsProof memory idsProof = EMPTY_IDS_PROOF;
    idsProof.ids = ids;

    uint nftBuyCost_1 = buyCost(1);
    uint nftSellCost_1 = sellCost(1);
    uint nftSellCost_2 = sellCost(2);
    assertEq(nftBuyCost_1, 11 * 10**17); // 1.1 ETH
    assertEq(nftSellCost_1, 125 * 10**16); // 1.25 ETH
    assertEq(nftSellCost_2, 26 * 10**17); // 2.6 (1.25 + 1.35) ETH

    unsignedFillCalls[0] = abi.encode(
      address(filler),
      2,
      idsProof,
      EMPTY_IDS_PROOF,
      Call(
        address(filler),
        abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, nftSellCost_2, new bytes(0))
      )
    );

    startBalances(address(filler));
    startBalances(TRADER_1);
    intentTarget.execute(
      declaration,
      UnsignedData(
        1, // the "sell" NFT intent (limitSwapExactInput)
        unsignedFillCalls
      )
    );
    endBalances(address(filler));
    endBalances(TRADER_1);
    assertEq(diffBalance(DOODLES, TRADER_1), -2);                         // sold 2 DOODLES
    assertEq(diffBalance(DOODLES, address(filler)), 2);
    assertEq(diffBalance(WETH, TRADER_1), int(nftSellCost_2));           // received 2.6 ETH
    assertEq(diffBalance(WETH, address(filler)), -int(nftSellCost_2));

    nftBuyCost_1 = buyCost(1);
    nftSellCost_1 = sellCost(1);
    assertEq(nftBuyCost_1, 13 * 10**17); // 1.3 ETH
    assertEq(nftSellCost_1, 0); // NO MORE SELLS
  }

  function testExecute_invertedNftIntents_fillAllSells_then_fillAllBuys_then_sellBackToOriginal () public {
    Declaration memory declaration = createInvertedNftIntent();

    uint TRADER_1_initialBalance = WETH_ERC20.balanceOf(TRADER_1);
    
    // fill all 2 NFT "sell" intents for TRADER_1
    bytes[] memory unsignedFillCalls = new bytes[](1);
    uint[] memory ids = new uint[](2);
    ids[0] = 3643;
    ids[1] = 3206;
    IdsProof memory idsProof = EMPTY_IDS_PROOF;
    idsProof.ids = ids;

    uint nftBuyCost_1 = buyCost(1);
    uint nftSellCost_1 = sellCost(1);
    uint nftSellCost_2 = sellCost(2);
    assertEq(nftBuyCost_1, 11 * 10**17); // 1.1 ETH
    assertEq(nftSellCost_1, 125 * 10**16); // 1.25 ETH
    assertEq(nftSellCost_2, 26 * 10**17); // 2.6 (1.25 + 1.35) ETH

    unsignedFillCalls[0] = abi.encode(
      address(filler),
      2,
      idsProof,
      EMPTY_IDS_PROOF,
      Call(
        address(filler),
        abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, nftSellCost_2, new bytes(0))
      )
    );

    startBalances(address(filler));
    startBalances(TRADER_1);
    intentTarget.execute(
      declaration,
      UnsignedData(
        1, // the "sell" NFT intent (limitSwapExactInput)
        unsignedFillCalls
      )
    );
    endBalances(address(filler));
    endBalances(TRADER_1);
    assertEq(diffBalance(DOODLES, TRADER_1), -2);                         // sold 2 DOODLES
    assertEq(diffBalance(DOODLES, address(filler)), 2);
    assertEq(diffBalance(WETH, TRADER_1), int(nftSellCost_2));           // received 2.6 ETH
    assertEq(diffBalance(WETH, address(filler)), -int(nftSellCost_2));

    nftBuyCost_1 = buyCost(1);
    nftSellCost_1 = sellCost(1);
    assertEq(nftBuyCost_1, 13 * 10**17); // 1.3 ETH
    assertEq(nftSellCost_1, 0); // NO MORE SELLS

    // fill all 6 "buy" intents for TRADER_1
    ids = new uint[](6);
    ids[0] = 3643;
    ids[1] = 3206;
    ids[2] = 5268;
    ids[3] = 4631;
    ids[4] = 3989;
    ids[5] = 1170;
    idsProof.ids = ids;
    unsignedFillCalls[0] = abi.encode(
      address(filler),
      6,
      EMPTY_IDS_PROOF,
      idsProof,
      Call(
        address(filler),
        abi.encodeWithSelector(filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, ids)
      )
    );

    uint nftBuyCost_6 = buyCost(6);
    assertEq(nftBuyCost_6, 63 * 10**17); // 6.3 ETH

    startBalances(address(filler));
    startBalances(TRADER_1);
    intentTarget.execute(
      declaration,
      UnsignedData(
        0, // the "buy" NFT intent (limitSwapExactOutput)
        unsignedFillCalls
      )
    );
    endBalances(address(filler));
    endBalances(TRADER_1);
    assertEq(diffBalance(WETH, TRADER_1), -int(nftBuyCost_6));           // paid 6.3 ETH
    assertEq(diffBalance(WETH, address(filler)), int(nftBuyCost_6));
    assertEq(diffBalance(DOODLES, TRADER_1), 6);                         // received 6 DOODLES
    assertEq(diffBalance(DOODLES, address(filler)), -6);

    nftBuyCost_1 = buyCost(1);
    nftSellCost_1 = sellCost(1);
    assertEq(nftBuyCost_1, 0); // NO MORE BUYS
    assertEq(nftSellCost_1, 85 * 10**16); // 0.85 ETH

    // fill 4 "sell" intents for TRADER_1 to put the curve back to it's original state
    uint nftSellCost_4 = sellCost(4);
    assertEq(nftSellCost_4, 4 * 10**18); // 4.0 ETH

    ids = new uint[](4);
    ids[0] = 5268;
    ids[1] = 3989;
    ids[2] = 1170;
    ids[3] = 3206;
    idsProof.ids = ids;
    unsignedFillCalls[0] = abi.encode(
      address(filler),
      4,
      idsProof,
      EMPTY_IDS_PROOF,
      Call(
        address(filler),
        abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, nftSellCost_4, new bytes(0))
      )
    );

    startBalances(address(filler));
    startBalances(TRADER_1);
    intentTarget.execute(
      declaration,
      UnsignedData(
        1, // the "sell" NFT intent (limitSwapExactInput)
        unsignedFillCalls
      )
    );
    endBalances(address(filler));
    endBalances(TRADER_1);
    assertEq(diffBalance(DOODLES, TRADER_1), -4);                        // sold 4 DOODLES
    assertEq(diffBalance(DOODLES, address(filler)), 4);
    assertEq(diffBalance(WETH, TRADER_1), int(nftSellCost_4));           // received 4.0 ETH
    assertEq(diffBalance(WETH, address(filler)), -int(nftSellCost_4));

    // back to original prices
    nftBuyCost_1 = buyCost(1);
    nftSellCost_1 = sellCost(1);
    assertEq(nftBuyCost_1, 11 * 10**17); // 1.1 ETH
    assertEq(nftSellCost_1, 125 * 10**16); // 1.25 ETH

    // TRADER_1 should profit exactly 0.3 ETH
    uint TRADER_1_finalBalance = WETH_ERC20.balanceOf(TRADER_1);
    assertEq(TRADER_1_finalBalance - TRADER_1_initialBalance, 3 * 10**17); // 0.3 ETH
  }

  function buyCost (uint nftAmount) public returns (uint cost) {
    cost = limitSwapExactOutput_loadInput(
      address(intentTarget),
      nftAmount,
      nftTotal,
      linearPriceCurve,
      nftBuyCurveParams,
      nftBuyFillStateParams
    );
  }

  function sellCost (uint nftAmount) public returns (uint cost) {
    cost = limitSwapExactInput_loadOutput(
      address(intentTarget),
      nftAmount,
      nftTotal,
      linearPriceCurve,
      nftSellCurveParams,
      nftSellFillStateParams
    );
  }

}
