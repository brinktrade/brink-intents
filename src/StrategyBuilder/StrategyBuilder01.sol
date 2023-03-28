// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "../TokenHelper/TokenHelper.sol";

import "../StrategyTarget01.sol";
import "./OrderBuilder01.sol";
import "./PrimitiveBuilder01.sol";
import "./UnsignedDataBuilder01.sol";

contract StrategyBuilder01 is PrimitiveBuilder01, OrderBuilder01, UnsignedDataBuilder01 {

  address public immutable primitives;

  constructor (address _primitives) {
    primitives = _primitives;
  }

  function strategy (
    Order[] memory orders
  ) public view returns (bytes memory data) {
    data = strategy(orders, new Call[](0), new Call[](0));
  }

  function strategy (
    Order[] memory orders,
    Call[] memory beforeCalls,
    Call[] memory afterCalls
  ) public view returns (bytes memory data) {
    // encode strategy data without using Strategy struct
    bytes memory strategyData = abi.encode(
      primitives,
      orders,
      beforeCalls,
      afterCalls
    );

    // create a memory pointer to the encoded strategy data, which starts after 64 bytes (after the two pointers)
    bytes32 strategyPtr = 0x0000000000000000000000000000000000000000000000000000000000000040;

    // create a memory pointer to where unsigned data will be appended,
    // which will be after 64 bytes (for the two pointers) plus the length of the encoded strategy
    bytes32 unsignedDataPtr = bytes32(strategyData.length + 0x40); 

    data = bytes.concat(
      StrategyTarget01.execute.selector, // bytes4: fn selector
      strategyPtr,        // bytes32: memory pointer to strategy data
      unsignedDataPtr,    // bytes32: memory pointer to unsigned data
      strategyData        // bytes: encoded strategy
    );
  }

}
