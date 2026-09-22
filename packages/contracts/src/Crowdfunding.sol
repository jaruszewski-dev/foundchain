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
    mapping(uint256 => mapping(address => uint256)) public contributions;

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

    function contribute(uint256 campaignId) external payable {

        require(campaigns[campaignId].owner != address(0), "This campaign doesn't exist");
        require(campaigns[campaignId].deadline > block.timestamp, "This campaign already finished");
        require(msg.value > 0, "Amount has to be grater than 0");

        uint256 remainingGoal = campaigns[campaignId].goal - campaigns[campaignId].raised;

        require(msg.value <= remainingGoal, "Amount has to be lower or equal than remaining goal");

        campaigns[campaignId].raised += msg.value;
        contributions[campaignId][msg.sender] += msg.value;
    } 
}