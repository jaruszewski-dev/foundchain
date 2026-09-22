// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Crowdfunding.sol";

contract CrowdfundingTest is Test {

    Crowdfunding public crowdfunding;

    function setUp() public {
        crowdfunding = new Crowdfunding();
    }


    function testCampainCountIncrement() public {
        crowdfunding.createCampaign(1 ether, block.timestamp + 30 days);

        assertEq(crowdfunding.campaignCount(), 1);

        crowdfunding.createCampaign(2 ether, block.timestamp + 60 days);

        assertEq(crowdfunding.campaignCount(), 2);
    }
}