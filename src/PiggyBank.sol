// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

error NotOwnerOrBeneficiary();

contract PiggyBank {
    bytes32 private immutable i_name;
    address private immutable i_beneficiary;
    uint256 private lockupPeriodInSeconds; // for PROD should be immutable as well...

    uint256 private immutable i_deploymentTimestamp;
    address private immutable i_owner;

    constructor(
        bytes32 _name,
        address _beneficiary,
        uint256 _lockupPeriodInSeconds
    ) {
        i_name = _name;
        i_beneficiary = _beneficiary;
        lockupPeriodInSeconds = _lockupPeriodInSeconds;
        i_deploymentTimestamp = block.timestamp;
        i_owner = msg.sender;
    }

    function deposit() public payable {
        // is something needed in here for ETH? no but transaction must call payable function, otherwise sending ETH reverts (as long no receive/fallback implemented)
        // TODO: also implement receive() & fallback()
        // TODO: list of donor addresses & amount?
        // how is this for ERC20 tokens?
    }

    function withdraw() public OnlyOwnerOrBeneficiary {
        // withdraw all funds to beneficiary address
        (bool callSuccess /* bytes memory dataReturned */, ) = payable(
            i_beneficiary
        ).call{value: address(this).balance}("");
        require(callSuccess, "Withdrawal failed");
        // TODO: the instance should also be removed from PiggyBankFactory book keeping
        // TODO: can we "undeploy/destroy" contract?
    }

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
