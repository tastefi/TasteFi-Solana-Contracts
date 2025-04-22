#!/bin/bash

# Script to set up TasteFi Solana smart contract tests

# Variables
PROJECT_DIR="tastefi-solana-contracts"
TESTS_DIR="$PROJECT_DIR/tests"

# Step 1: Ensure project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: Project directory '$PROJECT_DIR' not found. Please run the initial setup script first."
  exit 1
fi
cd $PROJECT_DIR

# Step 2: Create tests directory
echo "Creating tests directory: $TESTS_DIR"
mkdir -p $TESTS_DIR

# Step 3: Create tastefi.ts test file
echo "Creating test file: tastefi.ts..."
cat > $TESTS_DIR/tastefi.ts << EOL
import * as anchor from "@coral-xyz/anchor";
import { Program, BN, AnchorProvider } from "@coral-xyz/anchor";
import { PublicKey, Keypair, SystemProgram } from "@solana/web3.js";
import { TOKEN_PROGRAM_ID, createMint, createAccount, mintTo } from "@solana/spl-token";
import { TastefiPaymentProcessing } from "../target/types/tastefi_payment_processing";
import { TastefiStakingYield } from "../target/types/tastefi_staking_yield";
import { TastefiCashbackProgram } from "../target/types/tastefi_cashback_program";
import { TastefiGovernance } from "../target/types/tastefi_governance";
import { TastefiRestaurantDashboard } from "../target/types/tastefi_restaurant_dashboard";
import { TastefiMenuStorage } from "../target/types/tastefi_menu_storage";

describe("TasteFi Contracts", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);
  const connection = provider.connection;
  const wallet = provider.wallet;

  const paymentProgram = anchor.workspace.TastefiPaymentProcessing as Program<TastefiPaymentProcessing>;
  const stakingProgram = anchor.workspace.TastefiStakingYield as Program<TastefiStakingYield>;
  const cashbackProgram = anchor.workspace.TastefiCashbackProgram as Program<TastefiCashbackProgram>;
  const governanceProgram = anchor.workspace.TastefiGovernance as Program<TastefiGovernance>;
  const dashboardProgram = anchor.workspace.TastefiRestaurantDashboard as Program<TastefiRestaurantDashboard>;
  const menuProgram = anchor.workspace.TastefiMenuStorage as Program<TastefiMenuStorage>;

  let mint: PublicKey;
  let userToken: PublicKey;
  let restaurantToken: PublicKey;
  let treasuryToken: PublicKey;
  let treasuryAuthority: Keypair;

  before(async () => {
    // Create $TASTE mint
    mint = await createMint(
      connection,
      wallet.payer,
      wallet.publicKey,
      null,
      9
    );

    // Create token accounts
    userToken = await createAccount(
      connection,
      wallet.payer,
      mint,
      wallet.publicKey
    );
    restaurantToken = await createAccount(
      connection,
      wallet.payer,
      mint,
      wallet.publicKey
    );

    // Create treasury token account and authority
    treasuryAuthority = Keypair.generate();
    treasuryToken = await createAccount(
      connection,
      wallet.payer,
      mint,
      treasuryAuthority.publicKey
    );

    // Mint $TASTE to user and treasury
    await mintTo(
      connection,
      wallet.payer,
      mint,
      userToken,
      wallet.publicKey,
      1000000 // 1M $TASTE
    );
    await mintTo(
      connection,
      wallet.payer,
      mint,
      treasuryToken,
      wallet.publicKey,
      1000000 // 1M $TASTE
    );
  });

  it("Tests payment processing", async () => {
    const paymentKeypair = Keypair.generate();
    const amount = 10000; // 10,000 $TASTE
    const cashbackRate = 2; // 2% standard rate

    await paymentProgram.methods
      .processPayment(new BN(amount), cashbackRate)
      .accounts({
        payment: paymentKeypair.publicKey,
        user: wallet.publicKey,
        userToken,
        restaurantToken,
        tokenProgram: TOKEN_PROGRAM_ID,
        systemProgram: SystemProgram.programId,
      })
      .signers([paymentKeypair])
      .rpc();

    const payment = await paymentProgram.account.payment.fetch(paymentKeypair.publicKey);
    assert.equal(payment.amount.toNumber(), amount);
    assert.equal(payment.cashbackRate, cashbackRate);
    assert.equal(payment.fee.toNumber(), amount / 100); // 1% fee
    assert.equal(payment.burn.toNumber(), amount / 1000); // 0.1% burn
  });

  it("Tests staking and yield", async () => {
    const stakeKeypair = Keypair.generate();
    const poolToken = await createAccount(
      connection,
      wallet.payer,
      mint,
      wallet.publicKey
    );
    const amount = 50000; // 50,000 $TASTE

    await stakingProgram.methods
      .stake(new BN(amount))
      .accounts({
        stake: stakeKeypair.publicKey,
        user: wallet.publicKey,
        userToken,
        poolToken,
        tokenProgram: TOKEN_PROGRAM_ID,
        systemProgram: SystemProgram.programId,
      })
      .signers([stakeKeypair])
      .rpc();

    const stake = await stakingProgram.account.stakeAccount.fetch(stakeKeypair.publicKey);
    assert.equal(stake.amount.toNumber(), amount);
    assert.equal(stake.user.toString(), wallet.publicKey.toString());
  });

  it("Tests cashback program", async () => {
    const cashbackKeypair = Keypair.generate();
    const amount = 10000; // 10,000 $TASTE transaction

    await cashbackProgram.methods
      .applyCashback(new BN(amount))
      .accounts({
        cashback: cashbackKeypair.publicKey,
        user: wallet.publicKey,
        userToken,
        treasuryToken,
        treasuryAuthority: treasuryAuthority.publicKey,
        tokenProgram: TOKEN_PROGRAM_ID,
        systemProgram: SystemProgram.programId,
      })
      .signers([cashbackKeypair, treasuryAuthority])
      .rpc();

    const cashback = await cashbackProgram.account.cashback.fetch(cashbackKeypair.publicKey);
    const expectedRate = 2; // 2% for <10,000 $TASTE holdings
    assert.equal(cashback.amount.toNumber(), (amount * expectedRate) / 100);
  });

  it("Tests governance", async () => {
    const proposalKeypair = Keypair.generate();
    const proposalDesc = "Increase cashback rate to 6%";
    const voteWeight = 1000;

    await governanceProgram.methods
      .propose(proposalDesc)
      .accounts({
        proposal: proposalKeypair.publicKey,
        user: wallet.publicKey,
        systemProgram: SystemProgram.programId,
      })
      .signers([proposalKeypair])
      .rpc();

    await governanceProgram.methods
      .vote(new BN(voteWeight))
      .accounts({
        proposal: proposalKeypair.publicKey,
        user: wallet.publicKey,
      })
      .rpc();

    const proposal = await governanceProgram.account.proposal.fetch(proposalKeypair.publicKey);
    assert.equal(proposal.description, proposalDesc);
    assert.equal(proposal.votes.toNumber(), voteWeight);
    assert.equal(proposal.proposer.toString(), wallet.publicKey.toString());
  });

  it("Tests restaurant dashboard", async () => {
    const profileKeypair = Keypair.generate();
    const name = "Joe's Bistro";
    const ipfsHash = "QmExampleHash";

    await dashboardProgram.methods
      .updateRestaurantProfile(name, ipfsHash)
      .accounts({
        restaurantProfile: profileKeypair.publicKey,
        owner: wallet.publicKey,
        systemProgram: SystemProgram.programId,
      })
      .signers([profileKeypair])
      .rpc();

    const profile = await dashboardProgram.account.restaurantProfile.fetch(profileKeypair.publicKey);
    assert.equal(profile.name, name);
    assert.equal(profile.ipfsHash, ipfsHash);
    assert.equal(profile.owner.toString(), wallet.publicKey.toString());
  });

  it("Tests menu storage", async () => {
    const menuKeypair = Keypair.generate();
    const ipfsHash = "QmMenuHash";

    await menuProgram.methods
      .storeMenuData(ipfsHash)
      .accounts({
        menu: menuKeypair.publicKey,
        restaurant: wallet.publicKey,
        systemProgram: SystemProgram.programId,
      })
      .signers([menuKeypair])
      .rpc();

    const menu = await menuProgram.account.menuData.fetch(menuKeypair.publicKey);
    assert.equal(menu.ipfsHash, ipfsHash);
    assert.equal(menu.restaurant.toString(), wallet.publicKey.toString());
  });
});
EOL

