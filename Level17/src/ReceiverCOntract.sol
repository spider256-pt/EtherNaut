//SPDX-License-Identifier:MIT

pragma solidity ^0.8.14;
import {console} from "forge-std/console.sol";

contract Reciever {
    function hehehe() public {
        console.log("Hiiiiiiii");
    }

    receive() external payable {}
    fallback() external payable {}
}
