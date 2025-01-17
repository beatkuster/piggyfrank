// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {PiggyBank} from "../src/PiggyBank.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DeployPiggyBank is Script {
    // Hardcoded values + address that exists only on local testnet but this script will never be used for mainnet
    // On mainnet, use DeployPiggyBankFactory and then deploy single contracts through the factory...
    address constant BENEFICIARY = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    uint256 constant LOCKUP_PERIOD_IN_SECONDS = 900;
    bytes32 constant NAME = "MyBelovedPiggyBank";

    function run() external returns (PiggyBank, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        (address zchf,) = helperConfig.activeNetworkConfig();
        // why can I not use "address[] memory allowedTokens = [zchf]" ?
        // check Solidity docs regarding array init
        address[] memory allowedTokens = new address[](1);
        allowedTokens[0] = zchf;

        // Everything between start & stop gets broadcasted to the local testnet
        vm.startBroadcast();
        PiggyBank piggyBank = new PiggyBank(NAME, BENEFICIARY, LOCKUP_PERIOD_IN_SECONDS, allowedTokens);
        vm.stopBroadcast();
        return (piggyBank, helperConfig);
    }
}
