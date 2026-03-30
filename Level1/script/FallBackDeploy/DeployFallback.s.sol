//SPDX-License-Identifier: MIT

import {Fallback_sol} from "../../src/Fallback.sol";
import "@openzeppelin/src/levels/Fallback.sol";
import {Script} from "forge-std/Script.sol";

pragma solidity ^0.8.18;

contract DeployFallback is Script{
    
    function run() external returns(Fallback_sol) {
        vm.startBroadcast();
        Fallback_sol fallback_sol = new Fallback_sol();
        vm.stopBroadcast();
        return fallback_sol;
    }
}