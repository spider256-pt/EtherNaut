//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Force} from "../src/Force.sol";
import {DeployForce} from "../script/DeployForce.s.sol";
import {AttackForce} from "../src/AttackForce.sol";

contract TestForce is Test {
    Force public force;
    AttackForce public attack;

    DeployForce public deployer;


    uint256 public constant INITIAL_BALANCE = 5 ether;


    address public spider = makeAddr("spider");

    function setUp() public {
        deployer = new DeployForce();
        (force, attack) = deployer.run();
        vm.deal(spider, INITIAL_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                                EXPLOIT
    //////////////////////////////////////////////////////////////*/

    function testBalanceOfForceContract() public {
        uint256 initialbalance = address(force).balance;
        console.log("Balance of Force Contract: ", initialbalance);
    }

    function testexploitBalanceAfterSelfDestruct() public {
        //Arrange
        uint256 initialForceBalance;
        uint256 finalForceBalance;
        //Act 
        vm.startPrank(spider);
        
        initialForceBalance = address(force).balance;
        console.log("The initial Balance of Contract force is: ", initialForceBalance);
        attack.deposit{value: 2 ether}();
        console.log("The balance of the contract Attack: ", address(attack).balance);
        attack.attack();
        finalForceBalance = address(force).balance;
        console.log("The initial Balance of Contract force is: ", finalForceBalance);

        //Assert
        assertEq(initialForceBalance, 0);
        assertEq(finalForceBalance, 2 ether);
    }
}