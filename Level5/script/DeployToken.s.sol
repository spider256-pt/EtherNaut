//SPDX-License-Identifer: MIT;

import {Script, console} from "forge-std/Script.sol";



pragma solidity ^0.8.18;

contract DeployToken is Script{

    uint256 initialSupply = 100;

    function run() external{

        uint256 deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address deployAddress = deployCode("Token.sol:Token_sol", abi.encode(initialSupply));
        vm.stopBroadcast();
    }

}