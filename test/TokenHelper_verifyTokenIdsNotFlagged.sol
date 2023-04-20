// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";

/*
SIGNED MESSAGES FOR DOODLES @ timestamp=1677099515

{
  "messages": [
    {
      "token": "0x8a90cab2b38dba80c64b7734e58ee1db38b8992e:3798",
      "isFlagged": true,
      "lastTransferTime": 1676977007,
      "message": {
        "id": "0x03036f33ea7e9100da54fa68fab78dd800e7f389aee188a0d9844e3dcaceee5a",
        "payload": "0x00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000063f4a36f",
        "timestamp": 1677099515,
        "signature": "0x3d39ab2d4177122ce511b25a3d5072a22483694ca746715f683c8ca98ed1ea400cd927f30df54b19f0390b2c1fda3a2488b8aa5a5644972166d93bc38bcaedf21c"
      }
    },
    {
      "token": "0x8a90cab2b38dba80c64b7734e58ee1db38b8992e:2337",
      "isFlagged": false,
      "lastTransferTime": 1657735691,
      "message": {
        "id": "0x5159e9dcf4d9d88727473580329b9edf3cf3b4f729855f89194326027f0e85f7",
        "payload": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000062cf0a0b",
        "timestamp": 1677099515,
        "signature": "0xff7703e32d36cdb084c97a855f8e36e639545200320bc9be87ff07bf32650a4853af58b0a77b52696ebb5527437111ae9e0739eb56d1d5fc9f6b24ce66e4fd221c"
      }
    },
    {
      "token": "0x8a90cab2b38dba80c64b7734e58ee1db38b8992e:7632",
      "isFlagged": false,
      "lastTransferTime": 1648603038,
      "message": {
        "id": "0x237ac3d6987de116765df338d98d2b920ae4c73a3eee4fe38374caced6d0253f",
        "payload": "0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006243af9e",
        "timestamp": 1677099515,
        "signature": "0x9f14f26808f0a7739fd5a33bf0c1186192339a4593a5491b6e18980210f1f85d7d519ef78c7eff4f2a5b2259eaa659c304a7e8488bad4eff945a268f8ca2c18e1b"
      }
    }
  ]
}
*/

contract TokenHelper_verifyTokenIdsNotFlagged is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testVerifyTokenIdsNotFlagged_validSignatures () public {
    address tokenAddress = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
    uint[] memory ids = new uint[](2);
    uint[] memory lastTransferTimes = new uint[](2);
    uint[] memory timestamps = new uint[](2);
    bytes[] memory signatures = new bytes[](2);
    ids[0] = 7632;
    lastTransferTimes[0] = 1648603038;
    timestamps[0] = 1677099515;
    signatures[0] = hex"9f14f26808f0a7739fd5a33bf0c1186192339a4593a5491b6e18980210f1f85d7d519ef78c7eff4f2a5b2259eaa659c304a7e8488bad4eff945a268f8ca2c18e1b";
    ids[1] = 2337;
    lastTransferTimes[1] = 1657735691;
    timestamps[1] = 1677099515;
    signatures[1] = hex"ff7703e32d36cdb084c97a855f8e36e639545200320bc9be87ff07bf32650a4853af58b0a77b52696ebb5527437111ae9e0739eb56d1d5fc9f6b24ce66e4fd221c";

    tokenHelper.verifyTokenIdsNotFlagged_internal(tokenAddress, ids, lastTransferTimes, timestamps, signatures);
  }

  function testVerifyTokenIdsNotFlagged_invalidSignatures () public {
    address tokenAddress = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
    uint[] memory ids = new uint[](2);
    uint[] memory lastTransferTimes = new uint[](2);
    uint[] memory timestamps = new uint[](2);
    bytes[] memory signatures = new bytes[](2);
    ids[0] = 7632;
    lastTransferTimes[0] = 1648603038;
    timestamps[0] = 1677099515;
    signatures[0] = hex"9f14f26808f0a7739fd5a33bf0c1186192339a4593a5491b6e18980210f1f85d7d519ef78c7eff4f2a5b2259eaa659c304a7e8488bad4eff945a268f8ca2c18e1b";
    ids[1] = 2222; // wrong id
    lastTransferTimes[1] = 1657735691;
    timestamps[1] = 1677099515;
    signatures[1] = hex"ff7703e32d36cdb084c97a855f8e36e639545200320bc9be87ff07bf32650a4853af58b0a77b52696ebb5527437111ae9e0739eb56d1d5fc9f6b24ce66e4fd221c";

    vm.expectRevert(abi.encodeWithSelector(WrongSigner.selector, 0xDABA04D48C27502847Bbc89Ae9fAf37Dd5F6d846));
    tokenHelper.verifyTokenIdsNotFlagged_internal(tokenAddress, ids, lastTransferTimes, timestamps, signatures);
  }

}
