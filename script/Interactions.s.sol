//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundInteract is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundInFundMe(address mostRecentDeployedAddtess) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedAddtess)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployedFundMe = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);

        //vm.startBroadcast();
        fundInFundMe(mostRecentDeployedFundMe);
        //vm.stopBroadcast();
    }
}

contract WithdrawInteract is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function withdrawInFundMe(address mostRecentDeployedAddtess) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployedAddtess)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployedFundMe = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);

        //vm.startBroadcast();
        withdrawInFundMe(mostRecentDeployedFundMe);
        //vm.stopBroadcast();
    }
}
