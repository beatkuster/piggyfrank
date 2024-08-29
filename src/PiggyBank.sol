// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract PiggyBank {
    
    address private paybackAddress;
    uint256 private deploymentTimestamp;
    uint256 private lockupPeriodInSeconds;

    constructor() {
        deploymentTimestamp = block.timestamp;
    }

    function getDeplomyentTimestamp() public view returns(uint256) {
        return deploymentTimestamp;
    }

    function getLockupPeriod() public view returns(uint256) {
        return lockupPeriodInSeconds;
    }

    function setLockupPeriod(uint256 _lockupPeriodInSeconds) public {
        lockupPeriodInSeconds = _lockupPeriodInSeconds;
    }

    function hasLockupPeriodExpired() public view returns(bool) {
        uint256 currentTimestamp = block.timestamp;
        return currentTimestamp >= deploymentTimestamp + lockupPeriodInSeconds;
    }

    function getRemainingLockupPeriod() public view returns(int256) {
        uint256 currentTimestamp = block.timestamp;
        // casting values before calculation to prevent underflow
        return int256((deploymentTimestamp + lockupPeriodInSeconds)) - int256(currentTimestamp);
    }

}