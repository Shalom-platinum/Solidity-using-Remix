pragma solidity ^0.4.17;

//"SPDX-License-Identifier: UNLISCENED"

contract CampaignFactory {
    address[] public deployedCampaigns;
    
    function createCampaign(uint minimum) public {
        address newCampaign = address(new Campaign(minimum, msg.sender));
        deployedCampaigns.push(newCampaign);

    }

    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}


contract Campaign {
    address public manager;
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalsCount;
        mapping(address => bool) approvals;
    }

    mapping(address => bool) public approvers;
    uint approversCount;
    uint public minimumContribution;
    uint numRequests;
    mapping (uint => Request) public requests;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    constructor(uint minimum, address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);

        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest (string memory description, uint value, address recipient) public restricted {
        Request storage r = requests[numRequests++];
            r.description= description;
            r.value = value;
            r.recipient = recipient;
            r.complete = false;
            r.approvalsCount= 0;
    }

    function approveRequest(uint index) public {
        Request storage r = requests[index];
        require(approvers[msg.sender]);
        require(!requests[index].approvals[msg.sender]);

        r.approvals[msg.sender] = true;
        r.approvalsCount++;
    }

    function finalizeRequest(uint index) public restricted{
        Request storage r = requests[index];
        require(!r.complete);
        require(r.approvalsCount > (approversCount/2));

        r.recipient.transfer(r.value); 
        r.complete = true;

    }

}