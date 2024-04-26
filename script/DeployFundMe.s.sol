// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Since we`re using a script in Foundry we`re going to need to import Script
// from forge-std
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";




contract DeployFundMe is Script{
    // As we know, in order to run a script we`re need run function, run is now going
    // to return a FundMe contract. All we have to do is update how we deploy in
    // here and our tests will deploy it the exact same way
    
    function run() external returns (FundMe) {
        // create a mock contract
        HelperConfig helperConfig = new HelperConfig();
        // normally since we`re returning a struct we would have to wrap in parenthses
        // and if we had muitiple return in the struct, but since it`s only one we
        // can wrap in parenthses like this and solidity will just automatically 
        // take those away
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        // Before startBroadcast -> Not a 'real' tx it`s going simulate this!
        // the reason we`re going to do this before vm.startBroadcast() is we
        // don`t actually want to have to spend gas to deploy this on a real chain
        // It`s going to simulate this in it`s simulated enviroment

        // when we do vm.startBroadcast this makes fundMe actually msg.sender
        vm.startBroadcast();
        // After startBroadcas() -> real tx!
        // grabbing right address from the HelperConfig
        FundMe fundMe = new FundMe(ethUsdPriceFeed); 
        vm.stopBroadcast();
        return fundMe;
    }
}