// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

interface IAccountFactory {
  function deployAccount(address owner) external returns (address account);
}
