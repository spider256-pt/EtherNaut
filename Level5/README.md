# Ethernaut Level 5: Token Exploit 🪙

## Objective
The goal of this level is to hack the basic token contract. You start with 20 tokens, and you must somehow increase your balance to beat the level.

## The Vulnerability: Integer Underflow
This smart contract was written in Solidity `^0.6.0`. In versions of Solidity prior to `0.8.0`, the Ethereum Virtual Machine (EVM) did not have built-in protection against integer overflows and underflows. 

The critical flaw lies in the `transfer` function's balance check:
```solidity
require(balances[msg.sender] - _value >= 0);