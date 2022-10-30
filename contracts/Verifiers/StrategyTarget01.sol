// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.10;
pragma abicoder v1;

contract StrategyTarget01 {

  /// @dev Execute an order within a signed array of orders
  /// @notice This should be executed by metaDelegateCall() or metaDelegateCall_EIP1271() with the following signed and unsigned params
  /// @param strategy Strategy signed by owner [signed]
  /// @param orderIndex Index of the order to execute [unsigned]
  /// @param unsignedCalls Array of unsigned calls provided for the order's primative functions [unsigned]
  function execute(
    Strategy strategy,
    uint8 orderIndex,
    UnsignedCall[] unsignedCalls
  ) external {
    
  }

  /// @param primativeTarget Contract address where primative functions will be executed
  /// @param orders Array of allowed orders
  /// @param beforeCalls Array of primative calls to execute before order execution
  /// @param afterCalls Array of primative calls to execute after order execution
  struct Strategy {
    address primativeTarget;
    Order[] orders;
    Primative[] beforeCalls;
    Primative[] afterCalls;
  }

  struct Order {
    Primative[] primatives;
  }

  struct Primative {
    bytes callData;
    bool hasUnsignedCall;
  }

  struct UnsignedCall {
    uint8 id;
    Call call;
  }
}
