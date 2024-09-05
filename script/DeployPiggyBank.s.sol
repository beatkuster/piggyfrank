// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {PiggyBank} from "../src/PiggyBank.sol";

contract DeployPiggyBank is Script {
    function run() external returns (PiggyBank) {
        // Hardcoded values + address that exists only on local testnet but this script will never be used for mainnet
        // On mainnet, use DeployPiggyBankFactory and then deploy single contracts through the factory...
        address beneficiary = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        uint256 lockupPeriodInSeconds = 900;
        bytes32 name = "MyBelovedPiggyBank";
        // Everything between start & stop gets broadcasted to the local testnet
        vm.startBroadcast();
        PiggyBank piggyBank = new PiggyBank(
            name,
            beneficiary,
            lockupPeriodInSeconds
        );
        vm.stopBroadcast();
        return piggyBank;
    }
}
