//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {AttackReentrance} from "../src/AttackReentrance.sol";
import {DeployScript} from "../script/DeployReentranceScript.s.sol";

interface IReentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external view returns (uint256 balance);
    function withdraw(uint256 _amount) external;
}

contract TestReentrance is Test {
    IReentrance public ireentrace;
    DeployScript public deployScript;
    AttackReentrance public attack;


    uint256 public constant STARTING_BALANCE = 5 ether;
    address public spider = makeAddr("spider");
    address public USER = makeAddr("USER");

    function setUp() public {
        address deployeradd = deployCode("Reentrance.sol:Reentrance");
        ireentrace = IReentrance(deployeradd);
       
        deployScript = new DeployScript();
        attack = deployScript.run(deployeradd);


        vm.deal(spider, STARTING_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                            FUNDAMENTAL TEST
    //////////////////////////////////////////////////////////////*/

    function testBalanceOFUSERandContractUSingLowLevel() public {

        //Arrange 
        uint256 contractBalance;
        uint256 userBalance;
        vm.deal(USER, STARTING_BALANCE);
        vm.startPrank(USER);
        userBalance = USER.balance;
        console.log("The user balance: ", userBalance);
      
        //Act 
        (bool s,) = address(ireentrace).call{value:3 ether}("");
        require(s, "This fails to populate the contract with Ether");
        contractBalance = address(ireentrace).balance;
        console.log("The contract Balance: ", contractBalance);
        vm.stopPrank();
        //Assert 
        assertEq(contractBalance, 3 ether);
        assertEq(userBalance, STARTING_BALANCE);
        
    }

    function testdonateAndBalanceOf() public {
        //Arrange 
        uint256 balanceOfUSERWhenDonateNotCalled;
        uint256 balanceOfUSERWhenDonateCalled;
        uint256 contractBalance;
        
        vm.startPrank(USER);
        vm.deal(USER, STARTING_BALANCE);
        //Act 
        balanceOfUSERWhenDonateNotCalled = ireentrace.balanceOf(USER);
        ireentrace.donate{value: STARTING_BALANCE}(USER);
        balanceOfUSERWhenDonateCalled = ireentrace.balanceOf(USER);
        console.log("The balance of the USER after donating: ", balanceOfUSERWhenDonateCalled);
        contractBalance = address(ireentrace).balance;
        console.log("The contract Balane is: ", contractBalance);
        //Assert
        assertEq(balanceOfUSERWhenDonateNotCalled, 0);
        assertEq(balanceOfUSERWhenDonateCalled, STARTING_BALANCE);
       
    }

   
    function testWithDraw() public {
        //Arrange 
        uint256 theUSERBalance;
        uint256 theContractBalance;
        uint256 withdrawAmount = 3 ether;

        vm.deal(USER, 10 ether);
        vm.startPrank(USER);

        (bool s,) = address(ireentrace).call{value: 5 ether}("");
        require(s, "Failed");
        ireentrace.donate{value: 4 ether}(USER);
        theUSERBalance = ireentrace.balanceOf(USER);
        console.log("The balance of the USER: ", theUSERBalance);
        theContractBalance = address(ireentrace).balance;
        console.log("The total Balance of Contract:", theContractBalance);

        //Act
        ireentrace.withdraw(withdrawAmount);
        uint256 afterWithdrawContractBalance = address(ireentrace).balance;
        console.log("The balance of contract after withdrawing: ", afterWithdrawContractBalance);
        
        //Assert 
        assert(afterWithdrawContractBalance < theContractBalance);
        assertEq(afterWithdrawContractBalance, (theUSERBalance + 5 ether) - withdrawAmount);
        assertEq(theContractBalance, theUSERBalance + 5 ether);
        assertEq(theUSERBalance, 4 ether);
    }

    /*//////////////////////////////////////////////////////////////
                                 EXPLOIT
    //////////////////////////////////////////////////////////////*/

    function testExploitWithdraw() public {
        //Arrange
        uint256 contractBalance;
        
        (bool s,)=address(ireentrace).call{value: 0.001 ether}("");
        require(s, "Failed to fund the contract");
        console.log("The contract balance before attack: ", address(ireentrace).balance);
        //Act 
        vm.startPrank(USER);
        vm.deal(USER, STARTING_BALANCE);
        ireentrace.donate{value: 0.005 ether}(USER);
        console.log("The USER balance: ", USER.balance);
        console.log("The contract balance after donating: ", address(ireentrace).balance);
        vm.stopPrank();

        vm.startPrank(spider);
        attack.donateToWithdraw{value: 0.0001 ether}();
        console.log("The contract balance after attack: ", address(ireentrace).balance);
        vm.stopPrank();
        //Assert 
        assertEq(address(ireentrace).balance, 0);
    }
}