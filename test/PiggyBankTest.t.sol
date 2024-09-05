// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PiggyBank} from "../src/PiggyBank.sol";
import {DeployPiggyBank} from "../script/DeployPiggyBank.s.sol";

contract PiggyBankTest is Test {
    PiggyBank piggyBank;

    // cheatcode to create a valid address
    address USER = makeAddr("tester");

    uint256 constant STARTING_BALANCE = 1 ether;
    uint256 constant SEND_VALUE = 0.001 ether; // = 1e15 Wei
    uint256 constant BLOCK_TIMESTAMP = 1725184800; // 01.09.2024 10:00 UTC

    // setUp() is executed before EACH test
    function setUp() external {
        // configuring testnet
        vm.warp(1725184800);
        vm.deal(USER, STARTING_BALANCE);

        // deploying new PiggyBank on testnet
        DeployPiggyBank deployPiggyBank = new DeployPiggyBank();
        piggyBank = deployPiggyBank.run();

        console.log("Finished execution of setUp()");
    }

    function testOwnerIsMsgSender() public view {
        /* 
        console.log("address(this) is: ", address(this));
        console.log("address(piggyBank) is: ", address(piggyBank));
        console.log("USER is: ", USER);
        console.log("msg.sender is: ", msg.sender);
        console.log("piggyBank.i_owner is: ", piggyBank.getOwner());
        */
        assertEq(piggyBank.getOwner(), msg.sender);
        // is this a reliable test? not 100% clear where msg.sender is coming from...
    }

    function testGetDeploymentTimestamp() public view {
        assertEq(piggyBank.getDeplomyentTimestamp(), BLOCK_TIMESTAMP);
    }

    function testDeposit() public {
        //console.log("Balance before deposit: ", address(piggyBank).balance);
        piggyBank.deposit{value: SEND_VALUE}();
        //console.log("Balance after deposit: ", address(piggyBank).balance);
        assertEq(address(piggyBank).balance, SEND_VALUE);
    }

    function testWithdrawAsBeneficiary() public {
        piggyBank.deposit{value: SEND_VALUE}();
        piggyBank.deposit{value: 2 * SEND_VALUE}();
        vm.prank(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        piggyBank.withdraw();
        assertEq(
            address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC).balance,
            3 * SEND_VALUE
        );
    }

    function testOnlyBeneficiaryCanWithdraw() public {
        piggyBank.deposit{value: SEND_VALUE}();
        vm.expectRevert();
        vm.prank(address(5));
        piggyBank.withdraw();
    }

    function testLockupPeriodExpired() public view {
        // TODO: implement test case to see if expiration logic works
    }

    function testDepositEthWithoutFunctionCall() public view {
        // TODO: implement test case for people sending ETH to contract directly without calling deposit()
    }
}
