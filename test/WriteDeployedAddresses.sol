// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Helper.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DeployedAddresses is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testWriteDeployedAddressesToConstants () public {
    console.log();
    vm.writeFile('./constants.js',
string.concat(
"module.exports = {\n",
"  TWAP_ADAPTER: '", addressToString(address(twapAdapter)), "',\n",
"  TWAP_INVERSE_ADAPTER: '", addressToString(address(twapInverseAdapter)), "',\n",
"  FLAT_PRICE_CURVE: '", addressToString(address(flatPriceCurve)), "',\n",
"  LINEAR_PRICE_CURVE: '", addressToString(address(linearPriceCurve)), "',\n",
"  RESERVOIR_FLOOR_PRICE_ORACLE_ADAPTER: '", addressToString(address(reservoirFloorPriceOracleAdapter)), "',\n",
"  RESERVOIR_TOKEN_STATUS_ORACLE_ADAPTER: '", addressToString(address(reservoirTokenStatusOracleAdapter)), "',\n",
"  PRIMITIVES_01: '", addressToString(address(primitives)), "',\n",
"  STRATEGY_TARGET_01: '", addressToString(address(strategyTarget)), "'\n",
"}\n"
)
    );
  }
}

function addressToString (address addr) returns (string memory){
  return Strings.toHexString(uint256(uint160(addr)), 20);
}