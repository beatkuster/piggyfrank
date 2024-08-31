// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

error NotOwnerOrBeneficiary();

contract PiggyBank {
    uint256 private immutable i_deploymentTimestamp;
    address private immutable i_owner;
    address private immutable i_beneficiary;
    uint256 private lockupPeriodInSeconds; // for PROD should be immutable as well...

    constructor(address _beneficiary, uint256 _lockupPeriodInSeconds) {
        i_deploymentTimestamp = block.timestamp;
        i_owner = msg.sender;
        i_beneficiary = _beneficiary;
        lockupPeriodInSeconds = _lockupPeriodInSeconds;
    }

    function deposit() public payable {
        // is something needed in here?
        // if yes, also implement receive() & fallback()
    }

    function withdraw() public OnlyOwnerOrBeneficiary {
        // withdraw all funds to beneficiary address
        (bool callSuccess /* bytes memory dataReturned */, ) = payable(
            i_beneficiary
        ).call{value: address(this).balance}("");
        require(callSuccess, "Withdrawal failed");
    }

    function getDeplomyentTimestamp() public view returns (uint256) {
        return i_deploymentTimestamp;
    }

    function getLockupPeriod() public view returns (uint256) {
        return lockupPeriodInSeconds;
    }

    function setLockupPeriod(uint256 _lockupPeriodInSeconds) public {
        lockupPeriodInSeconds = _lockupPeriodInSeconds;
    }

    function hasLockupPeriodExpired() public view returns (bool) {
        uint256 currentTimestamp = block.timestamp;
        return
            currentTimestamp >= i_deploymentTimestamp + lockupPeriodInSeconds;
    }

    function getRemainingLockupPeriod() public view returns (int256) {
        uint256 currentTimestamp = block.timestamp;
        // casting values before calculation to prevent underflow
        return
            int256((i_deploymentTimestamp + lockupPeriodInSeconds)) -
            int256(currentTimestamp);
    }

    modifier OnlyOwnerOrBeneficiary() {
        if (msg.sender != i_owner && msg.sender != i_beneficiary) {
            revert NotOwnerOrBeneficiary();
        }
        _;
    }
}
