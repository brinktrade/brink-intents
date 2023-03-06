// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./StrategyBase.sol";

error BadOrderIndex();
error UnsignedCallRequired();

/// @param primitiveTarget Contract address where primitive functions will be executed
/// @param orders Array of allowed orders
/// @param beforeCalls Array of primitive calls to execute before order execution
/// @param afterCalls Array of primitive calls to execute after order execution
struct Strategy {
  address primitiveTarget;
  Order[] orders;
  Call[] beforeCalls;
  Call[] afterCalls;
}

struct Order {
  Primitive[] primitives;
}

struct Primitive {
  bytes data;
  bool requiresUnsignedCall;
}

struct UnsignedData {
  uint8 orderIndex;
  bytes[] calls;
}

contract StrategyTarget01 is StrategyBase {

  /// @dev Execute an order within a signed array of orders
  /// @notice This should be executed by metaDelegateCall() or metaDelegateCall_EIP1271() with the following signed and unsigned params
  /// @param strategy Strategy signed by owner [signed]
  /// @param unsignedData Unsigned calldata [unsigned]
  function execute(
    Strategy calldata strategy,
    UnsignedData calldata unsignedData
  ) external {
    if (unsignedData.orderIndex >= strategy.orders.length) {
      revert BadOrderIndex();
    }

    _delegateCallsWithRevert(strategy.beforeCalls);

    uint8 nextUnsignedCall = 0;
    for (uint8 i = 0; i < strategy.orders[unsignedData.orderIndex].primitives.length; i++) {
      Primitive calldata primitive = strategy.orders[unsignedData.orderIndex].primitives[i];
      bytes memory primitiveCallData;
      if (primitive.requiresUnsignedCall) {
        if (nextUnsignedCall >= unsignedData.calls.length) {
          revert UnsignedCallRequired();
        }

        bytes memory signedData = primitive.data;

        // change length of signedData to ignore the last bytes32
        assembly {
          mstore(add(signedData, 0x0), sub(mload(signedData), 0x20))
        }

        // concat signed and unsigned call bytes
        primitiveCallData = bytes.concat(signedData, unsignedData.calls[nextUnsignedCall]);
        nextUnsignedCall++;
      } else {
        primitiveCallData = primitive.data;
      }
      _delegateCallWithRevert(Call({
        targetContract: strategy.primitiveTarget,
        data: primitiveCallData
      }));
    }

    _delegateCallsWithRevert(strategy.afterCalls);
  }

  function _delegateCallsWithRevert (Call[] calldata calls) internal {
    for (uint8 i = 0; i < calls.length; i++) {
      _delegateCallWithRevert(calls[i]);
    }
  }

  function _delegateCallWithRevert (Call memory call) internal {
    address targetContract = call.targetContract;
    bytes memory data = call.data;
    assembly {
      let result := delegatecall(gas(), targetContract, add(data, 0x20), mload(data), 0, 0)
      if eq(result, 0) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
  }
}
