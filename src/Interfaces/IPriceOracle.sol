// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.0;

interface IPriceOracle {
  function price(bytes memory params) external view returns (uint256);
}
