// SPDX-License-Identifier: MIT

//1.Deploy mocks when on local chain
//2.Keep track of the address across different chains

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig{
    // if we are on local anvil we deploy mocks
    // otherwise grab existing address from the live network
    struct NetworkConfig{
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;
    
    constructor(){
        if(block.chainid == 1115111){
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else{
            activeNetworkConfig = getAnvilEthConfig();
        }
    }
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public pure returns(NetworkConfig memory){

    }
}