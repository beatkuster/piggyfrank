// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PiggyBank} from "../src/PiggyBank.sol";
import {PiggyBankFactory, PiggyBankStructs} from "../src/PiggyBankFactory.sol";
import {DeployPiggyBankFactory} from "../script/DeployPiggyBankFactory.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract PiggyBankFactoryTest is Test {
    PiggyBankFactory pgbFactory;
    HelperConfig config;
    address beneficiary;
    address zchf;
    address usdc;
    address[] allowedTokens;

    function setUp() external {
        DeployPiggyBankFactory deployPgbFactory = new DeployPiggyBankFactory();
        (pgbFactory, config) = deployPgbFactory.run();
        (beneficiary, zchf, usdc) = config.activeNetworkConfig();
        allowedTokens = [zchf, usdc];
    }

    function testPgbDeployment() public {
        PiggyBank piggyBank = pgbFactory.createPiggyBankContract("MyTestPiggyBank1", beneficiary, 900, allowedTokens);
        console.log("Created PiggyBank contract at: ", address(piggyBank));
    }

    function testPgbNotEmpty() public {
        PiggyBank piggyBank = pgbFactory.createPiggyBankContract("MyTestPiggyBank1", beneficiary, 900, allowedTokens);
        address retrievedBeneficiary = piggyBank.getBeneficiary();
        assertEq(beneficiary, retrievedBeneficiary);
        console.log("PiggyBank's beneficiary is: ", retrievedBeneficiary);
    }

    function testCreateMultiplePgbs() public pgbsCreated {
        PiggyBank[] memory piggyBanks = pgbFactory.getPiggyBanksByBeneficiary(beneficiary);
        for (uint256 i = 0; i < piggyBanks.length; i++) {
            console.log("PiggyBank Number: ", i, " has Name: ", vm.toString(piggyBanks[i].getName()));
        }
    }

    function testCreateMultiplePgbsStruct() public pgbsCreated {
        // Arrange

        // Act
        PiggyBankStructs.MinimalPgb memory firstMinPgb = pgbFactory.getFirstPiggyBankStructByBeneficiary(beneficiary);
        console.log("First MinimalPgb Name: ", vm.toString(firstMinPgb.name));

        // Assert
        assertEq(pgbFactory.getPgbCount(), 2);
        assertEq(bytes32("MyTestPiggyBank1"), firstMinPgb.name);
    }

    function testCreateAndRetrieveMultiplePgbsStruct() public pgbsCreated {
        // Arrange

        // Act
        PiggyBankStructs.MinimalPgb[] memory minimalPgbs = pgbFactory.getAllPiggyBankStructsByBeneficiary(beneficiary);
        console.log("First Multi-MinimalPgb Name: ", vm.toString(minimalPgbs[0].name));
        console.log("First Multi-MinimalPgb Contract Address: ", vm.toString(minimalPgbs[0].contractAddress));

        // Assert
        assertEq(pgbFactory.getPgbCount(), 2);
        assertEq(bytes32("MyTestPiggyBank1"), minimalPgbs[0].name);
    }

    modifier pgbsCreated() {
        pgbFactory.createPiggyBankContract("MyTestPiggyBank1", beneficiary, 900, allowedTokens);
        pgbFactory.createPiggyBankContract("TheBestPiggyBank", beneficiary, 1200, allowedTokens);
        _;
    }
}
