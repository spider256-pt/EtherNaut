//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {Delegation, Delegate} from "../src/Delegation.sol";


contract DelegationDeploy is Script{
    Delegation public delegation;
    Delegate public delegate;


    function run() external returns(Delegation){
        uint256 deployer = vm.envUint("ANVIL_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployer);        

        vm.startBroadcast(deployer);
        delegate = new Delegate(deployerAddress);
        delegation = new Delegation(address(delegate));
        console.log("Delegate deployed at: ", address(delegate));
        console.log("Owner: ", delegate.owner());
        console.log("Delegation deployed at: ", address(delegation));
        vm.stopBroadcast();
        return delegation;
    }
}