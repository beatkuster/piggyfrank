// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address beneficiary;
        address zchf;
        address usdc;
    }
    //uint256 deployerKey;

    // Ethereum Sepolia

    // Base Sepolia
    address constant BASE_USDC = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;
    address constant BKEY_ETH_DEV_2 = 0xb726F2c1C7Df58ff1c4309Fb91162F14EF3cbbAb;

    // Anvil
    uint256 constant DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address constant ANVIL_BENEFICIARY = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 84532) {
            activeNetworkConfig = getBaseSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({beneficiary: address(0), zchf: address(0), usdc: address(0)});
    }

    function getBaseSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({beneficiary: BKEY_ETH_DEV_2, zchf: address(0), usdc: BASE_USDC});
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
        // Check to see if we set an active network config
        if (activeNetworkConfig.zchf != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        ERC20Mock zchfMock = new ERC20Mock("Frankencoin", "ZCHF", 18, msg.sender, 1000e8);
        ERC20Mock usdcMock = new ERC20Mock("USDC", "USDC", 6, msg.sender, 1000e8);
        vm.stopBroadcast();

        return NetworkConfig({beneficiary: ANVIL_BENEFICIARY, zchf: address(zchfMock), usdc: address(usdcMock)});
    }
}
