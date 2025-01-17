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
    mapping(address => uint256) private s_depositorsAndBalance;

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
        // is something needed in here for ETH? no but transaction must call payable function, otherwise sending ETH reverts (as long no receive/fallback implemented)
        // TODO: also implement receive() & fallback()
        // TODO: list of donor addresses & amount
        ////////////////
        // Ether: only modifier payable is required -> remove again as we only accept preapproved ERC20 tokens?
        ///////////////
        // ERC20
        if (msg.value == 0) {
            require(isAllowedToken(token), "ERC20 Token not on allowlist");
            require(IERC20(token).transferFrom(depositor, address(this), amount), "ERC20 Token transfer failed");
            s_depositorsAndBalance[depositor] += amount;
        }
    }

    function withdraw() public OnlyOwnerOrBeneficiary {
        // withdraw all funds to beneficiary address
        (bool callSuccess, /* bytes memory dataReturned */ ) =
            payable(i_beneficiary).call{value: address(this).balance}("");
        require(callSuccess, "Withdrawal failed");
        // TODO: the instance should also be removed from PiggyBankFactory book keeping
        // TODO: can we "undeploy/destroy" contract?
    }

    function setLockupPeriod(uint256 _lockupPeriodInSeconds) public {
        lockupPeriodInSeconds = _lockupPeriodInSeconds;
    }

    function isAllowedToken(address token) public view returns (bool) {
        // Check if the provided token address is in the acceptedTokens array
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

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getBalanceOfDepositor(address depositor) public view returns (uint256) {
        return s_depositorsAndBalance[depositor];
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
