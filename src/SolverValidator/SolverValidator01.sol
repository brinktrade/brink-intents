// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../Interfaces/ISolverValidator.sol";

contract SolverValidator01 is ISolverValidator, Ownable {

  event SolverValiditySet(address solver, bool valid);

  mapping (address => bool) solverValidity;

  constructor () {
    transferOwnership(0x0AfB7C8cf2b639675a20Fda58Adf3307d40e8E8A);
    solverValidity[0x0AfB7C8cf2b639675a20Fda58Adf3307d40e8E8A] = true;
  }

  function isValidSolver (address solver) external view returns (bool valid) {
    valid = solverValidity[solver];
  }

  function setSolverValidity (address solver, bool valid) external onlyOwner {
    solverValidity[solver] = valid;
    emit SolverValiditySet(solver, valid);
  }
}
