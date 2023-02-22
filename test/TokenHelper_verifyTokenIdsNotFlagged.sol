// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";

contract TokenHelper_verifyTokenIdsNotFlagged is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testVerifyTokenIdsNotFlagged_validSignatures () public {
    address tokenAddress = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
    uint[] memory ids = new uint[](1);
    uint[] memory lastTransferTimes = new uint[](1);
    uint[] memory timestamps = new uint[](1);
    bytes[] memory signatures = new bytes[](1);
    ids[0] = 1155;
    lastTransferTimes[0] = 1675498079;
    timestamps[0] = 1676851559;
    signatures[0] = hex"3312a380062b036f95b74e2973bc5215dd800293b87696384f7efd11d0a4a85e205f9ab2b89c24ad7091fda2ec5e63f1ac2e62ff58dc8b07032373a8ef5568001c";

    tokenHelper.verifyTokenIdsNotFlagged_internal(tokenAddress, ids, lastTransferTimes, timestamps, signatures);
  }

  function testVerifyTokenIdsNotFlagged_invalidSignatures () public {
    address tokenAddress = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
    uint[] memory ids = new uint[](1);
    uint[] memory lastTransferTimes = new uint[](1);
    uint[] memory timestamps = new uint[](1);
    bytes[] memory signatures = new bytes[](1);
    ids[0] = 1156; // not valid
    lastTransferTimes[0] = 1675498079;
    timestamps[0] = 1676851559;
    signatures[0] = hex"3312a380062b036f95b74e2973bc5215dd800293b87696384f7efd11d0a4a85e205f9ab2b89c24ad7091fda2ec5e63f1ac2e62ff58dc8b07032373a8ef5568001c";

    vm.expectRevert(abi.encodeWithSelector(WrongSigner.selector, 0x9c8B4eF0F251dCC0a12C5Af09fEb3EA7837b06a9));
    tokenHelper.verifyTokenIdsNotFlagged_internal(tokenAddress, ids, lastTransferTimes, timestamps, signatures);
  }

}
