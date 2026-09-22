// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Crowdfunding.sol";

contract CrowdfundingTest is Test {

    Crowdfunding public crowdfunding;

    function setUp() public {
        crowdfunding = new Crowdfunding();
    }


    function testCreateCampaign() public {
        uint256 expectedDeadline = block.timestamp + 30 days;
        crowdfunding.createCampaign(1 ether, expectedDeadline);

        (uint256 goal, address owner, uint256 raised, uint256 deadline, bool claimed) = crowdfunding.campaigns(1);

        assertEq(crowdfunding.campaignCount(), 1);
        assertEq(goal, 1 ether);
        assertEq(owner, address(this));
        assertEq(raised, 0);
        assertEq(deadline, expectedDeadline);
        assertEq(claimed, false);
    }

    function testRevertWhenGoalTooSmall() public {
        vm.expectRevert("Goal is too small to start campaign");

        crowdfunding.createCampaign(0 ether, block.timestamp + 30 days);

        assertEq(crowdfunding.campaignCount(), 0);
    }

    function testRevertWhenDeadlineIsInThePast() public {
        vm.warp(30 days);
        vm.expectRevert("deadline must be in a future");

        crowdfunding.createCampaign(1 ether, block.timestamp - 1 days);

        assertEq(crowdfunding.campaignCount(), 0);
    }
}