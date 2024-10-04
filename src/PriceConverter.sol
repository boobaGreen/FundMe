// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // function getPrice(
    //     AggregatorV3Interface priceFeed
    // ) internal view returns (uint256) {
    //     (, int256 answer, , , ) = priceFeed.latestRoundData();
    //     // ETH/USD rate in 18 digit
    //     return uint256(answer * 10000000000);
    // }
    // 0x694AA1769357215DE4FAC081bf1f309aDC325306
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // ETH/USD rate in 18 digit
        return uint256(answer * 10000000000);
    }

    // 1000000000
    // call it get fiatConversionRate, since it assumes something about decimals
    // It wouldn't work for every aggregator
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    )
        internal
        view
        returns (
            // AggregatorV3Interface priceFeed
            uint256
        )
    {
        // uint256 ethPrice = getPrice(priceFeed);
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // the actual ETH/USD conversation rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }
}
