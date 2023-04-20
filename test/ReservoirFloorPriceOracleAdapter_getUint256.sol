// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract ReservoirFloorPriceOracleAdapter_getUint256 is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // valid signed message should return X96 price
  function testReservoirFloorPriceOracleAdapter_getUint256_valid () public {
    uint8 priceKind = 1; // PriceKind.TWAP
    uint twapSeconds = 3600;
    address contractAddr = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
    uint floorPrice = 5865655555555560000;
    uint timestamp = 1676840303;
    bytes memory signature = hex"84c2b77a4bcb12565be2a4ef6d00ab2273ae3060c96b7827a2de0914f0e6c789597953e1979c81fe982c49e61cfe2ec22ef95e0b2511049d460bddc240641f781b";

    uint result = reservoirFloorPriceOracleAdapter.getUint256(abi.encode(
      priceKind, twapSeconds, contractAddr, floorPrice, timestamp, signature
    ));

    assertEq(result, floorPrice * 0x1000000000000000000000000);
  }

  // when signer is not the Reservoir signer address, revert with WrongSigner()
  function testReservoirFloorPriceOracleAdapter_getUint256_wrongSigner () public {
    uint8 priceKind = 1;
    uint twapSeconds = 86400; // not the signed value
    address contractAddr = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
    uint floorPrice = 5865655555555560000;
    uint timestamp = 1676840303;
    bytes memory signature = hex"84c2b77a4bcb12565be2a4ef6d00ab2273ae3060c96b7827a2de0914f0e6c789597953e1979c81fe982c49e61cfe2ec22ef95e0b2511049d460bddc240641f781b";

    vm.expectRevert(abi.encodeWithSelector(WrongSigner.selector, 0xCA373876d6dF5dF30412D2c70e5f49a703FA6e86));
    uint result = reservoirFloorPriceOracleAdapter.getUint256(abi.encode(
      priceKind, twapSeconds, contractAddr, floorPrice, timestamp, signature
    ));
  }

  // when max valid time is exceeded, revert with ExceedsValidTime()
  function testReservoirFloorPriceOracleAdapter_getUint256_exceedsValidTime () public {
    // timestamp of signed message + MAX_SECONDS_VALID + 1s
    vm.warp(1676840303 + 3600 + 1);

    uint8 priceKind = 1; // PriceKind.TWAP
    uint twapSeconds = 3600;
    address contractAddr = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
    uint floorPrice = 5865655555555560000;
    uint timestamp = 1676840303;
    bytes memory signature = hex"84c2b77a4bcb12565be2a4ef6d00ab2273ae3060c96b7827a2de0914f0e6c789597953e1979c81fe982c49e61cfe2ec22ef95e0b2511049d460bddc240641f781b";

    vm.expectRevert(ExceedsValidTime.selector);
    reservoirFloorPriceOracleAdapter.getUint256(abi.encode(
      priceKind, twapSeconds, contractAddr, floorPrice, timestamp, signature
    ));
  }
}

