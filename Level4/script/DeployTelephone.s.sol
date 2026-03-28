//SPDX-License-Identifier: MIT

import {Telephone_sol} from "../src/TelePhone.sol";
import {Script} from "forge-std/Script.sol";

pragma solidity ^0.8.18;

contract DeployTelephone is Script {

    function run() external returns(Telephone_sol){
        vm.startBroadcast();
        Telephone_sol telephone_sol = new Telephone_sol();
        vm.stopBroadcast();
        return telephone_sol;
    }
}