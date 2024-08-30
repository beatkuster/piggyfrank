// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {PiggyBank} from "../src/PiggyBank.sol";

contract DeployPiggyBank is Script {
    function run() external returns (PiggyBank) {
        address beneficiary = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        // Everything between start & stop gets broadcasted to the local testnet
        vm.startBroadcast();
        PiggyBank piggyBank = new PiggyBank(beneficiary);
        vm.stopBroadcast();
        return piggyBank;
    }
}
