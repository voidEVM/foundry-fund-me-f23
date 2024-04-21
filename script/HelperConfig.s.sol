// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain.We deploy our own 
//    fake(mock) PriceFeed and interact with that for the duration of our local tests
// 2. Keep track of contract address across different chains

// If we set up this helper congig correctly we`ll able to work with a local chain no
// problem and work with any chain we want no poblem
// Sepolia ETH/USD - different address
// Mainnet ETH/USD - different address

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // If we are on a local anvil, we deploy mocks contract for us to interact with
    // Otherwise, grab the existing address from the live network

    // When we deployed contract,activeNetworkConfig going to be updated with the
    // correct HelperConfig
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8; // uint8 because ETH/USD have 8 decimals
    int256 public constant INITIAL_PRICE = 2000e8;

    // if we`ve got a ton of stuff in here, it`s a good idea to turn this config into
    // it`s own type
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
        // vff address
        // gas price
    }
    
    // set the activeNetworkConfig
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    // We`re going to have both of these functions returns a NetworkConfig object with
    // priceFeed

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        // all we need in Sepolia the priceFeed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            // create object {type: object}
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        // return a configuration for everything we need in Sepolia or really any chain
        // we have a way to grab an existing address on a live network
        return sepoliaConfig; // return NetworkConfig object
        // holy mackerel
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory){
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return ethConfig;
    }

    // since we`re using 'vm' keyword we actually can`t have 'pure' and
    // additionally our HelperConfig needs to be is Scipt in order to have
    // access to this 'vm' keyword
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // the reason we put this ,if we we`ve already deployed one we don`t want
        // to deploy a new one, zero means we`ve already set it
        // address(0) - default value
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;   
        }
        // 1. Deploy the mocks(like a fake contract)
        // 2. Return the mock address(price feed address)

        // this way we can actually deploy these mock contracts to the Anvil chain
        vm.startBroadcast(); 
        // we`d say it starts at a price of 2000
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS, INITIAL_PRICE);

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;

    }
}
