//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Vault} from "../src/Vault.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployVault is Script {
    Vault vault;
    bytes32 public password = "THIS_IS_YOUR_SECRET_PASSWORD";
    function run() external returns(Vault){
        
        vm.startBroadcast();
        vault = new Vault(password);
        vm.stopBroadcast();
        console.log("Deployed");
        return vault;
    }
}