//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0 <0.9.0;

contract CrowdFuncding{

    mapping(address => uint) public Contributors;
    address public Manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raiseAmount;
    uint public noOfControbutors;

    //constructor for contribution
    constructor(uint _targer, uint _deadline) public{
        target = _targer;
        deadline = block.timestamp + _deadline; // 1hr = 60*60 = 3600
        minContribution = 100 wei;
        Manager = msg.sender;
    }

    struct Request{
        string description; // it tells what is the request
        address payable recipient; //the recipient of the transfer money through request
        uint value; //how much money needed to transfer in the request
        bool isComplted; //is the request complted
        uint noOfVotors; //if the no of votors is less than half of the total contributions = money will transfer
        mapping(address => bool) votors;
    }

    mapping(uint => Request) public requests;
    uint public num_of_request;

    //function for sending Ether
    function sendEth() public payable{
        require(block.timestamp < deadline, "Deadline has beed passed");
        require(msg.value >= 100 wei, "Minimun Contribution not matched");

        if(Contributors[msg.sender] == 0){
            noOfControbutors++;
        }

        Contributors[msg.sender]= msg.value; //increase the amount sent by the user
        raiseAmount += msg.value; //increse the overall value
    }

    //function to get the contribution balance
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    //function for refund
    function Refund() public{
        require(block.timestamp > deadline && raiseAmount < target);
        require(Contributors[msg.sender] > 0); //if a person who intialize the refund, must be a contributor
        address payable user = payable(msg.sender);
        user.transfer(Contributors[msg.sender]);
        Contributors[msg.sender] = 0;
    }

    //function for make a Request
    function makeRequest(string memory _description, address payable _recipient, uint _value) public{
        require(msg.sender == Manager, "Only Manager can make request");
        Request storage new_Request = requests[num_of_request];
        num_of_request++;
        new_Request.description = _description;
        new_Request.recipient = _recipient;
        new_Request.value = _value;
        new_Request.isComplted = false;
        new_Request.noOfVotors = 0;
    }

    //function for voting
    function Voting(uint _num_of_requests) public {
        require(Contributors[msg.sender] > 0, "You are not a contributor");
        Request storage this_Request = requests[_num_of_requests];
        require(this_Request.votors[msg.sender] == false, "You have already voted");
        this_Request.votors[msg.sender] = true;
        this_Request.noOfVotors++;
    }

    //function for making a payment
    function makePayment(uint _num_of_request) public{
        require(raiseAmount >= target);
        require(msg.sender == Manager, "Only manager can call this function");
        Request storage this_Request = requests[_num_of_request];
        require(this_Request.isComplted == false, "The Payment is already Done");
        require(this_Request.noOfVotors > noOfControbutors/2, "Majority does not support"); //it checks the voting and tell if the majority upport or not
        this_Request.recipient.transfer(this_Request.value);
        this_Request.isComplted = true;
    }
}