// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "uniswap-v3-core/Interfaces/IUniswapV3Pool.sol";
import "openzeppelin/utils/Strings.sol";
import "../src/Interfaces/ITwapAdapter.sol";
import "../src/TokenHelper/TokenHelper.sol";
import "../src/Primitives/Primitives01.sol";
import "./Mocks/MockPriceOracle.sol";
import "./Mocks/MockPrimitiveInternals.sol";
import "./Mocks/MockTokenHelperInternals.sol";

contract Helper is Test {

  ITwapAdapter public twapAdapter;
  ITwapAdapter public twapInverseAdapter;
  Primitives01 public primitives;
  MockPriceOracle public mockPriceOracle;
  MockPrimitiveInternals public primitiveInternals;
  MockTokenHelperInternals public tokenHelper;

  // TWAP prices are in fixed point X96 (2**96)

  // TWAP price for interval 1000s - 0s: ~0.000645 USDC/ETH
  uint256 public MAGIC_TWAP_PRICE_USDC_ETH_1000_0 = 51128994256875305254096266510654458404;
  // inverse ~1549.574 ETH/USDC
  uint256 public MAGIC_TWAP_PRICE_ETH_USDC_1000_0 = 122769904368744749859;
  
  
  // TWAP price for interval 2000s - 1000s: ~0.000646 USDC/ETH
  uint256 public MAGIC_TWAP_PRICE_USDC_ETH_2000_1000 = 51185264279942680916728141158213785257;
  // inverse ~1547.871 ETH/USDC
  uint256 public MAGIC_TWAP_PRICE_ETH_USDC_2000_1000 = 122634938466976106938;

  uint256 public BLOCK_JAN_25_2023 = 16_485_101;
  uint256 public BLOCK_FEB_12_2023 = 16_614_361;
  uint256 public mainnetFork;

  address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address public DOODLES = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
  address public THE_MEMES = 0x33FD426905F149f8376e227d0C9D3340AaD17aF1;

  Token public WETH_Token = Token(TokenStandard.ERC20, WETH, 0x0, 0);
  Token public USDC_Token = Token(TokenStandard.ERC20, USDC, 0x0, 0);
  Token public DOODLES_Token = Token(TokenStandard.ERC721, DOODLES, 0x0, 0);
  Token public THE_MEMES_FIRSTGM_Token = Token(TokenStandard.ERC1155, THE_MEMES, 0x0, 8);

  IUniswapV3Pool USDC_ETH_FEE500_UNISWAP_V3_POOL = IUniswapV3Pool(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);

  // Doodle Id's owned by 0x3111114529b97dAeF7A03FD10054dBBA2a085826 in BLOCK_FEB_12_2023:
  //    9878, 9785, 9592, 9107, 8064, 8038, 7754, 5268, 4631, 3989, 3643, 3206, 3110, 3104,
  //    2847, 2829, 2756, 2701, 2388, 2284, 1170, 476, 368
  address public DOODLE_WHALE = 0x3111114529b97dAeF7A03FD10054dBBA2a085826;

  // Merkle root for Id's 9878, 9785, 9592, 9107, 8064, 8038, 7754
  bytes32 DOODLE_WHALE_MERKLE_ROOT = 0x08f3eb3db4c2471f4f86ffafecd871a4e98a451613c9f437c1e8b7ffd54647cb;

  function setupAll () public {
    setupFork();
    setupContracts();
  }

  function setupContracts () public {
    setupTwapAdapter();
    setupTwapInverseAdapter();
    setupTestContracts();
  }

  function setupTwapAdapter () public {
    bytes memory code = vm.getCode('out/TwapAdapter.sol/TwapAdapter.json');
    address addr;
    assembly {
      addr := create(0, add(code, 0x20), mload(code))
      if iszero(addr) { revert (0, 0) }
    }
    twapAdapter = ITwapAdapter(addr);
  }

  function setupTwapInverseAdapter () public {
    bytes memory code = vm.getCode('out/TwapInverseAdapter.sol/TwapInverseAdapter.json');
    address addr;
    assembly {
      addr := create(0, add(code, 0x20), mload(code))
      if iszero(addr) { revert (0, 0) }
    }
    twapInverseAdapter = ITwapAdapter(addr);
  }

  function setupTestContracts () public {
    primitives = new Primitives01();
    mockPriceOracle = new MockPriceOracle();
    primitiveInternals = new MockPrimitiveInternals();
    tokenHelper = new MockTokenHelperInternals();
  }

  function setupFork () public {
    setupFork(BLOCK_JAN_25_2023);
  }

  function setupFork (uint blockNumber) public {
    mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"), blockNumber);
    vm.selectFork(mainnetFork);
  }

  function merkleProofForDoodle9107 () public returns (bytes32[] memory proof) {
    proof = new bytes32[](2);
    proof[0] = 0xab5623858b421d453a6ea4a4873a731863781529261bcc39f0160f476e1217a5;
    proof[1] = 0x0db851939cf734f5e0f3eafe70ccfbcb5509e5a8ade8c6ace7c1d1d1cfc841a5;
  }

  function invalidMerkleProof () public returns (bytes32[] memory proof) {
    proof = new bytes32[](3);
    proof[0] = 0xb0f1b2dc479b6baed16151fbb6cebd075c54c10d3e48a8e6c67334a3382a9c20;
    proof[1] = 0xab5623858b421d453a6ea4a4873a731863781529261bcc39f0160f476e1217a5;
    proof[2] = 0xc97ce8d1e731b4088a0419629557892a06ca5462a6083a0cf6e92a1d5a720b75;
  }

  function merkleMultiProofForDoodles_9592_7754_9107 () public returns (bytes32[] memory proof, bool[] memory proofFlags) {
    proof = new bytes32[](1);
    proof[0] = 0x0db851939cf734f5e0f3eafe70ccfbcb5509e5a8ade8c6ace7c1d1d1cfc841a5;

    proofFlags = new bool[](3);
    proofFlags[0] = true;
    proofFlags[1] = true;
    proofFlags[2] = false;
  }

}
