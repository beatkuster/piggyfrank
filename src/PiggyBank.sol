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

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PiggyBank {
    //////////////////////
    // Errors           //
    //////////////////////
    error NotOwnerOrBeneficiary();

    //////////////////////
    // State Variables  //
    //////////////////////
    bytes32 private immutable i_name;
    address private immutable i_beneficiary;
    uint256 private lockupPeriodInSeconds; // for PROD should be immutable as well...

    uint256 private immutable i_deploymentTimestamp;
    address private immutable i_owner;

    address[] private s_allowedTokens;

    // s_balance is redundant because contained in s_depositorsAndBalance below?
    // yes, but calculating it would require address[] of all depositors... -> do I want to track this?
    mapping(address token => uint256 balance) private s_balance;
    mapping(address user => mapping(address token => uint256 balance)) private s_depositorsAndBalance; //depositorToTokenBalance

    //////////////////////
    // Modifiers        //
    //////////////////////
    modifier OnlyOwnerOrBeneficiary() {
        if (msg.sender != i_owner && msg.sender != i_beneficiary) {
            revert NotOwnerOrBeneficiary();
        }
        _;
    }

    //////////////////////
    // Functions        //
    //////////////////////
    constructor(bytes32 _name, address _beneficiary, uint256 _lockupPeriodInSeconds, address[] memory _allowedTokens) {
        i_name = _name;
        i_beneficiary = _beneficiary;
        lockupPeriodInSeconds = _lockupPeriodInSeconds;
        i_deploymentTimestamp = block.timestamp;
        i_owner = msg.sender;
        s_allowedTokens = _allowedTokens;
    }

    ///////////////////////////////
    // Public Functions          //
    ///////////////////////////////
    function deposit(address depositor, address token, uint256 amount) public payable {
        require(isAllowedToken(token), "ERC20 Token not in allowlist");
        require(IERC20(token).transferFrom(depositor, address(this), amount), "ERC20 Token transfer failed");
        s_depositorsAndBalance[depositor][token] += amount;
        s_balance[token] += amount;
    }

    function withdraw() public OnlyOwnerOrBeneficiary {
        require(hasLockupPeriodExpired(), "Lockup Period has not expired yet");
        // check all allowed tokens for balance and send back to beneficiary address
        for (uint256 i = 0; i < s_allowedTokens.length; i++) {
            address token = s_allowedTokens[i];
            uint256 amount = s_balance[token];
            if (amount > 0) {
                require(IERC20(token).transfer(i_beneficiary, amount), "ERC20 Token transfer failed");
            }
        }

        // TODO: the instance should also be removed from PiggyBankFactory book keeping
        // TODO: can we "undeploy/destroy" contract?
    }

    function setLockupPeriod(uint256 _lockupPeriodInSeconds) public {
        lockupPeriodInSeconds = _lockupPeriodInSeconds;
    }

    function isAllowedToken(address token) public view returns (bool) {
        // Check if the provided token address is in the allowedTokens array
        for (uint256 i = 0; i < s_allowedTokens.length; i++) {
            if (s_allowedTokens[i] == token) {
                return true;
            }
        }
        return false;
    }

    /////////////////////////////////////////////
    // Public & External View Functions        //
    /////////////////////////////////////////////
    function getName() public view returns (bytes32) {
        return i_name;
    }

    function getDeplomyentTimestamp() public view returns (uint256) {
        return i_deploymentTimestamp;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getBeneficiary() public view returns (address) {
        return i_beneficiary;
    }

    function getTokenBalanceOfPiggyBank() public view returns (uint256 totalBalance) {
        // loop through each deposited token and get deposited amount
        // we can summarize different tokens because only CHF stablecoins allowed
        for (uint256 i = 0; i < s_allowedTokens.length; i++) {
            address token = s_allowedTokens[i];
            uint256 amount = s_balance[token];
            totalBalance += amount;
        }
        return totalBalance;
    }

    function getChfBalanceOfPiggyBank() public view {
        // TODO: same as getTokenBalanceOfPiggyBank() but
        // add oracle call to get CHF market value for each token
    }

    function getTokenBalanceOfDepositor(address depositor) public view returns (uint256 balanceOfDepositor) {
        // loop through each deposited token and get deposited amount for a certain depositor
        for (uint256 i = 0; i < s_allowedTokens.length; i++) {
            address token = s_allowedTokens[i];
            uint256 amount = s_depositorsAndBalance[depositor][token];
            balanceOfDepositor += amount;
        }
        return balanceOfDepositor;
    }

    function getChfBalanceOfDepositor() public view {
        // TODO: same as getTokenBalanceOfDepositor() but
        // add oracle call to get CHF market value for each token
    }

    function getLockupPeriod() public view returns (uint256) {
        return lockupPeriodInSeconds;
    }

    function getAllowedTokens() public view returns (address[] memory) {
        return s_allowedTokens;
    }

    function hasLockupPeriodExpired() public view returns (bool) {
        uint256 currentTimestamp = block.timestamp;
        return currentTimestamp >= i_deploymentTimestamp + lockupPeriodInSeconds;
    }

    function getRemainingLockupPeriod() public view returns (int256) {
        uint256 currentTimestamp = block.timestamp;
        // casting values before calculation to prevent underflow
        return int256((i_deploymentTimestamp + lockupPeriodInSeconds)) - int256(currentTimestamp);
    }
}
