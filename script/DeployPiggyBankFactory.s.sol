// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {PiggyBankFactory} from "../src/PiggyBankFactory.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployPiggyBankFactory is Script {
    function run() external returns (PiggyBankFactory, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        // Everything between start & stop gets broadcasted to the local testnet
        vm.startBroadcast();
        PiggyBankFactory piggyBankFactory = new PiggyBankFactory();
        vm.stopBroadcast();
        return (piggyBankFactory, helperConfig);
    }
}
