// SPDX-License-Identifier: MIT

import "@openzeppelin/Telephone.sol";

pragma solidity ^0.8.0;


contract Telephone_sol {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}
