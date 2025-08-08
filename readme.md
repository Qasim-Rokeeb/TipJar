
# 💸 TipJar Smart Contract

A decentralized tip jar contract built with Solidity that lets users send tips along with messages. It keeps track of contributors, their tip stats, and allows the owner to withdraw funds.

---

## 🚀 Deployment Details

- **Network:** Base Sepolia Testnet
- **Contract Name:** `TipJar`
- **Contract Address:** [`0x3c21847235A3658830b855a07972b03e111Cdbd0`](https://sepolia.basescan.org/address/0x3c21847235A3658830b855a07972b03e111Cdbd0)
- **Deployer Address:** `0x627773D1b0b10fbae4ac891a17886182a40a84c1b`
- **Verified on BaseScan:** ✅ Yes

---

## 📦 Features

- Accept tips with optional messages and names
- Leaderboard of top contributors
- Contributor profiles (name, total tipped, tip count)
- Owner-only fund withdrawals
- Transparent contributor registration
- On-chain events for tipping and withdrawals

---

## ✨ Smart Contract Functions

### Public Methods

| Function | Description |
|---------|-------------|
| `sendTip(string message, string name)` | Send a tip with an optional message and contributor name |
| `getTopContributors(uint256 limit)` | Returns a list of top contributors |
| `getContributor(address user)` | Get contributor stats |
| `getBalance()` | Check contract's current balance |
| `getTotalContributors()` | Total unique contributors |
| `updateName(string newName)` | Update contributor's name |

### Owner-only Methods

| Function | Description |
|---------|-------------|
| `withdraw()` | Withdraw all contract funds |
| `withdrawAmount(uint256 amount)` | Withdraw a specific amount |
| `transferOwnership(address newOwner)` | Transfer ownership of the contract |

---

## 🛠️ Compile & Deploy (Hardhat Example)

```bash
npm install --save-dev hardhat
npx hardhat compile
npx hardhat run scripts/deploy.js --network baseSepolia
````

*Replace `scripts/deploy.js` with your actual deployment script.*

---

## 🧪 Sample Deployment Script

```js
const hre = require("hardhat");

async function main() {
  const TipJar = await hre.ethers.getContractFactory("TipJar");
  const tipJar = await TipJar.deploy();
  await tipJar.deployed();
  console.log("TipJar deployed to:", tipJar.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

---

## 🧾 License

This project is licensed under the MIT License.

---

## 🤝 Contributions

Pull requests are welcome! Feel free to fork and build upon this.

---

