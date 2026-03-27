//SPDX-License-Identifier: MIT

import {CoinFlip_sol} from "../src/CointFlip.sol";
import {DeployCoinFlip} from "../script/DeployCoinFlip.s.sol";
import {Test, console} from "forge-std/Test.sol";

pragma solidity ^0.8.18;

contract TestCoinFlip is Test {

    CoinFlip_sol coinflip_sol;

    uint256 public constant STARTING_BALANCE = 10 ether;
    address spider = makeAddr("spider");
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;



    function setUp() public {
        DeployCoinFlip deploycoin = new DeployCoinFlip();
        (coinflip_sol) = deploycoin.run();

        vm.deal(spider, STARTING_BALANCE);
        
    }

    modifier startGuess{
      vm.startPrank(spider);
      _;
    }

    ///////////////////////////////////// 
   //        Fundamental tests        //
  /////////////////////////////////////

  function testblockValue() public {
    //Arrange
    vm.startPrank(spider);
    vm.roll(100);
    uint256 blockValue = uint256(blockhash(block.number - 1));
    console.log("The value of blockValue: ", blockValue);
    vm.stopPrank();
    //Act 
    //Assert
    assert(block.number == 100);
  }


  function testRevertsIfLastHashisSameAsBlockValue() public startGuess{
    //Arrange
    vm.roll(100);  
    //Act
    coinflip_sol.flip(true);
    vm.expectRevert();
    //Reverts if the blocknumber doesnot change.
    coinflip_sol.flip(false);
    vm.stopPrank();
    //Assert
    assert(block.number == 100);
  }

  function testguesstheblockValue() public startGuess{
    //Arrange
    for(uint256 i = 100; i<= 110; i++){

      //Act//Assert
      vm.roll(i);
      uint256 blockValue = uint256(blockhash(block.number - 1));
      uint256 coinFlip  = blockValue / FACTOR;
      console.log("The value of blockValue: ", coinFlip);
      
    }
    vm.stopPrank();
  }

    ///////////////////////////////////// 
   //        vulnerability tests      //
  /////////////////////////////////////

  function testguesstheCoinFlip() public startGuess{
    //Arrange

    for(uint256 i = 100; i <= 110; i++){
      vm.roll(i);
      uint256 blockValue = uint256(blockhash(block.number - 1));
      uint256 coinFlip  = blockValue / FACTOR;
      bool side = (coinFlip == 1);
      console.log("The value of blockValue: ", coinFlip);
    
      //Act
      coinflip_sol.flip(side);
      
    }  
    //Assert
    uint256 currentscore = coinflip_sol.consecutiveWins();
    console.log(currentscore);
    assert(currentscore >= 10);
      
  }

}