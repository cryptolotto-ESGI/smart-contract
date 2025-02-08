// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/Lottery.sol";

contract DeployLottery is Script {
    function run() external {
        vm.startBroadcast();
        
        // Deploy the contract
        LotteryContract lottery = new LotteryContract();
        
        vm.stopBroadcast();
    }
}