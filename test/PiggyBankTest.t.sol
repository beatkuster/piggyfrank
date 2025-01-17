// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PiggyBank} from "../src/PiggyBank.sol";
import {DeployPiggyBank} from "../script/DeployPiggyBank.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract PiggyBankTest is Test {
    PiggyBank piggyBank;
    HelperConfig config;
    address beneficiary;
    address zchf;
    uint256 lockupPeriodInSeconds;

    // cheatcode to create a valid address
    address USER_BOB = makeAddr("tester_bob");
    address USER_ALICE = makeAddr("tester_alice");
    address TOKEN_NOT_IN_ALLOWLIST = makeAddr("TokenNotInAllowlist");

    uint256 constant STARTING_BALANCE = 1 ether;
    uint256 constant SEND_VALUE = 0.001 ether; // = 1e15 Wei
    uint256 constant DEPOSIT_INITAL = 799;
    uint256 constant BLOCK_TIMESTAMP_INITIAL = 1725184800; // 01.09.2024 10:00 UTC
    uint256 constant BLOCK_TIMESTAMP_PLUS1h = 1725188400; // 01.09.2024 11:00 UTC

    // modifiers
    modifier zchfDeposited() {
        // Bob deposits ZCHF into PiggyBank
        vm.startPrank(USER_BOB);
        ERC20Mock(zchf).approve(address(piggyBank), STARTING_BALANCE);
        piggyBank.deposit(USER_BOB, zchf, DEPOSIT_INITAL);
        vm.stopPrank();
        _;
    }

    // setUp() is executed before EACH test
    function setUp() external {
        // configuring testnet
        vm.warp(BLOCK_TIMESTAMP_INITIAL);
        vm.deal(USER_BOB, STARTING_BALANCE);

        // deploying new PiggyBank on testnet
        DeployPiggyBank deployPiggyBank = new DeployPiggyBank();
        (piggyBank, config) = deployPiggyBank.run();
        (beneficiary, zchf,) = config.activeNetworkConfig();
        lockupPeriodInSeconds = piggyBank.getLockupPeriod();

        // mint our test users some initial balance of ZCHF
        ERC20Mock(zchf).mint(USER_ALICE, STARTING_BALANCE);
        ERC20Mock(zchf).mint(USER_BOB, STARTING_BALANCE);

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
        // works because block time warped in setUp() function
        assertEq(piggyBank.getDeplomyentTimestamp(), BLOCK_TIMESTAMP_INITIAL);
    }

    function testDepositZchf() public {
        vm.startPrank(USER_BOB);
        ERC20Mock(zchf).approve(address(piggyBank), STARTING_BALANCE);
        piggyBank.deposit(USER_BOB, zchf, DEPOSIT_INITAL);
        vm.stopPrank();
        assertEq(piggyBank.getTokenBalanceOfDepositor(USER_BOB), 799);
    }

    function testDepositTokenNotInAllowlist() public {
        vm.startPrank(USER_BOB);
        vm.expectRevert();
        piggyBank.deposit(USER_BOB, TOKEN_NOT_IN_ALLOWLIST, DEPOSIT_INITAL);
        vm.stopPrank();
    }

    function testDepositOfMultipleDepositorsZchf() public zchfDeposited {
        // Bob deposits ZCHF into PiggyBank, see modifier
        // Alice deposits ZCHF into PiggyBank
        vm.startPrank(USER_ALICE);
        ERC20Mock(zchf).approve(address(piggyBank), STARTING_BALANCE);
        piggyBank.deposit(USER_ALICE, zchf, 100);
        vm.stopPrank();

        // Assert
        assertEq(piggyBank.getTokenBalanceOfPiggyBank(), DEPOSIT_INITAL + 100);
    }

    function testWithdrawZchf() public zchfDeposited {
        // Bob deposits ZCHF into PiggyBank, see modifier
        // Fast forward blocktime by 1h to allow withdrawal
        vm.warp(BLOCK_TIMESTAMP_PLUS1h);

        // Beneficiary withdraws ZCHF
        vm.startPrank(beneficiary);
        piggyBank.withdraw();
        vm.stopPrank();

        // Assert Beneficiary has received funds
        assertEq(ERC20Mock(zchf).balanceOf(beneficiary), DEPOSIT_INITAL);
    }

    function testWithdrawZchfFromMultipleDepositors() public {}

    function testWithdrawBeforeLockupPeriodElapsed() public zchfDeposited {
        // Bob deposits ZCHF into PiggyBank, see modifier
        // Fast forward blocktime less than lockup period to fail withdrawal
        vm.warp(BLOCK_TIMESTAMP_INITIAL + (lockupPeriodInSeconds - 5));

        // Assert revert when trying to withdraw
        vm.startPrank(beneficiary);
        vm.expectRevert();
        piggyBank.withdraw();
        vm.stopPrank();
    }

    function testOnlyBeneficiaryCanWithdrawZchf() public zchfDeposited {
        // Bob deposits ZCHF into PiggyBank, see modifier
        // Fast forward blocktime by 1h to allow withdrawal
        vm.warp(BLOCK_TIMESTAMP_PLUS1h);

        // Assert revert if Bob tries to withdraw ZCHF
        vm.startPrank(USER_BOB);
        vm.expectRevert();
        piggyBank.withdraw();
        vm.stopPrank();
    }

    function testLockupPeriodExpired() public view {
        // TODO: implement test case to see if expiration logic works
    }

    function testDepositEthWithoutFunctionCall() public view {
        // TODO: implement test case for people sending unwanted ETH to contract directly -> is this even possible?
    }
}
