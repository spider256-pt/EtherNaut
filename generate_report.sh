#!/bin/bash

echo "🚀 Ethernaut Report Generator"
echo "------------------------------"

# Prompt for details
read -p "Enter Level Name/Number (e.g., 12 - Privacy): " LEVEL_NAME
read -p "Enter Vulnerability Name (e.g., Storage Collision): " VULN_NAME
read -p "Enter Test File Name (e.g., TestPrivacy.t.sol): " TEST_FILE
read -p "Enter Script File Name (e.g., AttackPrivacy.s.sol): " SCRIPT_FILE

# Define the output file
OUTPUT_FILE="Report.md"

# Generate the Markdown content
cat <<EOF > $OUTPUT_FILE
## 🎯 Objective
- [Enter the objective here]

---
## 📄 Contracts Overview
### $LEVEL_NAME
---
- [Enter contract details and variables here]

---
## 🧠 Vulnerability: $VULN_NAME
---
- [Explain the core vulnerability here]

---
## 🌪️ Attack Flow
---
- [Step 1]
- [Step 2]

---
## 🧪 Test — $TEST_FILE
---

| TestName | What it Checks |
| :--- | :--- |
| \`testName\` | Description of what this test verifies. |

### Key exploit line (in test):
---
\`\`\`solidity
// [Insert key test exploit code here]
\`\`\`
- [Explain the key exploit code]

---
## 🚀 On-chain Attack — $SCRIPT_FILE
---
\`\`\`solidity
// [Insert key script exploit code here]
\`\`\`
- [Explain the script automation]

---
## 🛠️ How to Run
---
### Run Tests (Local Anvil)
\`\`\`bash
forge test --mt [TestName] -vvvv
\`\`\`

### Deploy & Attack (On-chain)
\`\`\`bash 
forge script script/$SCRIPT_FILE --rpc-url \$SEPOLIA_RPC_URL --private-key \$PRIVATE_KEY --broadcast
\`\`\`

---
## 🔐 Key Concepts
---
- [Key takeaway 1]
- [Key takeaway 2]
EOF

echo "✅ Report boilerplate generated successfully in $OUTPUT_FILE!"
