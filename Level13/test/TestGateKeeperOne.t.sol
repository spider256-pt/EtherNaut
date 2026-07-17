//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {GatekeeperOne} from "../src/GateKeeperOne.sol";
import {
    DeployGateKeeperOneScript
} from "../script/DeployGateKeeperOneScript.s.sol";
import {AttackGatekeeperOne} from "../src/AttackGateKeeperOne.sol";

contract TestGatekeeperOne is Test {
    GatekeeperOne gatekeeperone;
    DeployGateKeeperOneScript deployer;
    AttackGatekeeperOne attacker;

    address public user = makeAddr("user");

    function setUp() public {
        attacker = new AttackGatekeeperOne();
        deployer = new DeployGateKeeperOneScript();
        gatekeeperone = deployer.run();
    }

    function testByPassAllTheGates() public {
        //Arrange
        vm.prank(user, user);
        //Act
        attacker.attack(address(gatekeeperone));
        //Assert
        assertEq(gatekeeperone.entrant(), user);
    }
}
