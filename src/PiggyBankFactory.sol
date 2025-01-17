// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;

import {PiggyBank} from "./PiggyBank.sol";

library PiggyBankStructs {
    struct MinimalPgb {
        // is this really needed or can I just use an PiggyBank instance?
        bytes32 name;
        address beneficiary;
        uint256 lockupPeriodInSeconds;
        address contractAddress;
    }
    //tokenType
    //balance
}

contract PiggyBankFactory {
    //////////////////////
    // State Variables  //
    //////////////////////
    PiggyBank[] public s_listOfPiggyBanks; // still needed after beneficiaryToPgbs map?
    mapping(address => PiggyBank[]) public s_beneficiaryToPgbs;

    ///////////////////////////////
    // Public Functions          //
    ///////////////////////////////
    function createPiggyBankContract(
        bytes32 name,
        address beneficiary,
        uint256 lockupPeriodInSeconds,
        address[] memory allowedTokens
    ) public returns (PiggyBank) {
        PiggyBank piggyBank = new PiggyBank(name, beneficiary, lockupPeriodInSeconds, allowedTokens);
        s_listOfPiggyBanks.push(piggyBank);
        s_beneficiaryToPgbs[beneficiary].push(piggyBank);
        return piggyBank;
    }

    /////////////////////////////////////////////
    // Public & External View Functions        //
    /////////////////////////////////////////////
    function getPgbCount() public view returns (uint256) {
        return s_listOfPiggyBanks.length;
    }

    function getPiggyBankAddressByIndex(uint256 index) public view returns (address) {
        return address(s_listOfPiggyBanks[index]);
    }

    function getPiggyBanksByBeneficiary(address beneficiary) public view returns (PiggyBank[] memory) {
        return s_beneficiaryToPgbs[beneficiary];
    }

    // Why exactly do we need the struct? Only to be able call a deployed contract on the CLI?
    // Or is this also of use for our future frontend... (?)
    function getFirstPiggyBankStructByBeneficiary(address beneficiary)
        public
        view
        returns (PiggyBankStructs.MinimalPgb memory)
    {
        PiggyBank piggyBank = s_beneficiaryToPgbs[beneficiary][0];
        return PiggyBankStructs.MinimalPgb({
            name: piggyBank.getName(),
            beneficiary: beneficiary,
            lockupPeriodInSeconds: piggyBank.getLockupPeriod(),
            contractAddress: address(piggyBank)
        });
    }

    function getAllPiggyBankStructsByBeneficiary(address beneficiary)
        public
        view
        returns (PiggyBankStructs.MinimalPgb[] memory)
    {
        uint256 pgbCountForBeneficiary = s_beneficiaryToPgbs[beneficiary].length;

        // arrays in memory cannot be dynamically-sized, see Solidity docs
        PiggyBankStructs.MinimalPgb[] memory minimalPgbs = new PiggyBankStructs.MinimalPgb[](pgbCountForBeneficiary);

        for (uint256 i = 0; i < pgbCountForBeneficiary; i++) {
            PiggyBank piggyBank = s_beneficiaryToPgbs[beneficiary][i];
            minimalPgbs[i] = PiggyBankStructs.MinimalPgb({
                name: piggyBank.getName(),
                beneficiary: beneficiary,
                lockupPeriodInSeconds: piggyBank.getLockupPeriod(),
                contractAddress: address(piggyBank)
            });
        }
        return minimalPgbs;
    }
}
