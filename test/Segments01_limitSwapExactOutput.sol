// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";

contract Segments01_limitSwapExactOutput is Test, Helper  {

  using Math for uint;

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
  }

  function testLimitSwapExactOutput_full () public {
    bytes memory curveParams;
    uint nftTotalOutput = 3;

    {
      // setup linear price curve for 3 NFT's, with prices of 0.5 ETH, 0.4 ETH, and 0.3 ETH (total "output" should be 1.2 ETH).
      // the curve is inverted by the limitSwapExactOutput function, so the output is NFT and input is ETH
      uint NFT_ETH_p0_X96 = 5 * Q96 * 10**17; // 0.5 ETH
      uint NFT_ETH_p1_X96 = 3 * Q96 * 10**17; // 0.3 ETH
      curveParams = linearPriceCurve.calcCurveParams(
        abi.encode(int(nftTotalOutput), int(NFT_ETH_p0_X96), int(NFT_ETH_p1_X96))
      );
    }

    // "calcOutput" calcs the weth input based on NFT output, since the curve will be inverted
    uint wethTotalInput = linearPriceCurve.calcOutput(nftTotalOutput, curveParams);

    vm.prank(TRADER_1);
    WETH_ERC20.approve(address(segments), wethTotalInput);

    bytes memory fillCall;
    {
      uint[] memory doodleIds = new uint[](3);
      doodleIds[0] = 5268;
      doodleIds[1] = 4631;
      doodleIds[2] = 3989;
      fillCall = abi.encodeWithSelector(
        filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, doodleIds
      );
    }

    IdsProof memory doodleIdsProof = EMPTY_IDS_PROOF;
    doodleIdsProof.ids = new uint[](3);
    doodleIdsProof.ids[0] = 5268;
    doodleIdsProof.ids[1] = 4631;
    doodleIdsProof.ids[2] = 3989;

    assertEq(limitSwap_loadFilledAmount(address(segments), DEFAULT_FILL_STATE_PARAMS, nftTotalOutput), 0);
    startBalances(address(filler));
    startBalances(TRADER_1);

    segments.limitSwapExactOutput(
      TRADER_1,
      WETH_Token,
      DOODLES_Token,
      nftTotalOutput,
      linearPriceCurve,
      curveParams,
      DEFAULT_FILL_STATE_PARAMS,
      UnsignedLimitSwapData(
        address(filler),
        nftTotalOutput,
        EMPTY_IDS_PROOF,
        doodleIdsProof,
        Call(address(filler), fillCall)
      )
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(limitSwap_loadFilledAmount(address(segments), DEFAULT_FILL_STATE_PARAMS, nftTotalOutput), nftTotalOutput);
    
    assertEq(diffBalance(WETH, TRADER_1), -int(wethTotalInput));
    assertEq(diffBalance(WETH, address(filler)), int(wethTotalInput));
    assertEq(diffBalance(DOODLES, TRADER_1), int(nftTotalOutput));
    assertEq(diffBalance(DOODLES, address(filler)), -int(nftTotalOutput));
  }

  function testLimitSwapExactOutput_partial () public {
    bytes memory curveParams;
    uint nftTotalOutput = 3;
    uint nftPartialOutput = 2;

    {
      // setup linear price curve for 3 NFT's, with prices of 0.5 ETH, 0.4 ETH, and 0.3 ETH (total "output" should be 1.2 ETH).
      // the curve is inverted by the limitSwapExactOutput function, so the output is NFT and input is ETH
      uint NFT_ETH_p0_X96 = 5 * Q96 * 10**17; // 0.5 ETH
      uint NFT_ETH_p1_X96 = 3 * Q96 * 10**17; // 0.3 ETH
      curveParams = linearPriceCurve.calcCurveParams(
        abi.encode(int(nftTotalOutput), int(NFT_ETH_p0_X96), int(NFT_ETH_p1_X96))
      );
    }

    // "calcOutput" calcs the weth input based on 2 out of 3 NFT output
    uint wethPartialInput = linearPriceCurve.calcOutput(nftPartialOutput, curveParams);

    vm.prank(TRADER_1);
    WETH_ERC20.approve(address(segments), wethPartialInput);

    bytes memory fillCall;
    {
      uint[] memory doodleIds = new uint[](2);
      doodleIds[0] = 5268;
      doodleIds[1] = 4631;
      fillCall = abi.encodeWithSelector(
        filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, doodleIds
      );
    }

    IdsProof memory doodleIdsProof = EMPTY_IDS_PROOF;
    doodleIdsProof.ids = new uint[](2);
    doodleIdsProof.ids[0] = 5268;
    doodleIdsProof.ids[1] = 4631;

    assertEq(limitSwap_loadFilledAmount(address(segments), DEFAULT_FILL_STATE_PARAMS, nftTotalOutput), 0);
    startBalances(address(filler));
    startBalances(TRADER_1);

    segments.limitSwapExactOutput(
      TRADER_1,
      WETH_Token,
      DOODLES_Token,
      nftTotalOutput,
      linearPriceCurve,
      curveParams,
      DEFAULT_FILL_STATE_PARAMS,
      UnsignedLimitSwapData(
        address(filler),
        nftPartialOutput,
        EMPTY_IDS_PROOF,
        doodleIdsProof,
        Call(address(filler), fillCall)
      )
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    // expect fill percent to be 2/3, so fill amount when given total NFT output of 3 should return 2
    assertEq(limitSwap_loadFilledAmount(address(segments), DEFAULT_FILL_STATE_PARAMS, nftTotalOutput), nftPartialOutput);
    
    // trader should have wethPartialInput less WETH
    assertEq(diffBalance(WETH, TRADER_1), -int(wethPartialInput));
    assertEq(diffBalance(WETH, address(filler)), int(wethPartialInput));

    // TRADER_1 should have 2 more NFT's
    assertEq(diffBalance(DOODLES, TRADER_1), int(nftPartialOutput));
    assertEq(diffBalance(DOODLES, address(filler)), -int(nftPartialOutput));
  }

}
