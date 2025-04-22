use anchor_lang::prelude::*;

declare_id!("55555555555555555555555555555555");

#[program]
pub mod tastefi_restaurant_dashboard {
    use super::*;

    pub fn update_restaurant_profile(
        ctx: Context<UpdateRestaurantProfile>,
        name: String,
        ipfs_hash: String,
    ) -> Result<()> {
        let profile = &mut ctx.accounts.restaurant_profile;
        profile.name = name;
        profile.ipfs_hash = ipfs_hash; // Menu data stored on IPFS
        profile.owner = *ctx.accounts.owner.key;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct UpdateRestaurantProfile<'info> {
    #[account(mut)]
    pub restaurant_profile: Account<'info, RestaurantProfile>,
    #[account(mut)]
    pub owner: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[account]
pub struct RestaurantProfile {
    pub name: String,
    pub ipfs_hash: String,
    pub owner: Pubkey,
}
