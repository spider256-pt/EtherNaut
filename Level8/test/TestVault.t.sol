//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployVault} from "../script/DeployVault.s.sol";
import {Vault} from "../src/Vault.sol";

contract TestVault is Test {
    Vault vault;
    DeployVault deployer;

    bytes32 public passwordleaked;
    address public spider = makeAddr("spider");
    uint256 public constant INITIAL_BALANCE = 10 ether;

    function setUp() public {
        deployer = new DeployVault();
        vault = deployer.run();

        vm.deal(spider, INITIAL_BALANCE);
    }

    function testgetTheSecertPassword() public {
        //Arrange
        passwordleaked = deployer.password();
        //Act
        bytes32 storageValue = vm.load(address(vault), bytes32(uint256(1)));
        console.logBytes32(storageValue);
        //Assert
        assertEq(passwordleaked, storageValue);
    }

    function testLockedValueChanges() public {
        //Arrange
        bool initialLockedValue;
        bool finalLockedValue;
        bytes32 storageValue = vm.load(address(vault), bytes32(uint256(1)));
        
        //Act 
        initialLockedValue = vault.locked();
        console.log("This is the initilaValue of Locked", initialLockedValue);
        vault.unlock(storageValue);
        finalLockedValue = vault.locked();
        console.log("This is the FinalValue of Locker", finalLockedValue);

        //Assert 
        assertEq(initialLockedValue, true);
        assertEq(finalLockedValue, false);
    }

}