//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {GatekeeperOne} from "../src/GateKeeperOne.sol";

contract DeployGateKeeperOneScript is Script {
    function run() external returns (GatekeeperOne gatekeeperone) {
        vm.startBroadcast();
        gatekeeperone = new GatekeeperOne();
        console.log("Deployed!!!!!");
        vm.stopBroadcast();
        return gatekeeperone;
    }
}
