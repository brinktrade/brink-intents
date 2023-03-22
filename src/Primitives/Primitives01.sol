// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "openzeppelin/utils/math/Math.sol";
import "openzeppelin/utils/math/SignedMath.sol";
import "../StrategyBase.sol";
import "../Interfaces/ICallExecutor.sol";
import "../Interfaces/IUint256Oracle.sol";
import "../Interfaces/IPriceCurve.sol";
import "../Libraries/Bit.sol";
import "../TokenHelper/TokenHelper.sol";

error NftIdAlreadyOwned();
error NotEnoughNftReceived();
error NotEnoughTokenReceived(uint amountReceived);
error MerkleProofAndAmountMismatch();
error BlockMined();
error BlockNotMined();
error OracleUint256ReadZero();
error Uint256LowerBoundNotMet(uint256 oraclePrice);
error Uint256UpperBoundNotMet(uint256 oraclePrice);
error InvalidTokenInIds();
error InvalidTokenOutIds();
error BitUsed();
error BitNotUsed();

struct UnsignedTransferData {
  address recipient;
  IdsProof idsProof;
}

struct UnsignedMarketSwapData {
  address recipient;
  IdsProof tokenInIdsProof;
  IdsProof tokenOutIdsProof;
  Call fillCall;
}

struct UnsignedLimitSwapData {
  address recipient;
  uint amount;
  IdsProof tokenInIdsProof;
  IdsProof tokenOutIdsProof;
  Call fillCall;
}

struct UnsignedStakeProofData {
  bytes stakerSignature;
}

