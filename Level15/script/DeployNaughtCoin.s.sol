//SPDX-License-Identifer: MIT

pragma solidity ^0.8.24;

import {NaughtCoin} from "../src/NaughtCoin.sol";
import {Script} from "forge-std/Script.sol";

contract DeployNaughtCoin is Script {
    function run() external returns (NaughtCoin naughtcoin) {
        vm.startBroadcast();
        naughtcoin = new NaughtCoin(address(this));
        vm.stopBroadcast();
    }
}
