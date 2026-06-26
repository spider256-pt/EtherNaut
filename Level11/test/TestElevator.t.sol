//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";

import {Elevator} from "../src/Elevator.sol";
import {ElevatorScript} from "../script/ElevatorScript.s.sol";
import {AttackElevator} from "../src/AttackElevator.sol";

contract TestElevator is Test {
    Elevator public elevator;
    ElevatorScript public deploy;
    AttackElevator public attack;

    address spider = makeAddr("spider");

    function setUp() public {
        deploy = new ElevatorScript();
        (elevator) = deploy.run();

        attack = new AttackElevator(address(elevator));
    }

    function testAttack() public {
        attack.attack(12);
        assertEq(
            elevator.top(),
            true,
            "The elevator did not reach the top floor!"
        );
    }
}
