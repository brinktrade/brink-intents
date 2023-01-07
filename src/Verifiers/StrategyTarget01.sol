// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;
pragma abicoder v1;

contract StrategyTarget01 {
  
  error BadOrderIndex();
  error BadUnsignedCallForPrimitive(uint primitiveIndex);

  /// @dev Execute an order within a signed array of orders
  /// @notice This should be executed by metaDelegateCall() or metaDelegateCall_EIP1271() with the following signed and unsigned params
  /// @param strategy Strategy signed by owner [signed]
  /// @param orderIndex Index of the order to execute [unsigned]
  /// @param unsignedCalls Array of bytes data provided for the order's primitive functions that require unsigned calls [unsigned]
  function execute(
    Strategy strategy,
    uint8 orderIndex,
    bytes[] calldata unsignedCalls
  ) external {
    if (orderIndex >= strategy.orders.length) {
      revert BadOrderIndex();
    }

    _delegateCallsWithRevert(strategy.beforeCalls);

    uint8 nextUnsignedCall = 0;
    for (uint8 i = 0; i < strategy.orders[orderIndex].primitives.length; i++) {
      Primitive primitive = strategy.orders[orderIndex].primitives[i]
      bytes memory primitiveCallData;
      if (primitive.requiresUnsignedCall) {
        bytes memory unsignedCall = unsignedCalls[nextUnsignedCall];
        if (unsignedCall == bytes(0)) {
          BadUnsignedCallForPrimitive(i);
        }
        primitiveCallData = abi.encodePacked(primitive.data, unsignedCall);
      } else {
        primitiveCallData = primitive.data;
      }
      _delegateCallWithRevert(Call(strategy.primitiveTarget, primitiveCallData));
    }

    _delegateCallsWithRevert(strategy.afterCalls);
  }

  function _delegateCallsWithRevert (Call[] calls) {
    for (uint8 i = 0; i < calls.length; i++) {
      _delegateCallWithRevert(calls[i]);
    }
  }

  function _delegateCallWithRevert (Call call) internal {
    address targetContract = call.targetContract;
    bytes data = call.data;
    assembly {
      let result := delegatecall(gas(), targetContract, add(data, 0x20), mload(data), 0, 0)
      if (result, 0) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
  }

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
    bytes calldata data;
    bool requiresUnsignedCall;
  }

  struct Call {
    address targetContract;
    bytes calldata data;
  }
}