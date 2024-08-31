// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PiggyBank} from "./PiggyBank.sol";

contract PiggyBankFactory {
    PiggyBank[] public listOfPiggyBanks;

    function createPiggyBankContract(
        address beneficiary,
        uint256 lockupPeriodInSeconds
    ) public {
        //PiggyBank piggyBank = new PiggyBank(beneficiary);
        listOfPiggyBanks.push(
            new PiggyBank(beneficiary, lockupPeriodInSeconds)
        );
    }

    function getPiggyBankContractAddress(
        uint256 index
    ) public view returns (address) {
        //PiggyBank piggyBank = listOfPiggyBanks[listIndex];
        return address(listOfPiggyBanks[index]);
    }
}
