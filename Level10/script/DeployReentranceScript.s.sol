//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {AttackReentrance} from "../src/AttackReentrance.sol";


interface IReentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external view returns (uint256 balance);
    function withdraw(uint256 _amount) external;
}

contract DeployScript is Script{
    AttackReentrance attack;

    function run(address targetContract) external returns (AttackReentrance) {
        vm.startBroadcast();
        attack = new AttackReentrance(targetContract);
        vm.stopBroadcast();
        return attack;
    }
}