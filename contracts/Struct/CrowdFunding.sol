// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

struct Funder {
    address addr;
    uint amount;
}

contract CrowdFunding {
    struct Campaign {
        address payable beneficairy;
        uint fundingGoal;
        uint numFunders;
        uint amount;
        mapping (uint => Funder) funders;
    }

    uint numCampaigns;
    mapping (uint => Campaign) campaigns;

    function newCampaign(address payable beneficairy, uint goal) public returns (uint campaignId) {
        campaignId = numCampaigns++;
        Campaign storage c = campaigns[campaignId];
        c.beneficairy = beneficairy;
        c.fundingGoal = goal;
    }

    function contribute(uint campingnId) public payable {
        Campaign storage c = campaigns[campingnId];
        c.funders[c.numFunders++] = Funder({addr: msg.sender, amount: msg.value});
        c.amount += msg.value;
    }

    function checkGoalReached(uint campaignId) public returns (bool reached) {
        Campaign storage c = campaigns[campaignId];
        if (c.amount < c.fundingGoal)
            return false;
        uint amount = c.amount;
        c.amount = 0;
        c.beneficairy.transfer(amount);
        return true;
    } 
}