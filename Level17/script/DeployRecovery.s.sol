//SPDX-License-Identifer: MIT

pragma solidity ^0.8.14;

import {Script} from "forge-std/Script.sol";
import {Recovery, SimpleToken} from "../src/Recovery.sol";

contract DeployRecovery is Script {
    address spider = makeAddr("spider");

    function run() external returns (Recovery recover, SimpleToken token) {
        vm.startBroadcast();
        recover = new Recovery();
        token = new SimpleToken("Token", spider, 0.001 ether);
        vm.stopBroadcast();
        return (recover, token);
    }
}
