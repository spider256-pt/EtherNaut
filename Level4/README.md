# Ethernaut Level 4: Telephone Exploit ☎️🕸️

## The Objective
The goal of this level is to claim ownership of the `Telephone` smart contract.

## The Vulnerability: `tx.origin` Phishing
The smart contract contains a fatal flaw in its authorization logic within the `changeOwner` function:

```solidity
if (tx.origin != msg.sender) {
    owner = _owner;
}```