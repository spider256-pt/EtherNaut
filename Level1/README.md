# 🕷️ Ethernaut Level 1: Fallback Exploit

**Author:** Pratik ([@spider256-pt](https://github.com/spider256-pt))
**Discipline:** Smart Contract Security / Red Team 

## 🎯 Objective
This repository contains a professional, Foundry-based audit and exploit suite for OpenZeppelin's Ethernaut Level 1: Fallback. The test suite mathematically proves the contract's baseline defenses, simulates multi-user network interactions, and executes a precision strike to hijack contract ownership and drain the vault.

## 🩻 Vulnerability Breakdown (The Open Window)
The target contract (`Fallback.sol`) contains a fatal logic flaw in its `receive()` function:

```solidity
receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender; // 🚨 FATAL FLAW
}