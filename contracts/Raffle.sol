// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Raffle {
    mapping(address => uint256) public lastParticipationTime;
    uint256 public constant COOLDOWN_PERIOD = 24 hours;

    event RaffleEntered(address indexed user, uint256 randomSeed, bytes32 indexed raffleId);

    function _enterRaffle() internal returns (uint256) {

        lastParticipationTime[msg.sender] = block.timestamp;

        // Generate a pseudo-random number between 0 and 9
        uint256 randomSeed =
            (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10);
        emit RaffleEntered(msg.sender, randomSeed, calculateRaffleId(msg.sender, block.timestamp));
        return randomSeed;
    }

    function calculateRaffleId(address user, uint256 timestamp) public pure returns (bytes32) {
        if (timestamp == 0) {
            return 0;
        }
        return keccak256(abi.encodePacked(user, timestamp));
    }

    function getRaffleInfo(address user) public view returns (bool canEnter, bytes32 lastRaffleId) {
        if (block.timestamp >= lastParticipationTime[user] + COOLDOWN_PERIOD) {
            return (true, calculateRaffleId(user, lastParticipationTime[user]));
        } else {
            return (false, calculateRaffleId(user, lastParticipationTime[user]));
        }
    }
}