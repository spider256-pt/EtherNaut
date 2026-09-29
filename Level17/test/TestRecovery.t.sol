//SPDX-License-Iddentifier: MIT

pragma solidity ^0.8.14;

import {Test, console} from "forge-std/Test.sol";
import {Reciever} from "../src/ReceiverCOntract.sol";
import {Recovery, SimpleToken} from "../src/Recovery.sol";
import {DeployRecovery} from "../script/DeployRecovery.s.sol";

contract TestRecovery is Test {
    Recovery recover;
    SimpleToken token;
    Reciever receiver;

    DeployRecovery deployer;

    address spider = makeAddr("spider");

    function setUp() public {
        deployer = new DeployRecovery();
        (recover, token) = deployer.run();

        receiver = new Reciever();

        vm.deal(spider, 1e18);

        vm.prank(spider);
        (bool s,) = address(token).call{value: 0.001 ether}("");
        require(s, "setting up transfer failed");
    }

    function test_balance_of_token_contracts() public {
        //Arrange
        uint256 balance_of_token_contract = address(token).balance;
        console.log(balance_of_token_contract);
        //Act
        //Assert
    }

    function test_destroy_function() public {
        //Arrange
        uint256 balance_of_token_before_self_destruct = address(token).balance;
        uint256 balance_of_receiver_before_destroy = address(receiver).balance;
        //Act
        token.destroy(payable(address(receiver)));

        uint256 balance_of_receiver_after_destroy = address(receiver).balance;
        //Assert
        assertEq(
            balance_of_receiver_after_destroy,
            balance_of_receiver_before_destroy + balance_of_token_before_self_destruct
        );
        assertEq(address(token).balance, 0);
    }
}
