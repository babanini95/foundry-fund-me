//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // kalau ga konek ke chain -> pakai mock untuk priceFeed
    // kalau konek -> priceFeed pakai chain yang sedang live
    struct NetworkConfig {
        address priceFeedAddress;
    }

    NetworkConfig public activeNetworkConfig;
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else {
            activeNetworkConfig = getAnvilNetworkConfig();
        }
    }

    function getSepoliaNetworkConfig()
        private
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory sepoliaNetworkConfig = NetworkConfig({
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaNetworkConfig;
    }

    function getAnvilNetworkConfig() private returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeedAddress != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilNetworkConfig = NetworkConfig({
            priceFeedAddress: address(mockPriceFeed)
        });

        return anvilNetworkConfig;
    }
}
