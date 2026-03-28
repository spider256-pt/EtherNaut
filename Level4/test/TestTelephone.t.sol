//SPDX-License-Identifier: MIT

import {Telephone_sol} from "../src/TelePhone.sol";
import {DeployTelephone} from "../script/DeployTelephone.s.sol";
import {Test, console} from "forge-std/Test.sol";

pragma solidity ^0.8.18;

contract TestTelephone is Test{

    Telephone_sol telephone_sol;

    uint256 constant public STARTING_BALANCE = 10 ether;
    address spider = makeAddr("spider");
    address ghost = makeAddr("ghost");

    function setUp() public {
        DeployTelephone deploytelephone = new DeployTelephone();
        (telephone_sol) = deploytelephone.run();
        vm.deal(spider, STARTING_BALANCE);
    }

      /*//////////////////////////////////////////////////////////////
                            FUNDAMENTAL TEST
    //////////////////////////////////////////////////////////////*/


    function testChangeOwner() public{
        //Arrange
        address ogOwner = telephone_sol.owner();
        vm.prank(spider,spider);
        //Act
        telephone_sol.changeOwner(spider);
        console.log("Address of Owner is: ", telephone_sol.owner());
        //Assert 
        assert(telephone_sol.owner() == ogOwner);
    }

       /*//////////////////////////////////////////////////////////////
                           VULNERABLITIY TEST
    //////////////////////////////////////////////////////////////*/

    function testChangeOwnerFunctionWithDifferentParameter() public{
        //Arranage
        address ogOwner = telephone_sol.owner();
        vm.prank(spider);
        //Act
        console.log("Current Owner: ", ogOwner);
        telephone_sol.changeOwner(ghost);
        console.log("Ownership Changed to: ", ghost);
        //Assert
        assert(telephone_sol.owner() == ghost);
       
    }
}
