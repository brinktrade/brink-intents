// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

error InvalidSignature();
error ExceedsValidTime();
error WrongSigner(address signer);

abstract contract ReservoirOracle {

  address constant SIGNER = 0xAeB1D03929bF87F69888f381e73FBf75753d75AF;
  uint constant MAX_SECONDS_VALID = 3600;
  uint256 internal constant Q96 = 0x1000000000000000000000000;

  function _validateTimestamp (uint timestamp) internal view {
    if (timestamp + MAX_SECONDS_VALID < block.timestamp) {
      revert ExceedsValidTime();
    }
  }

  function _validateSigner (address signer) internal pure {
    if (signer != SIGNER) {
      revert WrongSigner(signer);
    }
  }

  function _recover(
    bytes32 messageId,
    bytes memory payload,
    uint timestamp,
    bytes memory signature
  ) internal pure returns (address signer) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Extract the individual signature fields from the signature
    if (signature.length == 64) {
      // EIP-2098 compact signature
      bytes32 vs;
      assembly {
        r := mload(add(signature, 0x20))
        vs := mload(add(signature, 0x40))
        s := and(
          vs,
          0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        )
        v := add(shr(255, vs), 27)
      }
    } else if (signature.length == 65) {
      // ECDSA signature
      assembly {
        r := mload(add(signature, 0x20))
        s := mload(add(signature, 0x40))
        v := byte(0, mload(add(signature, 0x60)))
      }
    } else {
      revert InvalidSignature();
    }

    signer = ecrecover(
      keccak256(
        abi.encodePacked(
          "\x19Ethereum Signed Message:\n32",
          // EIP-712 structured-data hash
          keccak256(
            abi.encode(
              keccak256(
                "Message(bytes32 id,bytes payload,uint256 timestamp)"
              ),
              messageId,
              keccak256(payload),
              timestamp
            )
          )
        )
      ),
      v,
      r,
      s
    );
  }
}
