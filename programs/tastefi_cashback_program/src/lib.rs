use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, TokenAccount};

declare_id!("33333333333333333333333333333333");

#[program]
pub mod tastefi_cashback_program {
    use super::*;

    pub fn apply_cashback(ctx: Context<ApplyCashback>, amount: u64) -> Result<()> {
        let cashback = &mut ctx.accounts.cashback;
        let user_balance = ctx.accounts.user_token.amount;

        // Determine cashback rate: 5% if holding >10,000 , else 2%
        let rate = if user_balance > 10_000 { 5 } else { 2 };
        cashback.amount = (amount * rate as u64) / 100;

        // Transfer cashback  to user
        token::transfer(
            CpiContext::new(
                ctx.accounts.token_program.to_account_info(),
                token::Transfer {
                    from: ctx.accounts.treasury_token.to_account_info(),
                    to: ctx.accounts.user_token.to_account_info(),
                    authority: ctx.accounts.treasury_authority.to_account_info(),
                },
            ),
            cashback.amount,
        )?;

        Ok(())
    }
}

#[derive(Accounts)]
pub struct ApplyCashback<'info> {
    #[account(mut)]
    pub cashback: Account<'info, Cashback>,
    #[account(mut)]
    pub user: Signer<'info>,
    #[account(mut)]
    pub user_token: Account<'info, TokenAccount>,
    #[account(mut)]
    pub treasury_token: Account<'info, TokenAccount>,
    pub treasury_authority: AccountInfo<'info>,
    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info,
