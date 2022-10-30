// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.10;
pragma abicoder v1;

import "../TokenHelper/TokenHelper.sol";

contract Primatives01 is TokenHelper {

  error NftIdAlreadyOwned();
  error NftIdNotReceived();
  error NotEnoughTokenReceived();

  struct UnsignedTransferData {
    address recipient;
    IdMerkleProof[] idMerkleProofs;
  }

  struct UnsignedLimitSwapData {
    address recipient;
    uint tokenInAmount;
    uint tokenInId;
    IdMerkleProof[] tokenInIdMerkleProofs;
    Call fillCall;
  }

  struct Call {
    address targetContract;
    bytes data;
  }

  // require bitmapIndex/bit not to be used
  function requireBitNotUsed (uint bitmapIndex, uint bit) external {

  }

  // require bitmapIndex/bit to be used
  function requireBitUsed (uint bitmapIndex, uint bit) external {

  }

  // set bitmapIndex/bit to used. Requires bit not to be used
  function useBit (uint bitmapIndex, uint bit) external {
    
  }

  // require block <= current block
  function requireBlockMined (uint block) external {

  }

  // require block > current block
  function requireBlockNotMined (uint block) external {

  }

  // increment on each successful run, revert when maxRuns exceeded
  function maxRuns (bytes32 id, uint numberOfRuns) external {

  }

  // allows a run every n blocks, revert if last run was less than n blocks ago
  function requireBlocksElapsed (bytes32 id, uint numberOfBlocksElapsed) external {

  }

  // require priceOracle.price(A, B) <= value
  function requirePriceLowerBound (IPriceOracle priceOracle, Token tokenA, Token tokenB, uint value) external {

  }

  // require priceOracle.price(A, B) >= value
  function requirePriceUpperBound (IPriceOracle priceOracle, Token tokenA, Token tokenB, uint value) external {

  }

  // require priceDeltaOracle.priceDelta(A, B, duration) <= value * -1 AND require currentTime - startTime >= duration
  function requirePriceDecrease (IPriceDeltaOracle priceDeltaOracle, Token tokenA, Token tokenB, uint startTime, uint duration, uint value) {

  }

  // require priceDeltaOracle.priceDelta(A, B, duration) >= value AND require currentTime - startTime >= duration
  function requirePriceIncrease (IPriceDeltaOracle priceDeltaOracle, Token tokenA, Token tokenB, uint startTime, uint duration, uint value) {

  }

  function transfer (
    Token token,
    address owner,
    address recipient,
    uint amount,
    uint id,
    UnsignedTransferData data
  ) external {
    _checkUnsignedTransferData(token, amount, data);
    address _recipient = recipient != address(0) ? recipient : data.recipient
    transferFrom(token, owner, _recipient, amount, id, data.idMerkleProofs);
  }

  // given an exact tokenIn amount, fill a tokenIn -> tokenOut swap at market price, as determined by priceOracle
  function marketSwapExactInput (
    IPriceOracle priceOracle,
    address owner,
    Token tokenIn,
    Token tokenOut,
    uint tokenInAmount,
    UnsignedMarketSwapData data
  ) external {
    uint tokenOutAmountRequired = _getMarketOutput(priceOracle, tokenIn, tokenOut, tokenInAmount);
    _fillSwap(
      tokenIn,
      tokenOut,
      owner,
      data.recipient,
      tokenInAmount,
      tokenOutAmountRequired,
      data.tokenInId,
      data.tokenInIdMerkleProofs,
      data.tokenOutIdMerkleProofs,
      data.fillCall
    );
  }

  // given an exact tokenOut amount, fill a tokenIn -> tokenOut swap at market price, as determined by priceOracle
  function marketSwapExactOutput (
    IPriceOracle priceOracle,
    address owner,
    Token tokenIn,
    Token tokenOut,
    uint tokenOutAmount,
    UnsignedMarketSwapData data
  ) external {
    uint tokenInAmountRequired = _getMarketInput(priceOracle, tokenIn, tokenOut, tokenOutAmount);
    _fillSwap(
      tokenIn,
      tokenOut,
      owner,
      data.recipient,
      tokenInAmountRequired,
      tokenOutAmount,
      data.tokenInId,
      data.tokenInIdMerkleProofs,
      data.tokenOutIdMerkleProofs,
      data.fillCall
    );
  }

  // fill all or part of a swap for tokenIn -> tokenOut. Price curve calculates output based on input
  function limitSwap (
    bytes32 id,
    address owner,
    Token tokenIn,
    Token tokenOut,
    uint tokenInAmount,
    uint basePrice,
    IPriceCurve priceCurve,
    UnsignedLimitSwapData data
  ) {
    _checkUnsignedLimitSwapData(tokenIn, data);

    // TODO: state resolution for tokenInAmount and basePrice modification

    // get amount of output already filled. for a new limitSwap this will be 0
    uint outputFilled = _getLimitSwapOutputFilled(id);

    // get the amount of tokenOut required for the requested tokenIn amount
    uint tokenOutAmountRequired = priceCurve.getOutput(tokenInAmount, basePrice, outputFilled, data.tokenInAmount);

    _fillSwap(
      tokenIn,
      tokenOut,
      owner,
      data.recipient,
      data.tokenInAmount,
      tokenOutAmountRequired,
      data.tokenInId,
      data.tokenInIdMerkleProofs,
      data.fillCall
    );

    _updateLimitSwapOutputFilled(id, tokenOutAmountRequired);
  }

  // revert if limit swap is not open
  function requireLimitSwapOpen(bytes32 id) external {

  }

  // revert if limit swap is not filled
  function requireLimitSwapFilled(bytes32 id) external {

  }

  // invert the allowed swap amount states between two limit swaps.
  // if swap0 fill amount decreases, increase fill amount for swap1 by the same amount.
  // Should be used for swaps with opposite pairs, i.e. A->B and B->A
  function invertLimitSwapFills (bytes32 swap0, bytes32 swap1) external {
    
  }

  // binds the fill amounts of multiple swaps together, such that if one swap is filled, the other swaps will be set to the same fill amount.
  // Should be used for swaps with the same pairs, i.e. A->B and A->B
  function bindLimitSwapFills (bytes32[] swapsIds) external {
    
  }

  // auction tokenA in a dutch auction where price decreases until tokenA is swapped for tokenB.
  // incentivizes initialization of the auction with initializerFee
  function dutchAuction (bytes32 id, Token tokenA, Token tokenB, uint startPrice, uint endPrice, uint duration, address initializer, uint initializerReward) external {

  }

  // revert if dutch auction is not started
  function requireDutchAuctionNotStarted (bytes32 id) external {

  }

  // revert if dutch auction is not open
  function requireDutchAuctionOpen (bytes32 id) external {

  }

  // revert if dutch auction is not complete
  function requireDutchAuctionComplete (bytes32 id) external {

  }

  // execute a dutch auction buy order
  function dutchAuctionBuy (bytes32 id, uint inputAmount) external {

  }

  // create a seaport listing
  function createSeaportListing (bytes32 id) external {

  }

  function _checkUnsignedLimitSwapData (Token token, UnsignedLimitSwapData unsignedData) private {
    if (
      token.idsMerkleRoot == bytes32(0) &&
      token.id != 0 &&
      token.id != unsignedData.tokenInId
    ) {
      revert IdNotAllowed();
    }

    if (token.idsMerkleRoot != bytes32(0)) {
      if (unsignedData.tokenInIdMerkleProofs.length == 0) {
        revert MerkleProofsRequired();
      }
      if (unsignedData.tokenInIdMerkleProofs.length != unsignedData.tokenInAmount) {
        revert MerkleProofAndAmountMismatch()
      }

      // TODO: revert on duplicate merkle proof ids!!!!
    }
  }

  function _checkUnsignedTransferData (Token token, uint amount, UnsignedTransferData unsignedData) private {
    if (token.idsMerkleRoot != bytes32(0) && unsignedData.idMerkleProofs.length != amount) {
      revert MerkleProofAndAmountMismatch();
    }
  }

  function _fillSwap (
    Token tokenIn,
    Token tokenOut,
    address owner,
    address recipient,
    uint tokenInAmount,
    uint tokenOutAmount,
    uint tokenInId,
    IdMerkleProof[] tokenInIdMerkleProofs,
    IdMerkleProof[] tokenOutIdMerkleProofs,
    Call fillCall
  ) private {
    transferFrom(tokenIn, owner, recipient, tokenInAmount, tokenInId, tokenInIdMerkleProofs);

    (uint initialTokenOutBalance, uint initialOwnedIdCount) = checkTokenOwnership(owner, tokenOut, tokenOutIdMerkleProofs);
    if (initialOwnedIdCount > 0) {
      revert NftIdAlreadyOwned();
    }

    CALL_EXECUTOR_V2.proxyCall(fillCall.targetContract, fillCall.data);

    (uint finalTokenOutBalance, uint finalOwnedIdCount) = checkTokenOwnership(owner, tokenOut, tokenOutIdMerkleProofs);

    if (
      (token.id > 0 && finalOwnedIdCount < 1) ||
      (token.idsMerkleRoot != bytes(0) && finalOwnedIdCount < tokenOutIdMerkleProofs.length)
    ) {
      revert NftIdNotReceived();
    } else {
      uint256 tokenOutAmountReceived = finalTokenOutBalance - initialTokenOutBalance;
      if (tokenOutAmountReceived < tokenOutAmount) {
        revert NotEnoughTokenReceived(tokenOutAmountReceived);
      }
    }
  }

  function _updateLimitSwapOutputFilled(bytes32 id, uint newOutputFilled) private {
    // TODO: implement
  }

  function _getMarketOutput (IPriceOracle priceOracle, Token tokenIn, Token tokenOut, uint tokenInAmount) private returns (uint outputAmount) {
    // TODO: implement
  }

  function _getMarketInput (IPriceOracle priceOracle, Token tokenIn, Token tokenOut, uint tokenOutAmount) private returns (uint inputAmount) {
    // TODO: implement
  }

}
