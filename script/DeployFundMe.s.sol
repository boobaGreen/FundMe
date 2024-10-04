// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before startBroadcast --> Not a "real" transaction
        HelperConfig helperConfig = new HelperConfig();
        // per piu return dall helper usare (address x1,address y1,address z1,ecc)
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        // After startBroadcast --> "Real" transaction !
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
