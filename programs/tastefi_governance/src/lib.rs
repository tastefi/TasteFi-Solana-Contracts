use anchor_lang::prelude::*;

declare_id!("44444444444444444444444444444444");

#[program]
pub mod tastefi_governance {
    use super::*;

    pub fn propose(ctx: Context<Propose>, proposal: String) -> Result<()> {
        let proposal_account = &mut ctx.accounts.proposal;
        proposal_account.description = proposal;
        proposal_account.votes = 0;
        proposal_account.proposer = *ctx.accounts.user.key;
        Ok(())
    }

    pub fn vote(ctx: Context<Vote>, vote_weight: u64) -> Result<()> {
        let proposal = &mut ctx.accounts.proposal;
        proposal.votes += vote_weight; // Weighted by $TASTE holdings
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Propose<'info> {
    #[account(mut)]
    pub proposal: Account<'info, Proposal>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Vote<'info> {
    #[account(mut)]
    pub proposal: Account<'info, Proposal>,
    #[account(mut)]
    pub user: Signer<'info>,
}

#[account]
pub struct Proposal {
    pub description: String,
    pub votes: u64,
    pub proposer: Pubkey,
}