# Step 4: Update package.json to ensure test dependencies
echo "Updating package.json..."
cat > package.json << EOL
{
  "name": "tastefi-solana-contracts",
  "version": "0.1.0",
  "description": "Solana smart contracts for TasteFi decentralized dining platform",
  "scripts": {
    "lint": "eslint tests/*.ts",
    "test": "anchor test"
  },
  "dependencies": {
    "@coral-xyz/anchor": "^0.30.1",
    "@solana/web3.js": "^1.95.2",
    "@solana/spl-token": "^0.4.8"
  },
  "devDependencies": {
    "@types/bn.js": "^5.1.5",
    "@types/mocha": "^10.0.7",
    "@typescript-eslint/eslint-plugin": "^7.18.0",
    "@typescript-eslint/parser": "^7.18.0",
    "eslint": "^8.57.0",
    "mocha": "^10.7.3",
    "ts-mocha": "^10.0.0",
    "typescript": "^5.5.4"
  }
}
EOL

# Step 5: Initialize Git changes
echo "Adding test files to Git..."
git add tests/tastefi.ts package.json
git commit -m "Added test folder and tastefi.ts with Mocha tests for all contracts"

# Step 6: Install dependencies
echo "Installing Node.js dependencies..."
yarn install

# Step 7: Final instructions
echo "Test setup complete!"
echo "Next steps:"
echo "1. Ensure Solana local validator is running: 'solana-test-validator'"
echo "2. Build the project: 'anchor build'"
echo "3. Run tests: 'anchor test'"
echo "4. Push changes to GitHub:"
echo "   git push origin main"
echo "5. Enhance tests in 'tests/tastefi.ts' as you develop contract logic."
