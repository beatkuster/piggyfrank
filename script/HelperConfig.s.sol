// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address zchf;
        uint256 deployerKey;
    }

    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

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
        return NetworkConfig({
            zchf: address(0),
            deployerKey: vm.envUint("PRIVATE_KEY") // what does this do?
        });
    }

    function getBaseSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            zchf: address(0),
            deployerKey: vm.envUint("PRIVATE_KEY") // what does this do?
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
        // Check to see if we set an active network config
        if (activeNetworkConfig.zchf != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        ERC20Mock zchfMock = new ERC20Mock("Frankencoin", "ZCHF", msg.sender, 1000e8);
        vm.stopBroadcast();

        return NetworkConfig({zchf: address(zchfMock), deployerKey: DEFAULT_ANVIL_PRIVATE_KEY});
    }
}
