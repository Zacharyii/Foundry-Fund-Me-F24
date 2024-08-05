// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // 获取当前的ETH→USD价格
    function getPrice(
        // 一个合约实例，它指向一个具体的价格馈送合约。
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // 调用Chainlink的价格馈送合约获取最新一轮的数据
        // roundId: 当前的轮次 ID
        // answer: 当前轮次的价格，带8位小数
        // startedAt: 当前轮次开始的时间戳
        // updatedAt: 当前轮次数据最后一次更新的时间戳
        // answeredInRound: 当前轮次数据是否已经被其他轮次更新
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        // 将价格转换为18位小数的整数格式返回
        return uint256(answer * 10000000000);
    }

    // 将ETH金额转换为USD金额
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // 获取当前的ETH→USD价格
        uint256 ethPrice = getPrice(priceFeed);
        // 计算ethAmount对应的USD金额
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }
}
