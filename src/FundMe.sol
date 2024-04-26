// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.18;

// we need to tell Foundry that @chainlink/contracts should point to lib folder, so
// we need create something called a remapping

// 2. Imports
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// 3. Interfaces, Libraries, Contracts
// best practice name errors, name them with contract name and then two underscores
error FundMe__NotOwner();

/**
 * @title A sample Funding Contract
 * @author Patrick Collins
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */

contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // State variables
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders; 

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address private immutable  i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18; // 5e18
    AggregatorV3Interface private s_priceFeed;// (s_ storage/state var)

    // Events (we have none!)

    // Modifiers
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // Functions Order:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    // priceFeed object depend on the chain that we`re on
    // we`re pass a priceFeed in, so that we can deploy contract any chain we want
      constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
        "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        // this contract address only exists on Sepolia, but we`re testing on not Sepolia, we`re testing on our local chain
        // del. AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // call the version function directly on s_priceFeed variable
        return s_priceFeed.version();
    }
    
    

    function cheaperWithdraw() public onlyOwner {
        // that way we`ll only read it from storage one time and then every
        // time we loop through we`ll only read it one more time
        uint256 funderLength = s_funders.length;
        // funderLength - now is a memory variabble
        for(uint256 funderIndex = 0; funderIndex < funderLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0); // reset the storage
        // payable(msg.sender).transfer(address(this).balance);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0;
             funderIndex < s_funders.length; 
             funderIndex++)
        {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();

    }

    
    // View / Pure functions section (Gettes)
     

    /**
     * @notice Gets the amount that an address has funded
     * @param fundingAddress the address of the funder
     * @return the amount funded
     */
    function getAddressToAmountFunded(
        address fundingAddress) external view returns (uint256) {
            return s_addressToAmountFunded[fundingAddress];
        }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address) {
        return i_owner;
    }

}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly





















































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































