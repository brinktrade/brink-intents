// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import 'forge-std/console.sol';
import '@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol';
import '../../src/TokenHelper/TokenHelper.sol';
import './Constants.sol';

// this contract is setup in tests with some ETH, ERC20, ERC721, and ERC1155's.
// The fill() function can be used to transfer these to any recipient
contract Filler is TokenHelper, ERC1155Holder, Constants {
  
  function fill (address tokenAddress, TokenStandard tokenStandard, address to, uint amount, uint[] memory ids) public {
    if (tokenStandard == TokenStandard.ERC20) {
      // USDC requires the caller to approve transferFrom()
      IERC20(tokenAddress).approve(address(this), MAX_UINT);
    }
    transferFrom(tokenAddress, tokenStandard, address(this), to, amount, ids);
  }
}
