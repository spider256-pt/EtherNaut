//SPDX-License-Identifier:  MIT
pragma solidity ^0.8.0;
import {Script, console} from "forge-std/Script.sol";
import {Elevator} from "../src/Elevator.sol";

contract ElevatorScript is Script {
    Elevator public elevator;

    function run() external returns (Elevator) {
        vm.startBroadcast();
        elevator = new Elevator();
        vm.stopBroadcast();
        return elevator;
    }
}
