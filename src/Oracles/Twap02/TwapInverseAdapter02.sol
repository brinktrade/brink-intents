// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.7.6;

import "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol";
import "./TwapLogic02.sol";

contract TwapInverseAdapter02 is TwapLogic02 {

  function getUint256(bytes memory params) public view override returns (uint256) {
    (address uniswapV3Pool, uint32 twapInterval) = abi.decode(params, (address,uint32));
    return FullMath.mulDiv(
      FixedPoint96.Q96,
      FixedPoint96.Q96,
      getTwapX96(uniswapV3Pool, twapInterval)
    );
  }

}
