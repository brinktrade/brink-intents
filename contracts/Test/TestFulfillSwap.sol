// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.10;
pragma abicoder v1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract TestFulfillSwap is ERC1155Holder {

  function fulfillTokenOutSwap(IERC20 tokenOut, uint tokenOutAmount, address account) external payable {
    tokenOut.transfer(account, tokenOutAmount);
  }

  function fulfillEthOutSwap(uint ethOutAmount, address account) external {
    bool success;
    (success, ) = account.call{value: ethOutAmount}("");
    require(success, "TestFulfillSwap: fulfillEthOutSwap send ether to msg.sender failed");
  }

  function fulfillNftOutSwap(IERC721 nftOut, uint nftID, address account) external payable {
    if (nftID > 0) {
      nftOut.transferFrom(address(this), account, nftID);
    }
  }

  function fulfillNftOutSwapAndCall(IERC721 nftOut, uint nftID, address account, address to, bytes memory data) external payable {
    if (nftID > 0) {
      nftOut.transferFrom(address(this), account, nftID);
    }

    assembly {
      let result := call(gas(), to, 0, add(data, 0x20), mload(data), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }

  function fulfillERC1155OutSwap(IERC1155 erc1155Out, uint id, uint amount, address account) external payable {
    erc1155Out.safeTransferFrom(address(this), account, id, amount, '');
  }

  function fulfillNothing () external payable {
    
  }

  receive() external payable {}
}
