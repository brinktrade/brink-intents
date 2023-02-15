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
error AtLeastOneIdRequired();
error MerkleProofsRequired();
error ERC1155IdNotProvided();
error OwnerHasNft();
error InvalidIds();
error IdsLengthZero();

contract TokenHelper {

  function transferFrom (Token memory token, address from, address to, uint amount, uint tokenId, IdsMerkleProof memory idsMerkleProof) internal {
    if (token.standard == TokenStandard.ERC20) {
      IERC20(token.addr).transferFrom(from, to, amount);
      return;
    }
    
    if (token.standard == TokenStandard.ERC721) {
      if (token.idsMerkleRoot == bytes32(0)) {
        // check 1 id allowed
        if (token.id != 0 && token.id != tokenId) {
          revert IdNotAllowed();
        }
        IERC721(token.addr).transferFrom(from, to, tokenId);
      } else {
        // check ids allowed
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
        // check 1 id allowed
        if (token.id != 0 && token.id != tokenId) {
          revert IdNotAllowed();
        }
        IERC1155(token.addr).safeTransferFrom(from, to, tokenId, amount, '');
      } else {
        // check ids allowed
        if (!verifyIdsMerkleProof(idsMerkleProof, token.idsMerkleRoot)) {
          revert InvalidIds();
        }
        uint[] memory amounts = new uint[](idsMerkleProof.ids.length);
        for (uint8 i=0; i<idsMerkleProof.ids.length; i++) {
          amounts[i] = 1;
        }
        IERC1155(token.addr).safeBatchTransferFrom(from, to, idsMerkleProof.ids, amounts, '');
      }
      return;
    }

    revert UnsupportedTokenStandard();
  }

  // returns
  //    balance: total balance for all ids
  //    ownedIdCount: total number of ids with balance > 0
  //    idBalances: array of individual id balances
  function tokenOwnership (
    address owner,
    TokenStandard tokenStandard,
    address tokenAddress,
    uint[] memory ids
  ) internal view returns (uint balance, uint ownedIdCount, uint[] memory idBalances) {
    if (tokenStandard == TokenStandard.ERC721 || tokenStandard == TokenStandard.ERC1155) {
      if (ids[0] == 0) {
        revert AtLeastOneIdRequired();
      }

      idBalances = new uint[](ids.length);

      for (uint8 i=0; i<ids.length; i++) {
        if (tokenStandard == TokenStandard.ERC721 && IERC721(tokenAddress).ownerOf(ids[i]) == owner) {
          ownedIdCount++;
          balance++;
          idBalances[i] = 1;
        } else if (tokenStandard == TokenStandard.ERC1155) {
          idBalances[i] = IERC1155(tokenAddress).balanceOf(owner, ids[i]);
          if (idBalances[i] > 0) {
            ownedIdCount++;
            balance += idBalances[i];
          }
        }
      }
    } else if (tokenStandard == TokenStandard.ERC20) {
      balance = IERC20(tokenAddress).balanceOf(owner);
    } else if (tokenStandard == TokenStandard.ETH) {
      balance = owner.balance;
    } else {
      revert UnsupportedTokenStandard();
    }
  }

  // TODO: tests for this
  function verifyTokenIds (Token memory token, IdsMerkleProof memory idsMerkleProof) internal pure returns (bool valid) {
    if (token.id > 0) {
      valid = idsMerkleProof.ids.length == 1 && token.id == idsMerkleProof.ids[0];
    } else if (token.idsMerkleRoot != bytes32(0)) {
      return verifyIdsMerkleProof(idsMerkleProof, token.idsMerkleRoot);
    }
    return true;
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
