# TasteFi Solana Contracts

**TasteFi** is a decentralized platform revolutionizing the dining experience by integrating AI-driven menu translations with Web3 payment solutions. Powered by the \$TASTE token on the Solana blockchain, TasteFi enables seamless, multilingual menu access and cryptocurrency payments for restaurants worldwide. This repository contains the Solana smart contracts that form the backbone of TasteFi’s ecosystem, built using the [Anchor framework](https://www.anchor-lang.com/) for high-performance, secure development.

## Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Smart Contracts](#smart-contracts)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Testing](#testing)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Overview
TasteFi addresses two major pain points in the dining industry: inaccurate menu translations and cumbersome payment systems. By leveraging large language models (LLMs) for context-aware translations and Solana’s high-speed blockchain for crypto payments, TasteFi offers a user-centric platform with features like cashback, yield staking, and decentralized governance. These contracts power the following key functionalities:
- **AI-Powered Menu Translation**: Stores menu data on IPFS for processing by LLMs.
- **Crypto Payments**: Processes \$TASTE and other cryptocurrency transactions with low fees.
- **Cashback Program**: Rewards users with 2-5% \$TASTE cashback per transaction.
- **Yield Program**: Enables staking \$TASTE for 5-10% APY.
- **Restaurant Dashboard**: Manages restaurant profiles, payments, and feedback.
- **Decentralized Governance**: Allows \$TASTE holders to vote on platform upgrades.

This repository is part of TasteFi’s open-source initiative, aligning with the project’s litepaper and roadmap for a Q2 2025 MVP launch.

## Project Structure
The project is organized as an Anchor workspace with multiple Solana programs (smart contracts) and a test suite:
\`\`\`
tastefi-solana-contracts/
├── programs/
│   ├── tastefi_payment_processing/
│   │   └── src/lib.rs         # Handles \$TASTE payments, fees, and burns
│   ├── tastefi_staking_yield/
│   │   └── src/lib.rs         # Manages staking and yield distribution
│   ├── tastefi_cashback_program/
│   │   └── src/lib.rs         # Applies 2-5% cashback based on \$TASTE holdings
│   ├── tastefi_governance/
│   │   └── src/lib.rs         # Enables proposal and voting for \$TASTE holders
│   ├── tastefi_restaurant_dashboard/
│   │   └── src/lib.rs         # Manages restaurant profiles and metadata
│   ├── tastefi_menu_storage/
│   │   └── src/lib.rs         # Stores menu data on IPFS with on-chain hashes
├── tests/
│   └── tastefi.ts             # Mocha tests for all contracts
├── Anchor.toml                # Anchor configuration
├── Cargo.toml                 # Rust workspace configuration
├── package.json               # Node.js dependencies for testing
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
\`\`\`

## Smart Contracts
The following Solana programs power TasteFi’s core features:

### 1. Payment Processing (\`tastefi_payment_processing\`)
- **Purpose**: Facilitates \$TASTE payments from users to restaurants, deductrossing deducts a 1% transaction fee and burns 0.1% of \$TASTE per transaction.
- **Functionality**: Processes payments, allocates fees to liquidity pools, triggers cashback, and records transaction data.
- **Status**: Basic implementation complete; pending fee and burn logic.

### 2. Staking and Yield (\`tastefi_staking_yield\`)
- **Purpose**: Manages \$TASTE staking in liquidity pools, distributing 5-10% APY.
- **Functionality**: Allows users to stake and unstake \$TASTE, calculates yield based on pool size and fees.
- **Status**: Staking implemented; yield calculation TBD.

### 3. Cashback Program (\`tastefi_cashback_program\`)
- **Purpose**: Credits 2% (standard) or 5% (premium, >10,000 \$TASTE) cashback per transaction.
- **Functionality**: Verifies user holdings, transfers cashback from treasury, and records amounts.
- **Status**: Basic cashback logic complete; premium tier verification TBD.

### 4. Decentralized Governance (\`tastefi_governance\`)
- **Purpose**: Enables \$TASTE holders to propose and vote on platform upgrades.
- **Functionality**: Supports proposal creation and weighted voting based on \$TASTE holdings.
- **Status**: Proposal and voting implemented; token balance checks TBD.

### 5. Restaurant Dashboard (\`tastefi_restaurant_dashboard\`)
- **Purpose**: Manages restaurant profiles, payment history, and feedback.
- **Functionality**: Stores restaurant name, IPFS hash for menu data, and owner details.
- **Status**: Profile management complete; payment and feedback TBD.

### 6. Menu Data Storage (\`tastefi_menu_storage\`)
- **Purpose**: Stores menu data on IPFS with on-chain hashes for AI translation.
- **Functionality**: Records IPFS hashes and associates them with restaurants.
- **Status**: Basic storage implemented; IPFS upload logic TBD.

## Prerequisites
To develop and test the contracts, install the following:
- [Rust](https://www.rust-lang.org/tools/install) (latest stable)
- [Solana CLI](https://docs.solana.com/cli/install-solana-cli-tools) (v1.18.25)
- [Anchor](https://www.anchor-lang.com/docs/installation) (v0.30.1)
- [Node.js](https://nodejs.org/) (v16 or higher)
- [Yarn](https://yarnpkg.com/) (v1.22 or higher)
- [Git](https://git-scm.com/)

## Setup
1. **Clone the repository**:
   \`\`\`bash
   git clone https://github.com/<your-username>/TasteFi-Solana-Contracts.git
   cd TasteFi-Solana-Contracts
   \`\`\`

2. **Install Node.js dependencies**:
   \`\`\`bash
   yarn install
   \`\`\`

3. **Build the contracts**:
   \`\`\`bash
   anchor build
   \`\`\`

4. **Start a local Solana validator** (in a separate terminal):
   \`\`\`bash
   solana-test-validator
   \`\`\`

## Testing
The project includes a Mocha test suite in \`tests/tastefi.ts\` covering all contracts.
1. **Run tests**:
   \`\`\`bash
   anchor test
   \`\`\`
2. **Debug tests** (with logs):
   \`\`\`bash
   anchor test -- --show-logs
   \`\`\`

To add new tests, edit \`tests/tastefi.ts\` and use Anchor’s TypeScript client to interact with the contracts.

## Roadmap
The contracts align with TasteFi’s litepaper roadmap:
- **Q2 2025 (MVP)**: Implement core contracts (payment, cashback, menu storage) for initial testing.
- **Q3 2025 (Private Beta)**: Enhance staking and restaurant dashboard for restaurant onboarding.
- **Q4 2025 (Launch)**: Deploy all contracts, activate cashback and yield programs, onboard 1,000 restaurants.
- **Q1 2026 (Expansion)**: Activate governance, support additional cryptocurrencies (e.g., USDC).
- **Q2 2026 (Scale)**: Add advanced features (e.g., voice-based translations) via governance proposals.

## Contributing
We welcome contributions to TasteFi’s open-source ecosystem!
1. Fork the repository.
2. Create a feature branch (\`git checkout -b feature/my-feature\`).
3. Commit changes (\`git commit -m "Add my feature"\`).
4. Push to the branch (\`git push origin feature/my-feature\`).
5. Open a pull request.

Please include tests for new features and follow the [Anchor style guide](https://www.anchor-lang.com/docs/style-guide).


