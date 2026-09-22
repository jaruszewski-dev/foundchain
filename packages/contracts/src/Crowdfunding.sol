// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Crowdfunding {

    struct Campaign {
        uint256 goal;
        address owner;
        uint256 raised;
        uint256 deadline;
        bool claimed;
    }

    uint256 public campaignCount;

    mapping(uint256 => Campaign) public campaigns;

    function createCampaign(uint256 goal, uint256 deadline) external {

        require(goal > 0, "Goal is too small to start campaign");
        require(deadline > block.timestamp, "deadline must be in a future");

        campaignCount += 1;

        campaigns[campaignCount] = Campaign({
            goal: goal,
            owner: msg.sender,
            raised: 0,
            deadline: deadline,
            claimed: false
        });
    }
}