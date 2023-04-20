// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

contract ReservoirTokenStatusOracleAdapter_getBool is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  // valid signed message should return isFlagged status bool
  function testReservoirTokenStatusOracleAdapter_getBool_valid () public {
    address contractAddr = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
    uint tokenId = 1155;
    bool isFlagged = false;
    uint lastTransferTime = 1675498079;
    uint timestamp = 1676851559;
    bytes memory signature = hex"3312a380062b036f95b74e2973bc5215dd800293b87696384f7efd11d0a4a85e205f9ab2b89c24ad7091fda2ec5e63f1ac2e62ff58dc8b07032373a8ef5568001c";

    bool result = reservoirTokenStatusOracleAdapter.getBool(abi.encode(
      contractAddr, tokenId, isFlagged, lastTransferTime, timestamp, signature
    ));

    assertEq(result, false);
  }

  // when signer is not the Reservoir signer address, revert with WrongSigner()
  function testReservoirTokenStatusOracleAdapter_getBool_wrongSigner () public {
    address contractAddr = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
    uint tokenId = 1155;
    bool isFlagged = true; // not the signer value
    uint lastTransferTime = 1675498079;
    uint timestamp = 1676851559;
    bytes memory signature = hex"3312a380062b036f95b74e2973bc5215dd800293b87696384f7efd11d0a4a85e205f9ab2b89c24ad7091fda2ec5e63f1ac2e62ff58dc8b07032373a8ef5568001c";

    vm.expectRevert(abi.encodeWithSelector(WrongSigner.selector, 0x13983a1Cdb63B8ac4907C342fE72E6B63D27B232));
    bool result = reservoirTokenStatusOracleAdapter.getBool(abi.encode(
      contractAddr, tokenId, isFlagged, lastTransferTime, timestamp, signature
    ));
  }

  // when max valid time is exceeded, revert with ExceedsValidTime()
  function testReservoirTokenStatusOracleAdapter_getBool_exceedsValidTime () public {
    // timestamp of signed message + MAX_SECONDS_VALID + 1s
    vm.warp(1676851559 + 3600 + 1);

    address contractAddr = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
    uint tokenId = 1155;
    bool isFlagged = false;
    uint lastTransferTime = 1675498079;
    uint timestamp = 1676851559;
    bytes memory signature = hex"3312a380062b036f95b74e2973bc5215dd800293b87696384f7efd11d0a4a85e205f9ab2b89c24ad7091fda2ec5e63f1ac2e62ff58dc8b07032373a8ef5568001c";

    vm.expectRevert(ExceedsValidTime.selector);
    reservoirTokenStatusOracleAdapter.getBool(abi.encode(
      contractAddr, tokenId, isFlagged, lastTransferTime, timestamp, signature
    ));
  }

}

