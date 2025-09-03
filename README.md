# 🔐 FHE Demo – Private Voting on Ethereum

A demo project that shows how to build a private voting system on Ethereum using concepts from Fully Homomorphic Encryption (FHE). Instead of exposing raw votes on-chain, voters submit encrypted ballots. The contract aggregates votes without revealing individual choices.

This repository is designed for learning and experimentation with Solidity, Foundry, and TypeScript.

## 📂 Project Structure

```
/fhe-demo
├─ contracts/
│  └─ PrivateVote.sol        # Solidity smart contract for encrypted voting
├─ scripts/
│  └─ deploy.ts              # Deployment script using ethers.js
├─ test/
│  └─ PrivateVote.t.sol      # Foundry tests for the contract
├─ foundry.toml              # Foundry configuration
└─ package.json              # Node.js dependencies
```

## ⚡ Requirements

- **Node.js** v18+
- **npm** or **yarn**
- **Foundry** (for Solidity testing)
- A wallet private key & RPC URL (for deployment)

## 🚀 Setup

### 1. Clone the repository

```bash
git clone https://github.com/your-username/fhe-demo.git
cd fhe-demo
```

### 2. Install dependencies

```bash
npm install
```

### 3. Install Foundry (if not already installed)

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 4. Configure environment variables

Create a `.env` file in the root:

```env
PRIVATE_KEY=your_wallet_private_key
RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
```

## 📜 Smart Contract – PrivateVote.sol

The core contract handles:

- **Proposal creation** – Define what people are voting on
- **Encrypted vote submission** – Voters submit encrypted yes/no values
- **Tallying** – The contract aggregates results without exposing raw votes

> **🔒 Note:** For simplicity, this demo uses placeholder encryption (e.g., hashing or mocked values). Real FHE integration requires an external encryption library.

## 📦 Deployment

Run the deploy script with ts-node:

```bash
npx ts-node scripts/deploy.ts
```

If successful, you'll see output like:

```
✅ Contract deployed at: 0x1234abcd5678efgh...
```

## 🧪 Testing

Run Solidity unit tests with Foundry:

```bash
forge test
```

**Example tests included:**
- Voter submits an encrypted vote
- Contract tallies correctly
- Prevents double voting

## 🛠️ Example Usage

### Deploy contract

```bash
npx ts-node scripts/deploy.ts
```

### Cast a vote (pseudo example in ethers.js)

```javascript
await contract.castVote(userAddress, encryptVote("YES"));
```

### View results

```javascript
const tally = await contract.getTally();
console.log("Encrypted tally:", tally);
```

## ✨ Features

- **🔒 Privacy** – Individual votes stay hidden
- **⚡ On-chain verifiability** – Results can be verified by anyone
- **🛠️ Extensible** – Can be expanded into other private dApps

## 🤝 Contributing

Contributions welcome! Fork, branch, and submit PRs.

## 📄 License

MIT License - see LICENSE file for details.

## ⚠️ Disclaimer

This is a demonstration project for educational purposes. For production use, integrate with a proper FHE library and conduct thorough security audits.