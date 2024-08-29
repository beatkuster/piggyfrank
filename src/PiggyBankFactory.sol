// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PiggyBank} from "./PiggyBank.sol";

contract PiggyBankFactory {

    PiggyBank[] public listOfPiggyBanks;

    function createPiggyBankContract() public {
        listOfPiggyBanks.push(new PiggyBank());
    }
    
}