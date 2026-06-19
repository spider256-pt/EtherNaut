//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Privacy} from "../src/Privacy.sol";
import {PrivacyScript} from "../script/PrivacyScript.s.sol";

contract PrivacyTest is Test {
    Privacy public privacy;
    PrivacyScript public deployer;

    address spider = makeAddr("spider");

    function setUp() public {
        deployer = new PrivacyScript();
        (privacy) = deployer.run();
    }

    function testrevertIfPassedRandombytes16Inputs(uint256 x) public {
        //Arrange
        vm.startPrank(spider);
        uint256 boundInt = bound(x, 1, type(uint128).max);
        bytes32 rawBytes32 = bytes32(boundInt);
        bytes16 fuzzkey = bytes16(rawBytes32);
        //Act
        vm.expectRevert();
        privacy.unlock(fuzzkey);
        //Assert
        assertEq(privacy.locked(), true, "The value changed");
        vm.stopPrank();
    }

    function testLockIsUnlock() public {
        //Arrange
        vm.startPrank(spider);
        bool initialLocakedValue;
        bool finalLockedValue;
        bytes32 storageValue = vm.load(address(privacy), bytes32(uint256(5)));

        bytes16 byt16 = bytes16(storageValue);
        //Act
        initialLocakedValue = privacy.locked();
        privacy.unlock(byt16);
        finalLockedValue = privacy.locked();
        //Assert
        assertEq(
            privacy.locked(),
            finalLockedValue,
            "It didnt change teh locked value!"
        );
        vm.stopPrank();
    }
}
