// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

interface IAccount {
  function metaDelegateCall(
    address to, bytes calldata data, bytes calldata signature, bytes calldata unsignedData
  ) external payable;
}
