# ☢️ Ethernaut Level 2: Fallout

**Author:** Pratik
**Role:** Smart Contract Engineer & Security Auditor
**Framework:** Foundry (Solidity `^0.8.18`)

## 📝 Objective
The goal of this level is to claim ownership of the `Fallout` contract and drain its balance. 

This contract is a historical recreation of the infamous 2016 "Rubixi" hack, demonstrating the catastrophic dangers of constructor misconfigurations in early Solidity versions.

## 🔍 The Vulnerability
Prior to Solidity `0.4.22`, constructors were defined by creating a function with the **exact same name** as the contract. 

In `Fallout.sol`, the developer made a fatal typographical error:
* **Contract Name:** `Fallout`
* **Constructor Name:** `Fal1out` (Spelled with a '1')

```solidity
/* Constructor */
function Fal1out() public payable {
    owner = msg.sender;
    allocations[owner] = msg.value;
}
