// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import 'openzeppelin/token/ERC20/IERC20.sol';
import 'openzeppelin/token/ERC721/IERC721.sol';
import 'openzeppelin/token/ERC1155/IERC1155.sol';
import 'openzeppelin/utils/cryptography/MerkleProof.sol';

  enum TokenStandard { ERC20, ERC721, ERC1155, ETH }

  struct Token {
    TokenStandard standard;
    address addr;
    bytes32 idsMerkleRoot;
    uint id;
  }

  struct IdMerkleProof {
    uint id;
    bytes32[] proof;
  }

  error UnsupportedTokenStandard();
  error IdNotAllowed();
  error MerkleProofsRequired();
  error ERC1155IdNotProvided();
  error OwnerHasNft();

contract TokenHelper {

  function transferFrom (Token memory token, address from, address to, uint amount, uint id, IdMerkleProof[] memory idMerkleProofs) internal {
    if (token.standard == TokenStandard.ERC20) {
      IERC20(token.addr).transferFrom(from, to, amount);
      return;
    }
    
    if (token.standard == TokenStandard.ERC721) {
      if (token.idsMerkleRoot == bytes32(0)) {
        IERC721(token.addr).transferFrom(from, to, id);
      } else {
        for (uint8 i=0; i<idMerkleProofs.length; i++) {
          verifyId(idMerkleProofs[i].proof, token.idsMerkleRoot,idMerkleProofs[i].id);
          IERC721(token.addr).transferFrom(from, to, idMerkleProofs[i].id);
        }
      }
      return;
    } else if (token.standard == TokenStandard.ERC1155) {
      if (token.idsMerkleRoot == bytes32(0)) {
        IERC1155(token.addr).safeTransferFrom(from, to, id, amount, '');
      } else {
        uint[] memory ids;
        uint[] memory amounts;
        for (uint8 i=0; i<idMerkleProofs.length; i++) {
          verifyId(idMerkleProofs[i].proof, token.idsMerkleRoot, idMerkleProofs[i].id);
          ids[i] = idMerkleProofs[i].id;
          amounts[i] = 1;
        }
        IERC1155(token.addr).safeBatchTransferFrom(from, to, ids, amounts, '');
      }
      return;
    }

    revert UnsupportedTokenStandard();
  }

  function balanceOf(Token memory token, address owner, IdMerkleProof[] memory idMerkleProofs) internal view returns (uint) {
    if (token.standard == TokenStandard.ETH) {
      return owner.balance;
    }
    
    if (token.standard == TokenStandard.ERC20) {
      return IERC20(token.addr).balanceOf(owner);
    }
    
    if (token.standard == TokenStandard.ERC721) {
      return IERC721(token.addr).balanceOf(owner);
    }
    
    if (token.standard == TokenStandard.ERC1155) {
      if (token.id > 0) {
        return IERC1155(token.addr).balanceOf(owner, token.id);
      } else {
        uint balance;
        for (uint8 i=0; i<idMerkleProofs.length; i++) {
          balance += (IERC1155(token.addr).balanceOf(owner, idMerkleProofs[i].id) > 0 ? 1 : 0);
        }
        return balance;
      }
    }

    revert UnsupportedTokenStandard();
  }

  // returns total balance and number of NFT ids owned
  function checkTokenOwnership (
    address owner,
    Token memory token,
    IdMerkleProof[] memory idMerkleProofs
  ) internal view returns (uint balance, uint ownedIdCount) {
    if (token.standard == TokenStandard.ERC721) {
      if (token.id > 0 && IERC721(token.addr).ownerOf(token.id) == owner) {
        ownedIdCount = 1;
      } else if (token.idsMerkleRoot != bytes32(0)) {
        for (uint8 i=0; i<idMerkleProofs.length; i++) {
          if (IERC721(token.addr).ownerOf(idMerkleProofs[i].id) == owner) {
            ownedIdCount++;
            break;
          }
        }
      }
    }

    balance = balanceOf(token, owner, idMerkleProofs);

    if (token.standard == TokenStandard.ERC1155 && token.idsMerkleRoot != bytes32(0)) {
      ownedIdCount = balance;
    }
  }

  function verifyId (bytes32[] memory proof, bytes32 root, uint id) internal pure returns (bool) {
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(id))));
    return MerkleProof.verify(proof, root, leaf);
  }

}
