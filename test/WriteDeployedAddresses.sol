// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "forge-std/Test.sol";
import "./Helper.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DeployedAddresses is Test, Helper  {

  function setUp () public {
    setupAll();
  }

  function testWriteDeployedAddressesToConstants () public {
    string memory str =      "module.exports = {\n";
    str = string.concat(str, "  TWAP_ADAPTER: '", addressToString(address(twapAdapter)), "',\n");
    str = string.concat(str, "  TWAP_INVERSE_ADAPTER: '", addressToString(address(twapInverseAdapter)), "',\n");
    str = string.concat(str, "  TWAP_ADAPTER_02: '", addressToString(address(twapAdapter02)), "',\n");
    str = string.concat(str, "  TWAP_INVERSE_ADAPTER_02: '", addressToString(address(twapInverseAdapter02)), "',\n");
    str = string.concat(str, "  FLAT_PRICE_CURVE: '", addressToString(address(flatPriceCurve)), "',\n");
    str = string.concat(str, "  LINEAR_PRICE_CURVE: '", addressToString(address(linearPriceCurve)), "',\n");
    str = string.concat(str, "  RESERVOIR_FLOOR_PRICE_ORACLE_ADAPTER: '", addressToString(address(reservoirFloorPriceOracleAdapter)), "',\n");
    str = string.concat(str, "  RESERVOIR_TOKEN_STATUS_ORACLE_ADAPTER: '", addressToString(address(reservoirTokenStatusOracleAdapter)), "',\n");
    str = string.concat(str, "  SEGMENTS_01: '", addressToString(address(segments)), "',\n");
    str = string.concat(str, "  INTENT_TARGET_01: '", addressToString(address(intentTarget)), "',\n");
    str = string.concat(str, "  SOLVER_VALIDATOR_01: '", addressToString(address(solverValidator01)), "',\n");
    str = string.concat(str, "  FIXED_SWAP_AMOUNT_01: '", addressToString(address(fixedSwapAmount01)), "',\n");
    str = string.concat(str, "  BLOCK_INTERVAL_DUTCH_AUCTION_AMOUNT_01: '", addressToString(address(blockIntervalDutchAuctionAmount01)), "'\n");
    str = string.concat(str, "}\n");
    vm.writeFile('./constants.js', str);
  }
}

function addressToString (address addr) returns (string memory){
  return Strings.toHexString(uint256(uint160(addr)), 20);
}