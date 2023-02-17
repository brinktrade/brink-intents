// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 'openzeppelin/token/ERC1155/utils/ERC1155Holder.sol';
import '../../src/TokenHelper/TokenHelper.sol';

// this contract is setup in tests with some ETH, ERC20, ERC721, and ERC1155's.
// The fill() function can be used to transfer these to any recipient
contract Filler is TokenHelper, ERC1155Holder {
  
  function fill (address tokenAddress, TokenStandard tokenStandard, address to, uint amount, uint[] memory ids) public {
    transferFrom(tokenAddress, tokenStandard, address(this), to, amount, ids);
  }
}