contract Primitives01 is TokenHelper, StrategyBase {
  using Math for uint256;
  using SignedMath for int256;

  uint256 internal constant Q96 = 0x1000000000000000000000000;

  ICallExecutor constant CALL_EXECUTOR_V2 = ICallExecutor(0x6FE756B9C61CF7e9f11D96740B096e51B64eBf13);

  // require bitmapIndex/bit not to be used
  function requireBitNotUsed (uint bitmapIndex, uint bit) public {
    uint256 bitmap = Bit.loadUint(Bit.bitmapPtr(bitmapIndex));
    if (bitmap & bit != 0) {
      revert BitUsed();
    }
  }

  // require bitmapIndex/bit to be used
  function requireBitUsed (uint bitmapIndex, uint bit) public {
    uint256 bitmap = Bit.loadUint(Bit.bitmapPtr(bitmapIndex));
    if (bitmap & bit == 0) {
      revert BitNotUsed();
    }
  }

  // set bitmapIndex/bit to used. Requires bit not to be used
  function useBit (uint bitmapIndex, uint bit) public {
    Bit.useBit(bitmapIndex, bit);
  }

  // require block <= current block
  function requireBlockMined (uint blockNumber) public view {
    if (blockNumber > block.number) {
      revert BlockNotMined();
    }
  }

  function requireBlockNotMined (uint blockNumber) public view {
    if (blockNumber <= block.number) {
      revert BlockMined();
    }
  }

  // increment on each successful run, revert when maxRuns exceeded
  function maxRuns (bytes32 id, uint numberOfRuns) public {

  }

  // allows a run every n blocks, revert if last run was less than n blocks ago
  function requireBlocksElapsed (bytes32 id, uint numberOfBlocksElapsed) public {

  }

  // Require a lower bound uint256 returned from an oracle. Revert if oracle returns 0.
  function requireUint256LowerBound (IUint256Oracle uint256Oracle, bytes memory params, uint lowerBound) public view {
    uint256 oracleUint256 = uint256Oracle.getUint256(params);
    if (oracleUint256 == 0) {
      revert OracleUint256ReadZero();
    }
    if(oracleUint256 > lowerBound) {
      revert Uint256LowerBoundNotMet(oracleUint256);
    }
  }

  // Require an upper bound uint256 returned from an oracle
  function requireUint256UpperBound (IUint256Oracle uint256Oracle, bytes memory params, uint upperBound) public {
    uint256 oracleUint256 = uint256Oracle.getUint256(params);
    if(oracleUint256 < upperBound) {
      revert Uint256UpperBoundNotMet(oracleUint256);
    }
  }

  // requires tx sent by an executor that can prove ownership of one of the executor addresses
  function requireStake (UnsignedStakeProofData memory data) public {

  }

  function transfer (
    Token memory token,
    address owner,
    address recipient,
    uint amount,
    UnsignedTransferData memory data
  ) public {
    _checkUnsignedTransferData(token, amount, data);
    address _recipient = recipient != address(0) ? recipient : data.recipient;
    // transferFrom(token, owner, _recipient, amount, data.id, data.idsProof);
  }

  // given an exact tokenIn amount, fill a tokenIn -> tokenOut swap at market price, as determined by priceOracle
  function marketSwapExactInput (
    IUint256Oracle priceOracle,
    bytes memory priceOracleParams,
    address owner,
    Token memory tokenIn,
    Token memory tokenOut,
    uint tokenInAmount,
    uint24 feePercent,
    uint feeMinTokenOut,
    UnsignedMarketSwapData memory data
  ) public {
    _fillSwap(
      tokenIn,
      tokenOut,
      owner,
      data.recipient,
      tokenInAmount,
      getSwapAmountWithFee(priceOracle, priceOracleParams, tokenInAmount, -int24(feePercent), int(feeMinTokenOut)),
      data.tokenInIdsProof,
      data.tokenOutIdsProof,
      data.fillCall
    );
  }

  // given an exact tokenOut amount, fill a tokenIn -> tokenOut swap at market price, as determined by priceOracle
  function marketSwapExactOutput (
    IUint256Oracle priceOracle,
    bytes memory priceOracleParams,
    address owner,
    Token memory tokenIn,
    Token memory tokenOut,
    uint tokenOutAmount,
    uint24 feePercent,
    uint feeMinTokenIn,
    UnsignedMarketSwapData memory data
  ) public {
    _fillSwap(
      tokenIn,
      tokenOut,
      owner,
      data.recipient,
      getSwapAmountWithFee(priceOracle, priceOracleParams, tokenOutAmount, int24(feePercent), int(feeMinTokenIn)),
      tokenOutAmount,
      data.tokenInIdsProof,
      data.tokenOutIdsProof,
      data.fillCall
    );
  }

  // fill all or part of a swap for tokenIn -> tokenOut, with exact tokenInAmount. Price curve calculates output based on input
  function limitSwapExactInput (
    bytes32 id,
    address owner,
    Token memory tokenIn,
    Token memory tokenOut,
    uint tokenInAmount,
    IPriceCurve priceCurve,
    bytes memory priceCurveParams,
    UnsignedLimitSwapData memory data
  ) public {
    // get and update filled tokenIn amount for the swap
    uint filledTokenInAmount = getLimitSwapFilledAmount(id, tokenInAmount);

    // get the amount of tokenOut required for the requested tokenIn amount
    uint tokenOutAmountRequired = priceCurve.getOutput(
      tokenInAmount,
      filledTokenInAmount,
      data.amount,
      priceCurveParams
    );
  
    filledTokenInAmount += data.amount;
    _setLimitSwapFilledAmount(id, filledTokenInAmount, tokenInAmount);

    _fillSwap(
      tokenIn,
      tokenOut,
      owner,
      data.recipient,
      data.amount,
      tokenOutAmountRequired,
      data.tokenInIdsProof,
      data.tokenOutIdsProof,
      data.fillCall
    );
  }

  // fill all or part of a swap for tokenIn -> tokenOut, with exact tokenOutAmount. Price curve calculates input based on output
  function limitSwapExactOutput (
    bytes32 id,
    address owner,
    Token memory tokenIn,
    Token memory tokenOut,
    uint tokenOutAmount,
    IPriceCurve priceCurve,
    bytes memory priceCurveParams,
    UnsignedLimitSwapData memory data
  ) public {
    // get and update filled tokenOut amount for the swap
    uint filledTokenOutAmount = getLimitSwapFilledAmount(id, tokenOutAmount);

    // get the amount of tokenIn required for the requested tokenOut amount.
    // the getOutput() function is used to calculate the input amount, because the price curve is inverted
    uint tokenInAmountRequired = priceCurve.getOutput(
      tokenOutAmount,
      filledTokenOutAmount,
      data.amount,
      priceCurveParams
    );
  
    filledTokenOutAmount += data.amount;
    _setLimitSwapFilledAmount(id, filledTokenOutAmount, tokenOutAmount);

    _fillSwap(
      tokenIn,
      tokenOut,
      owner,
      data.recipient,
      tokenInAmountRequired,
      data.amount,
      data.tokenInIdsProof,
      data.tokenOutIdsProof,
      data.fillCall
    );
  }

  // revert if limit swap is not open
  function requireLimitSwapOpen(bytes32 id) public {

  }

  // revert if limit swap is not filled
  function requireLimitSwapFilled(bytes32 id) public {

  }

  // invert the allowed swap amount states between two limit swaps.
  // if swap0 fill amount decreases, increase fill amount for swap1 by the same amount.
  // Should be used for swaps with opposite pairs, i.e. A->B and B->A
  function invertLimitSwapFills (bytes32 swap0, bytes32 swap1) public {
    
  }

  // binds the fill amounts of multiple swaps together, such that if one swap is filled, the other swaps will be set to the same fill amount.
  // Should be used for swaps with the same pairs, i.e. A->B and A->B
  function bindLimitSwapFills (bytes32[] memory swapsIds) public {
    
  }

  // // auction tokenA in a dutch auction where price decreases until tokenA is swapped for tokenB.
  // // incentivizes initialization of the auction with initializerFee
  // function dutchAuction (bytes32 id, Token memory tokenA, Token memory tokenB, uint startPrice, uint endPrice, uint duration, address initializer, uint initializerReward) public {

  // }

  // // revert if dutch auction is not started
  // function requireDutchAuctionNotStarted (bytes32 id) public {

  // }

  // // revert if dutch auction is not open
  // function requireDutchAuctionOpen (bytes32 id) public {

  // }

  // // revert if dutch auction is not complete
  // function requireDutchAuctionComplete (bytes32 id) public {

  // }

  // // execute a dutch auction buy order
  // function dutchAuctionBuy (bytes32 id, uint inputAmount) public {

  // }

  // create a seaport listing
  function createSeaportListing (bytes32 id) public {

  }

  function _checkUnsignedTransferData (Token memory token, uint amount, UnsignedTransferData memory unsignedData) private pure {
    if (token.idsMerkleRoot != bytes32(0) && unsignedData.idsProof.ids.length != amount) {
      revert MerkleProofAndAmountMismatch();
    }
  }

  function _fillSwap (
    Token memory tokenIn,
    Token memory tokenOut,
    address owner,
    address recipient,
    uint tokenInAmount,
    uint tokenOutAmount,
    IdsProof memory tokenInIdsProof,
    IdsProof memory tokenOutIdsProof,
    Call memory fillCall
  ) internal {
    if (!verifyTokenIds(tokenIn, tokenInIdsProof)) {
      revert InvalidTokenInIds();
    }
    if (!verifyTokenIds(tokenOut, tokenOutIdsProof)) {
      revert InvalidTokenOutIds();
    }

    transferFrom(tokenIn.addr, tokenIn.standard, owner, recipient, tokenInAmount, tokenInIdsProof.ids);

    uint initialTokenOutBalance;
    {
      (uint _initialTokenOutBalance, uint initialOwnedIdCount,) = tokenOwnership(owner, tokenOut.standard, tokenOut.addr, tokenOutIdsProof.ids);
      initialTokenOutBalance = _initialTokenOutBalance;
      if (tokenOut.standard == TokenStandard.ERC721 && initialOwnedIdCount != 0) {
        revert NftIdAlreadyOwned();
      }
    }

    CALL_EXECUTOR_V2.proxyCall(fillCall.targetContract, fillCall.data);

    (uint finalTokenOutBalance,,) = tokenOwnership(owner, tokenOut.standard, tokenOut.addr, tokenOutIdsProof.ids);

    uint256 tokenOutAmountReceived = finalTokenOutBalance - initialTokenOutBalance;
    if (tokenOutAmountReceived < tokenOutAmount) {
      revert NotEnoughTokenReceived(tokenOutAmountReceived);
    }
  }

  function getSwapAmount (IUint256Oracle priceOracle, bytes memory priceOracleParams, uint token0Amount) public view returns (uint token1Amount) {
    uint priceX96 = priceOracle.getUint256(priceOracleParams);
    token1Amount = priceX96 * token0Amount / Q96;
  }

  function getSwapAmountWithFee (IUint256Oracle priceOracle, bytes memory priceOracleParams, uint token0Amount, int24 feePercent, int feeMin) public view returns (uint token1Amount) {
    token1Amount = getSwapAmount(priceOracle, priceOracleParams, token0Amount);
    int feeAmount = int(token1Amount.mulDiv(int(feePercent).abs(), 10**6)) * _sign(feePercent);
    if (feeAmount.abs() < feeMin.abs()) {
      feeAmount = feeMin;
    }
    token1Amount = uint(int(token1Amount) + feeAmount);
  }

  function getLimitSwapFilledAmount (bytes32 limitSwapId, uint totalAmount) public view returns (uint filledAmount) {
    filledAmount = getLimitSwapFilledPercent(limitSwapId).mulDiv(totalAmount, Q96);
  }

  function getLimitSwapFilledPercent (bytes32 limitSwapId) public view returns (uint filledPercent) {
    bytes32 position = keccak256(abi.encode(limitSwapId, "filledPercent"));
    assembly { filledPercent := sload(position) } 
  }

  function _setLimitSwapFilledAmount (bytes32 limitSwapId, uint filledAmount, uint totalAmount) internal {
    _setLimitSwapFilledPercent(limitSwapId, filledAmount.mulDiv(Q96, totalAmount) + 1);
  }

  function _setLimitSwapFilledPercent (bytes32 limitSwapId, uint filledPercent) internal {
    bytes32 position = keccak256(abi.encode(limitSwapId, "filledPercent"));
    assembly { sstore(position, filledPercent) } 
  }

  function _sign (int n) internal pure returns (int8 sign) {
    return n >= 0 ? int8(1) : -1;
  }
}
