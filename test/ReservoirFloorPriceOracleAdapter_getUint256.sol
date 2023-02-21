// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

/*
    {
      "token": "0x8a90cab2b38dba80c64b7734e58ee1db38b8992e:1155",
      "isFlagged": false,
      "lastTransferTime": 1675498079,
      "message": {
        "id": "0x0d842183cf01740259dd9ff1c70d8ab41ee3b998a374a20bea99377c0fce42d7",
        "payload": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000063de125f",
        "timestamp": 1676851559,
        "signature": "0x3312a380062b036f95b74e2973bc5215dd800293b87696384f7efd11d0a4a85e205f9ab2b89c24ad7091fda2ec5e63f1ac2e62ff58dc8b07032373a8ef5568001c"
      }
    },
  */

contract ReservoirFloorPriceOracleAdapter_getUint256 is Test, Helper  {

  function setUp () public {
    // setupAll();

    // TMP FOR OFFLINE
    setupTestContracts();
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
  function test_SKIP_ReservoirFloorPriceOracleAdapter_getUint256_exceedsValidTime () public {
    // TODO: set this with the right cheatcode
    // vm.setBlocktime(1676843903 + 1);

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

