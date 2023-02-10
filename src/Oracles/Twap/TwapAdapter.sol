// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.7.6;

import "./TwapLogic.sol";

contract TwapAdapter is TwapLogic {

  function getUint256(bytes memory params) public view override returns (uint256) {
    (address uniswapV3Pool, uint32 twapInterval) = abi.decode(params, (address,uint32));
    return getTwapX96(uniswapV3Pool, twapInterval);
  }

}
