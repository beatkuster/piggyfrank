// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PiggyBank} from "../src/PiggyBank.sol";
import {PiggyBankFactory, PiggyBankStructs} from "../src/PiggyBankFactory.sol";
import {DeployPiggyBankFactory} from "../script/DeployPiggyBankFactory.s.sol";

contract PiggyBankFactoryTest is Test {
    address constant BENEFICIARY = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address constant ZCHF_TOKEN = 0x20D1c515e38aE9c345836853E2af98455F919637; // Base Mainnet -> should be mock?
    address[] allowedTokens = [ZCHF_TOKEN];

    PiggyBankFactory pgbFactory;

    function setUp() external {
        DeployPiggyBankFactory deployPgbFactory = new DeployPiggyBankFactory();
        pgbFactory = deployPgbFactory.run();
    }

    function testPgbDeployment() public {
        PiggyBank piggyBank = pgbFactory.createPiggyBankContract("MyTestPiggyBank1", BENEFICIARY, 900, allowedTokens);
        console.log("Created PiggyBank contract at: ", address(piggyBank));
    }

    function testPgbNotEmpty() public {
        PiggyBank piggyBank = pgbFactory.createPiggyBankContract("MyTestPiggyBank1", BENEFICIARY, 900, allowedTokens);
        address retrievedBeneficiary = piggyBank.getBeneficiary();
        assertEq(BENEFICIARY, retrievedBeneficiary);
        console.log("PiggyBank's beneficiary is: ", retrievedBeneficiary);
    }

    function testCreateMultiplePgbs() public pgbsCreated {
        PiggyBank[] memory piggyBanks = pgbFactory.getPiggyBanksByBeneficiary(BENEFICIARY);
        for (uint256 i = 0; i < piggyBanks.length; i++) {
            console.log("PiggyBank Number: ", i, " has Name: ", vm.toString(piggyBanks[i].getName()));
        }
    }

    function testCreateMultiplePgbsStruct() public pgbsCreated {
        // Arrange

        // Act
        PiggyBankStructs.MinimalPgb memory firstMinPgb = pgbFactory.getFirstPiggyBankStructByBeneficiary(BENEFICIARY);
        console.log("First MinimalPgb Name: ", vm.toString(firstMinPgb.name));

        // Assert
        assertEq(pgbFactory.getPgbCount(), 2);
        assertEq(bytes32("MyTestPiggyBank1"), firstMinPgb.name);
    }

    function testCreateAndRetrieveMultiplePgbsStruct() public pgbsCreated {
        // Arrange

        // Act
        PiggyBankStructs.MinimalPgb[] memory minimalPgbs = pgbFactory.getAllPiggyBankStructsByBeneficiary(BENEFICIARY);
        console.log("First Multi-MinimalPgb Name: ", vm.toString(minimalPgbs[0].name));
        console.log("First Multi-MinimalPgb Contract Address: ", vm.toString(minimalPgbs[0].contractAddress));

        // Assert
        assertEq(pgbFactory.getPgbCount(), 2);
        assertEq(bytes32("MyTestPiggyBank1"), minimalPgbs[0].name);
    }

    modifier pgbsCreated() {
        pgbFactory.createPiggyBankContract("MyTestPiggyBank1", BENEFICIARY, 900, allowedTokens);
        pgbFactory.createPiggyBankContract("TheBestPiggyBank", BENEFICIARY, 1200, allowedTokens);
        _;
    }
}
