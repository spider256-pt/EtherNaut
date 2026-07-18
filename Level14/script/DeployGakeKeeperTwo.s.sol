//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script, console} from "forge-std/Script.sol";
import {GatekeeperTwo} from "../src/GateKeeperTwo.sol";
contract DeployGateKeeperTwo is Script {
    function run() external returns (GatekeeperTwo gatekeeperTwo) {
        vm.startBroadcast();
        gatekeeperTwo = new GatekeeperTwo();
        vm.stopBroadcast();
        return gatekeeperTwo;
    }
}
