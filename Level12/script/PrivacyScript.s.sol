//SPDX-License-Idetifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Privacy} from "../src/Privacy.sol" ;

contract PrivacyScript is Script {
    Privacy public privacy; 
    bytes32[3] public dataArray;
    function run() external returns(Privacy){
        dataArray[0] = bytes32("random_data1");
        dataArray[1] = bytes32("random_data2");
        dataArray[2] = bytes32("s3cr3t_D@t@");

        vm.startBroadcast();
        privacy = new Privacy(dataArray);
        vm.stopBroadcast();
        return privacy;
    }
}