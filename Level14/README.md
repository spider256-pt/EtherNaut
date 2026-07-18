## 🎯 Objective:
---
- Objective of this contract is to bypass all the modifier and run the entrant() function.
- To understand type casting and how BitWise Operator works.
- How constructor Can be used as the Attack Vector.
---
## 📄 Contracts Overview
---
### GateKeeperTwo 
- This contract have 1 state variable 3 modifier and 1 function.
	- `entrant`: address public visibility
	- `gateOne()`: modifier
	- `gateTwo()`: modifier
	- `gateThree()`: modifier
	- `enter()`: function
---
## 🧠 Vulnerability: GateKeeperTwo
---
- The core vulnerability of this contract is the given modifier can be bypassed by maths and the basic understanding of contracts.

```gateOne
//Modifier 1
modifier gateOne(){
	require(msg.sender != tx.origin);
	_;
}
```
- The modifier can be bypassed by using a EOA and 0 sized contract.
- As in modifier two there is require statement that need only passed if the code size is 0.

```gateTwo
//Modifier 2
modifier gateTwo(){
	uint256 x;
	assembly{
		x := extcodesize(caller())
	}
	require(x==0);
	_;
}
```
- `extcodesize`: an assembly opcode that returns the contract size to the caller contract's address.
- in this modifier it will only allow to pass if the code size will be 0. So using the attack logic inside the `constructor` is a good solution as it only runs when a contract is deployed and then there is no remaining of constructor so the the code size will be 0.

```gateThree
//Modifier 3
modifier gateThree(bytes8 _gateKey){
	require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))) ^ uint64(_gateKey) == type(uint64).max;
	_;
}
```
- This modifier uses  a bitwise operator (XOR) with a complex typecasting which can be bypassed using basic math.
	- `keccak256` returns the output in `32 bytes -> 256 bits {b0....b255}`.
	- `bytes8` returns in `8 bytes -> 64 bits {b0........b63}`.
	- As the type casted from `32 bytes` to `8 bytes`so a narrow type byte casting is being used which means lowest bits will be given the priority and highest bit will be thrown away.
	- so, 32 bytes have 64 hex characters and 8 bytes have 16 hex character so
	
	  `0x[b255,b254], [b253, b252], [b251, b250], [b249, b248], [b247, b246], [b245, b244], [b243,b242], [b241, b240]` is the obtained 8 bytes result can also be represented as `0xFFFFFFFFFFFFFFFF`
	- so as per the constraints:
		- let A = `0x[b255,b254], [b253, b252], [b251, b250], [b249, b248], [b247, b246], [b245, b244], [b243,b242], [b241, b240]`
		- or A = `0xFFFFFFFFFFFFFFFF` and let MAX = type(uint64).max
		- as per the require statement:
			- A ^ gateKey = MAX
			- gateKey = A ^ MAX {By this logic gate key can be constructed for bypassing modifier 3}.
---
## Attack Flow:
---
- To exploit this contract the attacker should know how a contract's constructor behaves and a good knowledge of typeCasting.
```attack
Attacker made a contract with a constructor that accepts GateKeeper instance

for modifier 1:
	The attacker use a contract's constructor which acts as both msg.sender and tx.origin {one for calling the enter and for deploying the contract}.
|
V
for modifier 2:
	To bypass this modifier the attacker writes its attack logic inside the constructore so that once the contract is deployed the attack gets initiated with 0 code size.
|
V
for modifier 3:
	To bypass this modifier the attacker must use a basic maths and type casting
	as per the require statement 
	A ^ gateKey = type(uint64).max
	gateKey = A ^ type(uint64).max
|
V
After this the attacker can run the enter() function and set entrant to tx.origin.
```
---
## 🧪 Test - TestGateKeeperTwo.t.sol
---

| TestName                     | What it checks                                                                                                                    |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| testAttackGateKeeperTwoEntry | Checks whether all the logic of the attack contract inside the constructor breaks the modifier logic of the GateKeeperTwo or not. |

---
### Key exploit(in test):
---
```solidity
function testAttackGateKeeperTwoEntry() public {
	//Arrange
	vm.startPrank(user, user);
	//Act
	attack = new AttackGateKeeperTwo(gateKeeperTwo);
	//Assert
	assertEq(gateKeeperTwo.entrant(), user);
	vm.stopPrank();
}
```
- The exploit in this file is 
	- `attack = new AttackGateKeeperTwo(gateKeeperTwo)`: as the contract is using a constructor so just by deploying the contract the attack can be initiated.
---
## 🚀 On-Chain - AttackGateKeeperTwo.s.sol
---
```solidity
function run() external {
	vm.startBroadcast();
	attack = new AttackGateKeeperTwo(GatekeeperTwo(instance));
	console.log("Attacked!!!!!");
	vm.stopBroadcast();
}
```
---
## 🛠️ How to Run
---

## Run Tests(Local Anvil)
---
```bash
forge test --mt testAttackGateKeeperTwoEntry -vvvv
```
---
## Deploy & Attack (On-chain)
---
```bash
forge script script/AttackScriptGKT.s.sol --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast
```
---
## 📁 Project Structure
---
```file
├── src/
│   └──GateKeeperTwo.sol
|	└──AttackGateKeeperTwo.sol        # call the attack function
├── script/
│   ├── DeployGateKeeperTwo.s.sol
│   └── AttackScriptGKT.s.sol
└── test/
    └── TestGateKeeperTwo.t.sol
```
--- 