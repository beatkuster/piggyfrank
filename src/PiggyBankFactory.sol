// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PiggyBank} from "./PiggyBank.sol";

// TODO: make beneficiaryToPgb save for multiple PiggyBanks for same beneficiary

contract PiggyBankFactory {
    PiggyBank[] public listOfPiggyBanks; // still needed after beneficiaryToPgb map?
    mapping(address => PiggyBank) public beneficiaryToPgb;

    struct MinimalPgb {
        // is this really needed or can I just use an PiggyBank instance?
        bytes32 name;
        address beneficiary;
        uint256 lockupPeriodInSeconds;
        address contractAddress;
        //tokenType
        //balance
    }

    function createPiggyBankContract(
        bytes32 name,
        address beneficiary,
        uint256 lockupPeriodInSeconds
    ) public returns (PiggyBank) {
        PiggyBank piggyBank = new PiggyBank(
            name,
            beneficiary,
            lockupPeriodInSeconds
        );
        listOfPiggyBanks.push(piggyBank);
        beneficiaryToPgb[beneficiary] = piggyBank;
        return piggyBank;
    }

    function getPgbCount() public view returns (uint256) {
        return listOfPiggyBanks.length;
    }

    function getPiggyBankAddressByIndex(
        uint256 index
    ) public view returns (address) {
        return address(listOfPiggyBanks[index]);
    }

    function getPiggyBankByBeneficiary(
        address beneficiary
    ) public view returns (MinimalPgb memory) {
        PiggyBank piggyBank = beneficiaryToPgb[beneficiary];
        return
            MinimalPgb({
                name: piggyBank.getName(),
                beneficiary: beneficiary,
                lockupPeriodInSeconds: piggyBank.getLockupPeriod(),
                contractAddress: address(piggyBank)
            });
    }
}
