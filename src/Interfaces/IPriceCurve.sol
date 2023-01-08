// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

interface IPriceCurve {
  function getOutput (
    uint totalTokenInAmount,
    uint basePrice,
    uint outputFilled,
    uint tokenInAmountRequired
  ) external returns (uint tokenOutAmountRequired);
}
