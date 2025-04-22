use anchor_lang::prelude::*;

declare_id!("66666666666666666666666666666666");

#[program]
pub mod tastefi_menu_storage {
    use super::*;

    pub fn store_menu_data(ctx: Context<StoreMenuData>, ipfs_hash: String) -> Result<()> {
        let menu = &mut ctx.accounts.menu;
        menu.ipfs_hash = ipfs_hash;
        menu.restaurant = *ctx.accounts.restaurant.key;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct StoreMenuData<'info> {
    #[account(mut)]
    pub menu: Account<'info, MenuData>,
    #[account(mut)]
    pub restaurant: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[account]
pub struct MenuData {
    pub ipfs_hash: String,
    pub restaurant: Pubkey,
}
