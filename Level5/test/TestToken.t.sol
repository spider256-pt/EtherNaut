//SPDX-License-Identifier: MIT

import {Test, console} from "forge-std/Test.sol";

pragma solidity ^0.8.18;

interface IToken {
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool);
    
}



contract TestToken is Test {

    IToken public itoken_sol;
    address spider = makeAddr("spider");
    address ghost = makeAddr("ghost");
    uint256 constant public STARTING_BALANCE = 20;


    function setUp() public{
        vm.startPrank(spider);
        address DeployedAddress = deployCode("Token.sol:Token_sol", abi.encode(STARTING_BALANCE));
        itoken_sol = IToken(DeployedAddress);
        vm.stopPrank();
    }


    /*//////////////////////////////////////////////////////////////
                            FUNDAMENTAL TEST
    //////////////////////////////////////////////////////////////*/


    function testTransfer() public{
        //Arrange
        console.log("Spider's balance before transfer: ", itoken_sol.balanceOf(spider));
        console.log("Ghost's balance before transfer: ", itoken_sol.balanceOf(ghost));
        //Act   
        vm.prank(spider);
        itoken_sol.transfer(ghost, 10);
        //Assert
        console.log("Spider's balance after transfer: ", itoken_sol.balanceOf(spider));
        console.log("Ghost's balance after transfer: ", itoken_sol.balanceOf(ghost));
        assert(itoken_sol.balanceOf(spider) == 10);
        assert(itoken_sol.balanceOf(ghost) == 10);
    }

    function testMyBalance() public {
        console.log("Spider's balance: ", itoken_sol.balanceOf(spider));
    }

    function testMsgSender() public {
        console.log("msg.sender: ", msg.sender);
    }

    

    /*//////////////////////////////////////////////////////////////
                           VULNERABLITY TEST
    //////////////////////////////////////////////////////////////*/

    function testOverFlow() public {
        //Arrange
        vm.startPrank(spider);
        console.log("Spider's balance before transfer: ", itoken_sol.balanceOf(spider));
        console.log("Ghost's balance before transfer: ", itoken_sol.balanceOf(ghost));
        //Act 
        itoken_sol.transfer(ghost, 100);
        console.log("Spdier's balance after transfer: ", itoken_sol.balanceOf(spider));
        console.log("Ghost's balance after transfer: ", itoken_sol.balanceOf(ghost));
        //Assert
        assert(itoken_sol.balanceOf(spider) > 20);
        assert(itoken_sol.balanceOf(ghost) == 100);
    }


}