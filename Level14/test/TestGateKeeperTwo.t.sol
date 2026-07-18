//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test, console} from "forge-std/Test.sol";
import {GatekeeperTwo} from "../src/GateKeeperTwo.sol";
import {DeployGateKeeperTwo} from "../script/DeployGakeKeeperTwo.s.sol";
import {AttackGateKeeperTwo} from "../src/AttackGateKeeperTwo.sol";

contract TestGateKeeperTwo is Test {
    DeployGateKeeperTwo deployer;
    GatekeeperTwo gateKeeperTwo;
    AttackGateKeeperTwo attack;

    address public user = makeAddr("user");

    function setUp() public {
        deployer = new DeployGateKeeperTwo();
        gateKeeperTwo = deployer.run();
    }

    function testAttackGateKeeperTwoEntry() public {
        //Arrange
        vm.startPrank(user, user);
        //Act
        attack = new AttackGateKeeperTwo(gateKeeperTwo);
        //Assert
        assertEq(gateKeeperTwo.entrant(), user);
        vm.stopPrank();
    }
}
