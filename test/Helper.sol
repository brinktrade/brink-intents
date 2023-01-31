// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "uniswap-v3-core/Interfaces/IUniswapV3Pool.sol";
import "openzeppelin/utils/Strings.sol";
import "../src/Interfaces/ITwapAdapter.sol";
import "../src/TokenHelper/TokenHelper.sol";
import "../src/Primatives/Primatives01.sol";
import "./Mocks/MockPriceOracle.sol";

contract Helper is Test {

  ITwapAdapter public twapAdapter;
  Primatives01 public primatives;
  MockPriceOracle public mockPriceOracle;

  // TWAP price for interval 1000s - 0s: ~0.000645 USDC/ETH, 1549.574 ETH/USDC
  uint256 public MAGIC_TWAP_PRICE_USDC_ETH_1000_0 = 51128994256875305254096266510654458404;
  
  // TWAP price for interval 2000s - 1000s: ~0.000646 USDC/ETH, 1547.871 ETH/USDC
  uint256 public MAGIC_TWAP_PRICE_USDC_ETH_2000_1000 = 51185264279942680916728141158213785257;

  uint256 public defaultBlock = 16_485_101;
  uint256 public mainnetFork;

  address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  Token public WETH_Token = Token(TokenStandard.ERC20, WETH, 0x0, 0);
  Token public USDC_Token = Token(TokenStandard.ERC20, USDC, 0x0, 0);

  IUniswapV3Pool USDC_ETH_FEE500_UNISWAP_V3_POOL = IUniswapV3Pool(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);

  function setupAll () public {
    setupFork();
    setupContracts();
  }

  function setupContracts () public {
    setupTwapAdapter();
    setupTestContracts();
  }

  function setupTwapAdapter () public {
    bytes memory code = vm.getCode('out/TwapAdapter01.sol/TwapAdapter01.json');
    address addr;
    assembly {
      addr := create(0, add(code, 0x20), mload(code))
      if iszero(addr) { revert (0, 0) }
    }
    twapAdapter = ITwapAdapter(addr);
  }

  function setupTestContracts () public {
    primatives = new Primatives01();
    mockPriceOracle = new MockPriceOracle();
  }

  function setupFork () public {
    setupFork(defaultBlock);
  }

  function setupFork (uint blockNumber) public {
    mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"), blockNumber);
    vm.selectFork(mainnetFork);
  }

}
