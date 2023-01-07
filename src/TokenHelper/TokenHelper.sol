// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;
pragma abicoder v1;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';

contract TokenHelper {

  enum TokenStandard { ERC20, ERC721, ERC1155, ETH }

  struct Token {
    TokenStandard standard;
    address addr;
    bytes32 idsMerkleRoot;
    uint id;
  }

  struct IdMerkleProof {
    uint id;
    bytes32[] memory proof;
  }

  error UnsupportedTokenStandard();
  error IdNotAllowed();
  error MerkleProofsRequired();
  error ERC1155IdNotProvided();
  error OwnerHasNft();

  function transferFrom (Token token, address from, address to, uint amount, uint id, IdMerkleProof[] idMerkleProofs) internal {
    if (token.standard == ERC20) {
      IERC20(token.addr).transferFrom(from, to, amount);
      return;
    }
    
    if (token.standard == ERC721) {
      if (token.idsMerkleRoot == bytes32(0)) {
        IERC721(token.addr).transferFrom(from, to, id);
      } else {
        for (uint8 i=0; i<idMerkleProofs.length; i++) {
          _merkleProofCheck(idsMerkleRoot, idMerkleProofs[i].proof, idMerkleProofs[i].id);
          IERC721(token.addr).transferFrom(from, to, idMerkleProofs[i].id);
        }
      }
      return;
    } else if (token.standard == ERC1155) {
      if (token.idsMerkleRoot == bytes32(0)) {
        IERC1155(token.addr).transferFrom(from, to, id, amount, '');
      } else {
        uint[] ids;
        uint[] amounts;
        for (uint8 i=0; i<idMerkleProofs.length; i++) {
          _merkleProofCheck(idsMerkleRoot, idMerkleProofs[i].proof, idMerkleProofs[i].id);
          ids[i] = idMerkleProofs[i].id;
          amounts[i] = 1;
        }
        IERC1155(token.addr).safeBatchTransferFrom(from, to, ids, amounts, '');
      }
      return;
    }
    
    revert UnsupportedTokenStandard();
  }

  function balanceOf(Token token, address owner, IdMerkleProof[] idMerkleProofs) internal view returns (uint) {
    if (token.standard == ETH) {
      return owner.balance;
    }
    
    if (token.standard == ERC20) {
      return IERC20(token.addr).balanceOf(owner);
    }
    
    if (token.standard == ERC721) {
      return IERC721(token.addr).balanceOf(owner);
    }
    
    if (token.standard == ERC1155) {
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
  function checkTokenOwnership (address owner, Token token, IdMerkleProof[] idMerkleProofs) internal returns (uint balance, uint ownedIdCount) {
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

  function _merkleProofCheck (bytes32 root, bytes32[] proof, uint id) {
    // TODO: Merkle proof check here
    // check proof that root contains id
  }

}
