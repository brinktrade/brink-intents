// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.0;

interface IDeployer {
  function getDeployAddress (bytes memory initCode) external pure returns (address deployAddress);
  function deploy(bytes memory initCode) external;
}
