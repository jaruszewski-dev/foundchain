// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Crowdfunding.sol";

contract CrowdfundingTest is Test {

    Crowdfunding public crowdfunding;

    function setUp() public {
        crowdfunding = new Crowdfunding();
        vm.deal(address(this), 10 ether);
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

    function testContributeToCampaign() public {
        crowdfunding.createCampaign(5 ether, block.timestamp + 30 days);
        crowdfunding.contribute{value: 1 ether}(1);

        (,, uint256 raised,,) = crowdfunding.campaigns(1);

        assertEq(raised, 1 ether);
        assertEq(crowdfunding.contributions(1, address(this)), 1 ether);
    }

    function testRevertIfCampaignMissing() public {
        vm.expectRevert("This campaign doesn't exist");

        crowdfunding.contribute{value: 1 ether}(1);

        assertEq(crowdfunding.campaignCount(), 0);
    }

    function testRevertIfCampaignFinished() public {
        uint256 deadline = block.timestamp + 1 days;

        crowdfunding.createCampaign(5 ether, deadline);
        vm.warp(deadline + 1 days);

        vm.expectRevert("This campaign already finished");
        crowdfunding.contribute{value: 1 ether}(1);

        (,, uint256 raised, uint256 savedDeadline,) = crowdfunding.campaigns(1);

        assertEq(deadline, savedDeadline);
        assertEq(raised, 0);
    }

    function testRevertIfZeroContribution() public {
        crowdfunding.createCampaign(5 ether, block.timestamp + 1 days);

        vm.expectRevert("Amount has to be greater than 0");
        crowdfunding.contribute{value: 0}(1);

        (,, uint256 raised ,,) = crowdfunding.campaigns(1);

        assertEq(raised, 0);
        assertEq(crowdfunding.contributions(1, address(this)), 0);
    }

    function testRevertOnExcessContribution() public {
        crowdfunding.createCampaign(5 ether, block.timestamp + 1 days);

        vm.expectRevert("Amount has to be lower or equal than remaining goal");
        crowdfunding.contribute{value: 6 ether}(1);

        (,, uint256 raised ,,) = crowdfunding.campaigns(1);

        assertEq(raised, 0);
        assertEq(crowdfunding.contributions(1, address(this)), 0);
    }
}