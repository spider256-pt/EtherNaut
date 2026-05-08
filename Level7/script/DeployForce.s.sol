//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Force} from "../src/Force.sol";
import {AttackForce} from "../src/AttackForce.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployForce is Script{
    Force public force;
    AttackForce public attack;

    function run() external returns(Force, AttackForce){
        vm.startBroadcast();
        force = new Force();
        attack = new AttackForce(address(force));
        vm.stopBroadcast();
        console.log(address(force).balance);
        console.log("Deployed");
        return (force, attack);
      
    }
    
}


