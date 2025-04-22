use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, TokenAccount};

declare_id!("11111111111111111111111111111111");

#[program]
pub mod tastefi_payment_processing {
    use super::*;

    pub fn process_payment(
        ctx: Context<ProcessPayment>,
        amount: u64,
        cashback_rate: u8, // 2 for standard, 5 for premium
    ) -> Result<()> {
        let payment = &mut ctx.accounts.payment;
        payment.amount = amount;
        payment.cashback_rate = cashback_rate;
        payment.fee = amount / 100; // 1% fee
        payment.burn = amount / 1000; // 0.1% burn

        // Transfer  to restaurant
        token::transfer(
            CpiContext::new(
                ctx.accounts.token_program.to_account_info(),
                token::Transfer {
                    from: ctx.accounts.user_token.to_account_info(),
                    to: ctx.accounts.restaurant_token.to_account_info(),
                    authority: ctx.accounts.user.to_account_info(),
                },
            ),
            amount - payment.fee - payment.burn,
        )?;

        // Allocate fee to liquidity pool (TBD)
        // Burn  (TBD)
        // Trigger cashback via cashback program (TBD)
        Ok(())
    }
}

#[derive(Accounts)]
pub struct ProcessPayment<'info> {
    #[account(mut)]
    pub payment: Account<'info, Payment>,
    #[account(mut)]
    pub user: Signer<'info>,
    #[account(mut)]
    pub user_token: Account<'info, TokenAccount>,
    #[account(mut)]
    pub restaurant_token: Account<'info, TokenAccount>,
    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
}

#[account]
pub struct Payment {
    pub amount: u64,
    pub cashback_rate: u8,
    pub fee: u64,
    pub burn: u64,
}
