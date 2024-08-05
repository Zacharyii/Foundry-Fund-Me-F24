//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig; // 当前活跃的网络配置

    uint8 public constant DECIMALS = 8; // 价格预言机的小数位数
    int256 public constant INITIAL_PRICE = 2000e8; // 初始价格

    struct NetworkConfig {
        address priceFeed; // 价格预言机地址
    }

    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia 测试网
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            // 以太坊主网
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            // 本地开发环境 (Anvil)
            activeNetworkConfig = getOrCreatAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreatAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; // 如果已经存在配置，直接返回
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
