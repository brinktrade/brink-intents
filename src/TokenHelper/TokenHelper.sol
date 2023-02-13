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

struct IdsMerkleProof {
  uint[] ids;
  bytes32[] proof;
  bool[] proofFlags;
}

error UnsupportedTokenStandard();
error IdNotAllowed();
error MerkleProofsRequired();
error ERC1155IdNotProvided();
error OwnerHasNft();
error InvalidIds();
error IdsLengthZero();

contract TokenHelper {

  function transferFrom (Token memory token, address from, address to, uint amount, IdsMerkleProof memory idsMerkleProof) internal {
    if (token.standard == TokenStandard.ERC20) {
      IERC20(token.addr).transferFrom(from, to, amount);
      return;
    }
    
    if (token.standard == TokenStandard.ERC721) {
      if (token.idsMerkleRoot == bytes32(0)) {
        IERC721(token.addr).transferFrom(from, to, token.id);
      } else {
        if (!verifyIdsMerkleProof(idsMerkleProof, token.idsMerkleRoot)) {
          revert InvalidIds();
        }
        for (uint8 i=0; i<idsMerkleProof.ids.length; i++) {
          IERC721(token.addr).transferFrom(from, to, idsMerkleProof.ids[i]);
        }
      }
      return;
    } else if (token.standard == TokenStandard.ERC1155) {
      if (token.idsMerkleRoot == bytes32(0)) {
        IERC1155(token.addr).safeTransferFrom(from, to, token.id, amount, '');
      } else {
        if (!verifyIdsMerkleProof(idsMerkleProof, token.idsMerkleRoot)) {
          revert InvalidIds();
        }
        uint[] memory amounts;
        for (uint8 i=0; i<idsMerkleProof.ids.length; i++) {
          amounts[i] = 1;
        }
        IERC1155(token.addr).safeBatchTransferFrom(from, to, idsMerkleProof.ids, amounts, '');
      }
      return;
    }

    revert UnsupportedTokenStandard();
  }

  // returns total balance and number of NFT ids owned
  function checkTokenOwnership (
    address owner,
    Token memory token,
    IdsMerkleProof memory idsMerkleProof
  ) internal view returns (uint balance, uint ownedIdCount) {
    if (token.standard == TokenStandard.ERC721) {
      if (token.id > 0 && IERC721(token.addr).ownerOf(token.id) == owner) {
        ownedIdCount = 1;
      } else if (token.idsMerkleRoot != bytes32(0)) {
        for (uint8 i=0; i<idsMerkleProof.ids.length; i++) {
          if (IERC721(token.addr).ownerOf(idsMerkleProof.ids[i]) == owner) {
            ownedIdCount++;
            break;
          }
        }
      }
    }

    balance = balanceOf(token, owner, idsMerkleProof);

    if (token.standard == TokenStandard.ERC1155 && token.idsMerkleRoot != bytes32(0)) {
      ownedIdCount = balance;
    }
  }

  function balanceOf(Token memory token, address owner, IdsMerkleProof memory idsMerkleProof) internal view returns (uint) {
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
        for (uint8 i=0; i<idsMerkleProof.ids.length; i++) {
          balance += (IERC1155(token.addr).balanceOf(owner, idsMerkleProof.ids[i]) > 0 ? 1 : 0);
        }
        return balance;
      }
    }

    revert UnsupportedTokenStandard();
  }

  function verifyIdsMerkleProof (IdsMerkleProof memory idsMerkleProof, bytes32 root) internal pure returns (bool) {
    if (idsMerkleProof.ids.length == 0) {
      return false;
    } else if (idsMerkleProof.ids.length == 1) {
      return verifyId(idsMerkleProof.proof, root, idsMerkleProof.ids[0]);
    } else {
      return verifyIds(idsMerkleProof.proof, idsMerkleProof.proofFlags, root, idsMerkleProof.ids);
    }
  }

  function verifyId (bytes32[] memory proof, bytes32 root, uint id) internal pure returns (bool) {
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(id))));
    return MerkleProof.verify(proof, root, leaf);
  }

  function verifyIds (bytes32[] memory proof, bool[] memory proofFlags, bytes32 root, uint[] memory ids) internal pure returns (bool) {
    bytes32[] memory leaves = new bytes32[](ids.length);
    for (uint8 i=0; i<ids.length; i++) {
      leaves[i] = keccak256(bytes.concat(keccak256(abi.encode(ids[i]))));
    }
    return MerkleProof.multiProofVerify(proof, proofFlags, root, leaves);
  }

}
