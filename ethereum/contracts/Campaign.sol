// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimumContribution) public{
        address newCampaign = address(new Campaign(minimumContribution, msg.sender));
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[] memory){
        return deployedCampaigns;
    }
}

contract Campaign {
    // Struct definition, this doesn't create an instance of Request, just a new type
    struct Request{
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    address public manager;
    uint public minimumContribution;
    uint numRequests;
    uint approversCount;
    mapping(uint => Request) public requests;

    /* 
     * We avoid an array because the looping can raise tremendous amounts
     * of gas for each transaction -> search time is Linear
     */
    // address[] public approvers;

    /* 
     * Using a mapping, the search time becomes Constant, no matter the
     * amount of elements, the time is always the same.
     */
    mapping(address => bool) public approvers;

    // Modifiers

    modifier restricted(){
        require(msg.sender == manager);
        _;
    }

    // Constructor

    constructor(uint minimum, address creator){
        manager = creator;
        minimumContribution = minimum;
    }

    // Functions

    /*
     * Allow to contribute to the campaign.
     * The payable keyword necessary in order to allow the contributor 
     * to send ether when calling this function
     */
    function contribute() public payable {
        require(msg.value > minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }

    /*
     * Allows a manager to create a spending request.
     *
     * memory, storage keywords: 
     * We have two separate types of reference:
     *
     *  - Sometimes reference where our contract stores data:
     *      storage: holds data between function calls, like a hard drive
     *          - Example: contract variables
     *      memory: Temporary place to store data, like RAM
     *          - Example: function arguments.
     *  - Sometimes reference how our solidity variables store values
     *      storage: it changes how a variable behaves, it can be used to allow
     *               the variable to point to a storage variable
     *               In this case we could say:
     *               address storage man = manager;
     *      memory: address memory man = manager;
     *              In this case, solidity makes a copy of manager and
     *              the man variable points to the copy.
     *  This is particularly useful on function arguments. If we pass an array to
     *  a function, we can decide if we want to modify the original or make a copy.   
     *
     */
    function createRequest(string memory description, uint value, address payable recipient) public restricted{
        // We use memory because we are creating a new instance. We are not trying 
        // to point to something in the storage.
        // All the value types must be initialized.
        Request storage newRequest = requests[numRequests++];
        newRequest.description = description;
        newRequest.value = value;
        newRequest.recipient = recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
        
        /* 
         * alternative...
         * Request(description, value, recipient, false);
         * Better not to use it, could accidentally forget or misplace a field...
         */
    }

    function approveRequest(uint index) public {
        Request storage request = requests[index];

        require(approvers[msg.sender]); // Check if it's a contributor to this campaign
        require(!request.approvals[msg.sender]); // check if hasn't voted

        request.approvals[msg.sender] = true; // Set to voted
        request.approvalCount++; // Increase approvals
    }
    
    function finalizeRequest(uint index) public restricted{
        Request storage request = requests[index];

        // At least >50% of the approvers must have approved the request
        require(request.approvalCount > (approversCount / 2)); 
        require(!request.complete);

        request.complete = true;
        request.recipient.transfer(request.value);
    }
}