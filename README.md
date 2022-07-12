# DODO Flashloans

## Technology Stack & Tools

- Solidity (Writing Smart Contract)
- Javascript (Testing)
- [Hardhat](https://hardhat.org/getting-started/) (Development Framework)
- [Ethers](https://docs.ethers.io/v5/) (Blockchain Interactions)
- [Alchemy](https://www.alchemy.com/) (Forking Mainnet)

## Requirements For Initial Setup
- Install [NodeJS](https://nodejs.org/en/), recommended version is v16.13.2

## Setting Up
### 1. Clone/Download the Repository

### 2. Install Dependencies:
`$ npm install`

### 3. Configure .env file:
Create a .env file, and fill in the following values (refer to the .env.example file):
- ALCHEMY_API_KEY="API_KEY"
- PRIVATE_KEY="YOUR_PRIVATE_KEY"

### 4. Run tests:
`npx hardhat test`

By default this will fork polygon mainnet and simulate the flashloan

### 5. Run deployment script:
`npx hardhat run --network polygon ./scripts/1_deploy.js`

Copy the deployed contract address logged to the console.

### 6. Edit flashloan script:
You'll want to paste in the address of the deployed contract on line 7

### 7. Run flashloan script:
`npx hardhat run --network polygon ./scripts/2_execute-flashloan.js`