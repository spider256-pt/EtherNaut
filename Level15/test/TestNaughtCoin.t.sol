//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {NaughtCoin} from "../src/NaughtCoin.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployNaughtCoin} from "../script/DeployNaughtCoin.s.sol";
import {AttackNaughtCoin} from "../src/AttackNaughtCoin.sol";

contract TestNaughtCoin is Test {
    DeployNaughtCoin deploy;
    NaughtCoin naughtcoin;
    AttackNaughtCoin attack;

    address public user = makeAddr("user");

    function setUp() public {
        deploy = new DeployNaughtCoin();
        naughtcoin = deploy.run();
        attack = new AttackNaughtCoin(address(naughtcoin));
    }

    function testTransfer() public {
        address player = naughtcoin.player();
        uint256 amount = naughtcoin.INITIAL_SUPPLY();
        vm.prank(player);
        naughtcoin.approve(address(attack), amount);
        attack.attack();
        assertEq(naughtcoin.balanceOf(address(attack)), amount);
        assertEq(naughtcoin.balanceOf(player), 0);
    }
}
