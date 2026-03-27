//SPDX-License-Identifier: MIT

import {Script,console} from "forge-std/Script.sol";
import {CoinFlip_sol} from "../src/CointFlip.sol";
import "../src/AttackCoinFlip.sol";

pragma solidity ^0.8.18;

contract DeployCoinFlip is Script {

    function run() external returns(CoinFlip_sol){
        
        vm.startBroadcast();
        CoinFlip_sol coinflip_sol = new CoinFlip_sol();
        vm.stopBroadcast();
        return coinflip_sol;
    }
}


