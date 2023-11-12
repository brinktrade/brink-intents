// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract Segments01_fillSwap is Test, Helper  {

  function setUp () public {
    setupAll(BLOCK_FEB_12_2023);
    setupFiller();
    setupTrader1();
  }

  // erc20 to erc20 swap
  function testFillSwap_erc20 () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 1450_000000);

    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, 1_000000000000000000, new uint[](0));

    startBalances(address(filler));
    startBalances(TRADER_1);

    segmentInternals.fillSwap(
      USDC_Token,
      WETH_Token,
      TRADER_1,
      address(filler),
      1450_000000,
      1_000000000000000000,
      EMPTY_IDS_PROOF,
      EMPTY_IDS_PROOF,
      Call(address(filler), fillCall)
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), -1450_000000);
    assertEq(diffBalance(USDC, address(filler)), 1450_000000);
    assertEq(diffBalance(WETH, TRADER_1), 1_000000000000000000);
    assertEq(diffBalance(WETH, address(filler)), -1_000000000000000000);
  }

  // erc721 (any id) to erc20 swap
  function testFillSwap_erc721_anyIds_in () public {
    vm.prank(TRADER_1);
    DOODLES_ERC721.setApprovalForAll(address(segmentInternals), true);

    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, USDC, TokenStandard.ERC20, TRADER_1, 500_000000, new uint[](0));

    uint[] memory ids = new uint[](2);
    ids[0] = 3643;
    ids[1] = 3206;
    IdsProof memory inIds = EMPTY_IDS_PROOF;
    inIds.ids = ids;

    startBalances(address(filler));
    startBalances(TRADER_1);

    segmentInternals.fillSwap(
      DOODLES_Token,
      USDC_Token,
      TRADER_1,
      address(filler),
      2,
      500_000000,
      inIds,
      EMPTY_IDS_PROOF,
      Call(address(filler), fillCall)
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), 500_000000);
    assertEq(diffBalance(USDC, address(filler)), -500_000000);
    assertEq(diffBalance(DOODLES, TRADER_1), -2);
    assertEq(diffBalance(DOODLES, 3643, TRADER_1), -1);
    assertEq(diffBalance(DOODLES, 3206, TRADER_1), -1);
    assertEq(diffBalance(DOODLES, address(filler)), 2);
    assertEq(diffBalance(DOODLES, 3643, address(filler)), 1);
    assertEq(diffBalance(DOODLES, 3206, address(filler)), 1);
  }

  // erc20 to erc721 (any id) swap
  function testFillSwap_erc721_anyIds_out () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 500_000000);

    uint[] memory ids = new uint[](2);
    ids[0] = 5268;
    ids[1] = 4631;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, ids);

    IdsProof memory outIds = EMPTY_IDS_PROOF;
    outIds.ids = ids;

    startBalances(address(filler));
    startBalances(TRADER_1);

    segmentInternals.fillSwap(
      USDC_Token,
      DOODLES_Token,
      TRADER_1,
      address(filler),
      500_000000,
      2,
      EMPTY_IDS_PROOF,
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

  // erc721 (merkle root ids) to erc20 swap
  function testFillSwap_erc721_merkleIds_in () public {
    vm.prank(TRADER_1);
    DOODLES_ERC721.setApprovalForAll(address(segmentInternals), true);

    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, USDC, TokenStandard.ERC20, TRADER_1, 500_000000, new uint[](0));

    (,IdsProof memory idsIn) = doodlesProof_3643();

    startBalances(address(filler));
    startBalances(TRADER_1);

    segmentInternals.fillSwap(
      DOODLES_Token_5268_4631_3643,
      USDC_Token,
      TRADER_1,
      address(filler),
      1,
      500_000000,
      idsIn,
      EMPTY_IDS_PROOF,
      Call(address(filler), fillCall)
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), 500_000000);
    assertEq(diffBalance(USDC, address(filler)), -500_000000);
    assertEq(diffBalance(DOODLES, TRADER_1), -1);
    assertEq(diffBalance(DOODLES, 3643, TRADER_1), -1);
    assertEq(diffBalance(DOODLES, address(filler)), 1);
    assertEq(diffBalance(DOODLES, 3643, address(filler)), 1);
  }

  // erc20 to erc721 (merkle root ids) swap
  function testFillSwap_erc721_merkleIds_out () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 500_000000);

    uint[] memory ids = new uint[](2);
    ids[0] = 5268;
    ids[1] = 4631;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, ids);

    (,IdsProof memory outIds) = doodlesProof_5268_4631();

    startBalances(address(filler));
    startBalances(TRADER_1);

    segmentInternals.fillSwap(
      USDC_Token,
      DOODLES_Token_5268_4631_3643,
      TRADER_1,
      address(filler),
      500_000000,
      2,
      EMPTY_IDS_PROOF,
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

  // erc20 to erc1155 (specific id)
  function testFillSwap_erc1155_specificId () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 500_000000);

    uint[] memory ids = new uint[](1);
    ids[0] = 14;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, THE_MEMES, TokenStandard.ERC1155, TRADER_1, 3, ids);

    IdsProof memory outIds = EMPTY_IDS_PROOF;
    outIds.ids = ids;

    startBalances(address(filler));
    startBalances(TRADER_1);

    segmentInternals.fillSwap(
      USDC_Token,
      THE_MEMES_GMGM_Token, // accept only id=14
      TRADER_1,
      address(filler),
      60_000000,
      3,
      EMPTY_IDS_PROOF,
      outIds,
      Call(address(filler), fillCall)
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), -60_000000);
    assertEq(diffBalance(USDC, address(filler)), 60_000000);
    assertEq(diffBalance(THE_MEMES, 14, TRADER_1), 3);
    assertEq(diffBalance(THE_MEMES, 14, address(filler)), -3);
  }

  // erc20 to erc1155 (any id)
  function testFillSwap_erc1155_anyId () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 500_000000);

    // fill with +1 of id=8 and +1 of id=14
    uint[] memory ids = new uint[](2);
    ids[0] = 8;
    ids[1] = 14;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, THE_MEMES, TokenStandard.ERC1155, TRADER_1, 0, ids);

    IdsProof memory outIds = EMPTY_IDS_PROOF;
    outIds.ids = ids;

    startBalances(address(filler));
    startBalances(TRADER_1);

    segmentInternals.fillSwap(
      USDC_Token,
      THE_MEMES_Token,
      TRADER_1,
      address(filler),
      60_000000,
      2,
      EMPTY_IDS_PROOF,
      outIds,
      Call(address(filler), fillCall)
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), -60_000000);
    assertEq(diffBalance(USDC, address(filler)), 60_000000);
    assertEq(diffBalance(THE_MEMES, 8, TRADER_1), 1);
    assertEq(diffBalance(THE_MEMES, 8, address(filler)), -1);
    assertEq(diffBalance(THE_MEMES, 14, TRADER_1), 1);
    assertEq(diffBalance(THE_MEMES, 14, address(filler)), -1);
  }

  // erc20 to erc1155 (merkle root ids)
  function testFillSwap_erc1155_merkleRootIds () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 500_000000);

    uint[] memory ids = new uint[](1);
    ids[0] = 8;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, THE_MEMES, TokenStandard.ERC1155, TRADER_1, 2, ids);

    (,IdsProof memory outIds) = proof_8();

    startBalances(address(filler));
    startBalances(TRADER_1);

    segmentInternals.fillSwap(
      USDC_Token,
      THE_MEMES_Token_8_14_64,
      TRADER_1,
      address(filler),
      60_000000,
      2,
      EMPTY_IDS_PROOF,
      outIds,
      Call(address(filler), fillCall)
    );

    endBalances(address(filler));
    endBalances(TRADER_1);

    assertEq(diffBalance(USDC, TRADER_1), -60_000000);
    assertEq(diffBalance(USDC, address(filler)), 60_000000);
    assertEq(diffBalance(THE_MEMES, 8, TRADER_1), 2);
    assertEq(diffBalance(THE_MEMES, 8, address(filler)), -2);
  }

  // InvalidMerkleProof() error
  function testFillSwap_InvalidMerkleProof_tokenIn () public {
    (,IdsProof memory idsIn) = doodlesProof_3643();
    idsIn.ids[0] = 1111;

    vm.expectRevert(InvalidMerkleProof.selector);
    segmentInternals.fillSwap(
      DOODLES_Token_5268_4631_3643,
      USDC_Token,
      TRADER_1,
      address(filler),
      1,
      500_000000,
      idsIn,
      EMPTY_IDS_PROOF,
      Call(address(filler), '')
    );
  }

  // InvalidMerkleProof() error
  function testFillSwap_InvalidMerkleProof_tokenOut () public {
    (,IdsProof memory idsOut) = doodlesProof_3643();
    idsOut.ids[0] = 1111;

    vm.expectRevert(InvalidMerkleProof.selector);
    segmentInternals.fillSwap(
      USDC_Token,
      DOODLES_Token_5268_4631_3643,
      TRADER_1,
      address(filler),
      1,
      500_000000,
      EMPTY_IDS_PROOF,
      idsOut,
      Call(address(filler), '')
    );
  }

  // NftIdAlreadyOwned() error
  function testFillSwap_NftIdAlreadyOwned () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 500_000000);

    uint[] memory ids = new uint[](2);
    ids[0] = 3643; // already owned by TRADER_1
    ids[1] = 4631;

    IdsProof memory outIds = EMPTY_IDS_PROOF;
    outIds.ids = ids;

    vm.expectRevert(NftIdAlreadyOwned.selector);
    segmentInternals.fillSwap(
      USDC_Token,
      DOODLES_Token,
      TRADER_1,
      address(filler),
      500_000000,
      2,
      EMPTY_IDS_PROOF,
      outIds,
      Call(address(filler), '')
    );
  }

  // NotEnoughTokenReceived() error for ERC20
  function testFillSwap_NotEnoughTokenReceived_erc20 () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 1450_000000);

    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, WETH, TokenStandard.ERC20, TRADER_1, 1_000000000000000000, new uint[](0));

    vm.expectRevert(abi.encodeWithSelector(NotEnoughTokenReceived.selector, 1_000000000000000000));
    segmentInternals.fillSwap(
      USDC_Token,
      WETH_Token,
      TRADER_1,
      address(filler),
      1450_000000,
      2_000000000000000000, // requires 2 WETH, but fillCall only transfers 1 WETH
      EMPTY_IDS_PROOF,
      EMPTY_IDS_PROOF,
      Call(address(filler), fillCall)
    );
  }

  // NotEnoughTokenReceived() error for ERC721
  function testFillSwap_NotEnoughTokenReceived_erc721 () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 500_000000);

    uint[] memory ids = new uint[](2);
    ids[0] = 5268;
    ids[1] = 4631;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, ids);

    IdsProof memory outIds = EMPTY_IDS_PROOF;
    outIds.ids = ids;

    startBalances(address(filler));
    startBalances(TRADER_1);

    vm.expectRevert(abi.encodeWithSelector(NotEnoughTokenReceived.selector, 2));
    segmentInternals.fillSwap(
      USDC_Token,
      DOODLES_Token,
      TRADER_1,
      address(filler),
      500_000000,
      3, // requires 3 ids but fillCall only provides 2
      EMPTY_IDS_PROOF,
      outIds,
      Call(address(filler), fillCall)
    );
  }

  // NotEnoughTokenReceived() error for ERC1155
  function testFillSwap_NotEnoughTokenReceived_erc1155 () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 500_000000);

    uint[] memory ids = new uint[](2);
    ids[0] = 8;
    ids[1] = 14;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, THE_MEMES, TokenStandard.ERC1155, TRADER_1, 0, ids);

    IdsProof memory outIds = EMPTY_IDS_PROOF;
    outIds.ids = ids;

    vm.expectRevert(abi.encodeWithSelector(NotEnoughTokenReceived.selector, 2));
    segmentInternals.fillSwap(
      USDC_Token,
      THE_MEMES_Token,
      TRADER_1,
      address(filler),
      60_000000,
      3, // requires 3 ids but fillCall only provides 2
      EMPTY_IDS_PROOF,
      outIds,
      Call(address(filler), fillCall)
    );
  }

  // erc20 to erc721 (any id) swap, filler provides duplicate ids
  function testFillSwap_duplicateIdsInFillCall_erc721 () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 500_000000);

    // fill with 5268
    uint[] memory fillIds = new uint[](1);
    fillIds[0] = 5268;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, DOODLES, TokenStandard.ERC721, TRADER_1, 0, fillIds);

    // filler provides two ids, both 5268
    IdsProof memory outIds = EMPTY_IDS_PROOF;
    outIds.ids = new uint[](2);
    outIds.ids[0] = 5268;
    outIds.ids[1] = 5268;

    vm.expectRevert(DuplicateIds.selector);
    segmentInternals.fillSwap(
      USDC_Token,
      DOODLES_Token,
      TRADER_1,
      address(filler),
      500_000000,
      2,
      EMPTY_IDS_PROOF,
      outIds,
      Call(address(filler), fillCall)
    );
  }

  // erc20 to erc1155 (any id), filler provides duplicate ids
  function testFillSwap_duplicateIdsInFillCall_erc1155 () public {
    vm.prank(TRADER_1);
    USDC_ERC20.approve(address(segmentInternals), 500_000000);

    // fill with 1 of id=8
    uint[] memory ids = new uint[](2);
    ids[0] = 8;
    bytes memory fillCall = abi.encodeWithSelector(filler.fill.selector, THE_MEMES, TokenStandard.ERC1155, TRADER_1, 0, ids);

    // filler provides 2 ids, both 8
    IdsProof memory outIds = EMPTY_IDS_PROOF;
    outIds.ids = new uint[](2);
    outIds.ids[0] = 8;
    outIds.ids[1] = 8;

    startBalances(address(filler));
    startBalances(TRADER_1);

    vm.expectRevert(DuplicateIds.selector);
    segmentInternals.fillSwap(
      USDC_Token,
      THE_MEMES_Token,
      TRADER_1,
      address(filler),
      60_000000,
      2,
      EMPTY_IDS_PROOF,
      outIds,
      Call(address(filler), fillCall)
    );
  }

}
