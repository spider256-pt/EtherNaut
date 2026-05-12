//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {King} from "../src/King.sol";

contract DeployKingScript is Script{
    King public king;

    function run() external returns(King){
        vm.startBroadcast();
        king = new King();
        vm.stopBroadcast();
        return king;
    }
}