// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PiggyBank} from "../src/PiggyBank.sol";
import {PiggyBankFactory} from "../src/PiggyBankFactory.sol";
import {DeployPiggyBankFactory} from "../script/DeployPiggyBankFactory.s.sol";

contract PiggyBankFactoryTest is Test {
    address constant BENEFICIARY = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    PiggyBankFactory pgbFactory;

    function setUp() external {
        DeployPiggyBankFactory deployPgbFactory = new DeployPiggyBankFactory();
        pgbFactory = deployPgbFactory.run();
    }

    function testPgbDeployment() public {
        PiggyBank piggyBank = pgbFactory.createPiggyBankContract(
            "MyTestPiggyBank1",
            BENEFICIARY,
            900
        );
        console.log("Created PiggyBank contract at: ", address(piggyBank));
    }

    function testPgbNotEmpty() public {
        PiggyBank piggyBank = pgbFactory.createPiggyBankContract(
            "MyTestPiggyBank2",
            BENEFICIARY,
            900
        );
        address retrievedBeneficiary = piggyBank.getBeneficiary();
        assertEq(BENEFICIARY, retrievedBeneficiary);
        console.log("PiggyBank's beneficiary is: ", retrievedBeneficiary);
    }
}
