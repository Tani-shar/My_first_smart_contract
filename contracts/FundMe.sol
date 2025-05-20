// get funds from user
// withdraw funds 
// set a minimum fudinf

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    uint256 public minimumUsd = 50;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    // uint256 public amountinUsd;
    address public owner;
    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        //want to be able to set a minimum found amount
        //how do we send ETH to this
        
        // if u use some variable it uses gas but when something fails excess gas is returned
        // work is undone
        require(getConversionRate(msg.value) >= minimumUsd, "Minimum fund amount is 50 Usd");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    // eth/usd address :- 0x694AA1769357215DE4FAC081bf1f309aDC325306

    function getPrice() public view returns (uint256){
        AggregatorV3Interface priceFeed =  AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price* 1e10);

    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/ 1e18;
        return ethAmountInUsd;
    }

    function withdraw() public onlyOwner{
        // require(msg.sender == owner, "Sender is not owner");
        for (uint256 funderIndex = 0; funderIndex< funders.length; funderIndex+1) 
        {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
            funders[funderIndex]=funders[funders.length-1 ];
        }

        funders = new address[](0); //resetting a address

        //transfer 

        payable(msg.sender).transfer(address(this).balance);

        //send 

        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send Failed");

        //call
        (bool callSuccess,)=payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not owner!");
        _;
    }

    
}
