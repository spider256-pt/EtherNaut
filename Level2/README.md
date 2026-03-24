
☢️ Ethernaut Level 2: Fallout
Author: Pratik
Role: Smart Contract Engineer & Security Auditor
Framework: Foundry (Solidity ^0.8.18)

📝 Objective
The goal of this level is to claim ownership of the Fallout contract and drain its balance.

This contract is a historical recreation of the infamous 2016 "Rubixi" hack, demonstrating the catastrophic dangers of constructor misconfigurations in early Solidity versions.

🔍 The Vulnerability
Prior to Solidity 0.4.22, constructors were defined by creating a function with the exact same name as the contract.

In Fallout.sol, the developer made a fatal typographical error:

Contract Name: Fallout

Constructor Name: Fal1out (Spelled with a '1')

Solidity
/* Constructor */
function Fal1out() public payable {
    owner = msg.sender;
    allocations[owner] = msg.value;
}
Because the EVM compiler did not recognize Fal1out as the constructor, it treated it as a standard, public function. This left the primary access-control mechanism completely exposed, allowing any external actor to call the function and overwrite the owner state variable.

🛠️ The Foundry Engineering (Bypassing Pragma Clashes)
The target contract was written in ^0.6.0. Standard Foundry testing libraries (forge-std) require ^0.8.13. Simply importing the legacy contract into a modern test file causes a fatal compiler version clash.

To solve this and maintain a modern 0.8.18 testing environment, I utilized the Interface & Proxy Deployment Pattern:

Quarantined the 0.6.0 legacy code in the src folder.

Created an IFallOut interface in the test file to define the required function signatures.

Used Foundry's deployCode("FallOut.sol:Fallout_Sol") cheatcode to compile and deploy the legacy bytecode in the background.

Wrapped the deployed address in the modern interface.

🧪 Audit & Exploit Execution
My test suite (TestFallout.t.sol) implements a strict Arrange-Act-Assert methodology to map the floorplan and execute the exploit:

Functional Testing (testCollectAllocation): Proved that the onlyOwner access control modifier successfully blocks unauthorized access (using vm.expectRevert()) and allows the true owner to drain the vault.

State Vulnerability (testsendAllocation): Discovered a secondary accounting flaw. The contract sends allocated ETH back to the user but fails to decrement their internal balance, creating an infinite withdrawal loop.

The Kill Shot (testFal1out): 1. Pranked as the attacker.
2. Called the exposed Fal1out{value: 1 wei}() function.
3. Successfully asserted that the attacker hijacked the owner title.
4. Called collectAllocations() to sweep the vault.

🚀 How to Run Locally
Clone the repository.

Install dependencies: forge install

Execute the exploit test:

Bash
forge test --mt testFal1out -vvvv
