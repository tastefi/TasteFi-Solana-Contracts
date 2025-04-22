it("Test restaurant dashboard", async () => {
  const profileKeypair = anchor.web3.Keypair.generate();
  const name = "Joe's Bistro";
  const ipfsHash = "Qm...";
  await dashboardProgram.methods
    .updateRestaurantProfile(name, ipfsHash)
    .accounts({
      restaurantProfile: profileKeypair.publicKey,
      owner: provider.wallet.publicKey,
      systemProgram: anchor.web3.SystemProgram.programId,
    })
    .signers([profileKeypair])
    .rpc();
  const profile = await dashboardProgram.account.restaurantProfile.fetch(profileKeypair.publicKey);
  assert.equal(profile.name, name);
  assert.equal(profile.ipfsHash, ipfsHash);
  assert.equal(profile.owner.toString(), provider.wallet.publicKey.toString());
});
