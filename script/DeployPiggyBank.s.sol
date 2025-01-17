// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {PiggyBank} from "../src/PiggyBank.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DeployPiggyBank is Script {
    // Hardcoded values but this script will never be used for mainnet -> I guess?
    // On mainnet, use DeployPiggyBankFactory and then deploy single contracts through the factory...
    uint256 constant LOCKUP_PERIOD_IN_SECONDS = 900;
    bytes32 constant NAME = "MyBelovedPiggyBank";

    function run() external returns (PiggyBank, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        (address beneficiary, address zchf, address usdc,) = helperConfig.activeNetworkConfig();

        address[] memory allowedTokens = new address[](2);
        allowedTokens[0] = zchf;
        allowedTokens[1] = usdc;

        // Everything between start & stop gets broadcasted to the local testnet
        vm.startBroadcast();
        PiggyBank piggyBank = new PiggyBank(NAME, beneficiary, LOCKUP_PERIOD_IN_SECONDS, allowedTokens);
        vm.stopBroadcast();
        return (piggyBank, helperConfig);
    }
}
