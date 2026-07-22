//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {AttackLibraryContract} from "../src/AttackLibraryContract.sol";
import {Script} from "forge-std/Script.sol";

contract DeployNewLibraryContract is Script {
    function run() external returns (AttackLibraryContract attack) {
        vm.startBroadcast();
        attack = new AttackLibraryContract();
        vm.stopBroadcast();
        return attack;
    }
}
