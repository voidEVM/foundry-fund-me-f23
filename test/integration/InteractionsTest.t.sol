// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Integration tests are when we test a lot of your interactios, tests combinations
// of systems

/**
 * @title 
 * @author 
 * @notice 
 */

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";


contract Interactions is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    // decimals don`t work in solidity but if you do 0.1 ether that makes it like below
    uint256 constant SEND_VALUE = 0.1 ether; // 1000000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE); // give our fake user 10 fake ether
    
    }

    // insted of funding directly with the functions we`re going to import
    // {FundFundMe} from "../../script/Interactions.s.sol
    function testUserCanInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        /* This is why we separated those scripts in Interactions.s.sol, because
           we can`t run() with this - 'address mostRecentlyDeployed = 
                  DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);'
           we want to run fundFundMe and able to add my own address in 
           here fundFundMe(mostRecentlyDeployed);
           So we`re testing specifically function fundFundMe in Interactions.s.sol to
           make sure our funding works

         */
        

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
 
    }
}