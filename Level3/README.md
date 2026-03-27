# Ethernaut Level 3: CoinFlip Exploit 🪙🕸️

## The Objective
The goal of this Ethernaut level is to guess the correct outcome of a coin flip 10 times in a row. 

## The Vulnerability: Predictable On-Chain PRNG
The `CoinFlip` contract attempts to generate randomness (PRNG) by using `blockhash(block.number - 1)` divided by a massive hardcoded `FACTOR`. 

Because blockchains are entirely deterministic, there is no true randomness natively available on-chain. All variables used in the contract's calculation (`block.number`, `blockhash`) are publicly visible before the block is finalized. 

## The Attack Vector: Atomic Execution
If a standard off-chain script calculates the hash and submits the transaction, network latency (the mempool delay) will cause the transaction to execute in a *future* block, ruining the math. 

To bypass this network race condition, the exploit must be executed **on-chain**. By writing an Attack Contract that calculates the exact same math and calls the target `CoinFlip` contract in the *exact same transaction*, the exploit becomes atomic. Both contracts share the exact same block context, ensuring a 100% win rate.

## Exploit Architecture 🏗️

This repository contains a professional Foundry-based exploit, strictly separating the on-chain weapon from the off-chain deployment script.

* **`src/AttackCoinFlip.sol`**: The on-chain "Drone". It contains an interface pointing to the target, reads the current block data, calculates the exact winning side, and natively calls `target.flip()`.
* **`script/HackCoinFlip.s.sol`**: The off-chain "Remote Control". A Foundry script that uses a private key to broadcast a transaction to Sepolia, deploying the Attack Contract and firing the first shot.
* **`test/CoinFlip.t.sol`**: The local laboratory. Tests that mathematically prove the `FACTOR` division vulnerability before going live.

## Execution Steps

**1. Deploy and Fire Shot #1**
```bash
forge script script/HackCoinFlip.s.sol:HackCoinFlip --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast