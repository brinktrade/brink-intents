// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "./IntentBase.sol";
import "./Libraries/ProxyReentrancyGuard.sol";

error BadOrderIndex();
error UnsignedCallRequired();

/// @param segmentTarget Contract address where segment functions will be executed
/// @param orders Array of allowed orders
/// @param beforeCalls Array of segment calls to execute before order execution
/// @param afterCalls Array of segment calls to execute after order execution
struct Intent {
  address segmentTarget;
  Order[] orders;
  bytes[] beforeCalls;
  bytes[] afterCalls;
}

struct Order {
  Segment[] segments;
}

struct Segment {
  bytes data;
  bool requiresUnsignedCall;
}

struct UnsignedData {
  uint8 orderIndex;
  bytes[] calls;
}

contract IntentTarget01 is IntentBase, ProxyReentrancyGuard {

  /// @dev Execute an order within a signed array of orders
  /// @notice This should be executed by metaDelegateCall() or metaDelegateCall_EIP1271() with the following signed and unsigned params
  /// @param intent Intent signed by owner [signed]
  /// @param unsignedData Unsigned calldata [unsigned]
  function execute(
    Intent calldata intent,
    UnsignedData calldata unsignedData
  ) external nonReentrant {
    if (unsignedData.orderIndex >= intent.orders.length) {
      revert BadOrderIndex();
    }

    _delegateCallsWithRevert(intent.segmentTarget, intent.beforeCalls);

    uint8 nextUnsignedCall = 0;
    for (uint8 i = 0; i < intent.orders[unsignedData.orderIndex].segments.length; i++) {
      Segment calldata segment = intent.orders[unsignedData.orderIndex].segments[i];
      bytes memory segmentCallData;
      if (segment.requiresUnsignedCall) {
        if (nextUnsignedCall >= unsignedData.calls.length) {
          revert UnsignedCallRequired();
        }

        bytes memory signedData = segment.data;

        // change length of signedData to ignore the last bytes32
        assembly {
          mstore(add(signedData, 0x0), sub(mload(signedData), 0x20))
        }

        // concat signed and unsigned call bytes
        segmentCallData = bytes.concat(signedData, unsignedData.calls[nextUnsignedCall]);
        nextUnsignedCall++;
      } else {
        segmentCallData = segment.data;
      }
      _delegateCallWithRevert(Call({
        targetContract: intent.segmentTarget,
        data: segmentCallData
      }));
    }

    _delegateCallsWithRevert(intent.segmentTarget, intent.afterCalls);
  }

  function _delegateCallsWithRevert (address targetContract, bytes[] calldata calls) internal {
    for (uint8 i = 0; i < calls.length; i++) {
      _delegateCallWithRevert(Call({
        targetContract: targetContract,
        data: calls[i]
      }));
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
