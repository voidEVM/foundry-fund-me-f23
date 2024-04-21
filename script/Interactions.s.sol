
/**
When we actually call FundMe and withdraw we`re going to do 'cast send' or we`re
going to do it with forge script
Here we`re going to have all of the ways we can actually interact with
our contract

We`re just going to make:
Fund script
Withdraw script 
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
// this package helps  Foundry keep track of the most recently deployed version of a 
// contract(grab contract address) - this way we don`t have to pass the FundMe
// contract address
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

// script for funding the FundMe contract
// we can call: forge script script/Interactions.s.sol:FundFundMe --rpc-url ... --private-key ...
contract FundFundMe is Script {

    uint256 constant SEND_VALUE = 0.01 ether;
    
    function run() external {
        address mostRecentlyDeployed = 
                  DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed); // address
        vm.stopBroadcast();
    }

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        // we just call fund on this most recently deployed
        // payable,because we`re going to be sending value here
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
        // created some tests which kind of bring it all together
    }
}


contract WithdrawFundMe is Script {

    function run() external {
        address mostRecentlyDeployed = 
                  DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed); // address
        vm.stopBroadcast();

    }
    
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");

        
    }
}
// Now we can run:
// forge script script/Interactions.s.sol:FundFundMe --rpc-url asdfas --private-key,
// so that always calling the fund function the way we wantt to call it and then we
// created some integration tests which kind of bring ia all together and then
// we did the same thing with withdrawing money as well.