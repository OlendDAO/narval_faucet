module narval_faucet::main;

use sui::clock::Clock;
use sui::coin::TreasuryCap;

use narval_faucet::faucet::{Self, FaucetRegistry, FaucetAdmin};

entry fun create_faucet_cap_to(receiver: address, ctx: &mut TxContext) {
    // let cap = faucet::create_faucet_admin(ctx);
    // transfer::public_transfer(cap, receiver);
    abort 0
}

entry fun create_faucet_cap_by_admin(_cap: &FaucetAdmin, receiver: address, ctx: &mut TxContext) {
    let cap = faucet::create_faucet_admin(ctx);
    transfer::public_transfer(cap, receiver);
}

entry fun add_coin_config<T>(
    registry: &mut FaucetRegistry,
    treasury_cap: TreasuryCap<T>,
    max_supply: u64,
    mint_amount: u64,
    mint_interval_ms: u64,
) {
    faucet::add_coin_config<T>(registry, treasury_cap, max_supply, mint_amount, mint_interval_ms);
}

entry fun mint<T>(
    registry: &mut FaucetRegistry,
    amount: Option<u64>,
    clock: &Clock,
    ctx: &mut TxContext
) {
    faucet::mint<T>(registry, amount, clock, ctx);
}

entry fun mint_to<T>(
    registry: &mut FaucetRegistry,
    cap: &FaucetAdmin,
    amount: u64,
    receiver: address,
    clock: &Clock,
    ctx: &mut TxContext
) {
    faucet::mint_to<T>(registry, cap, amount, receiver, clock, ctx);
}

entry fun set_max_supply<T>(
    registry: &mut FaucetRegistry,
    cap: &FaucetAdmin,
    max_supply: u64,
) {
    faucet::set_max_supply<T>(registry, cap, max_supply);
}

entry fun set_mint_amount<T>(
    registry: &mut FaucetRegistry,
    cap: &FaucetAdmin,
    amount: u64,
) {
    faucet::set_mint_amount<T>(registry, cap, amount);
}

entry fun set_mint_interval<T>(
    registry: &mut FaucetRegistry,
    cap: &FaucetAdmin,
    interval_ms: u64,
) {
    faucet::set_mint_interval<T>(registry, cap, interval_ms);
}   

entry fun pause_mint<T>(
    registry: &mut FaucetRegistry,
    cap: &FaucetAdmin,
) {
    faucet::pause_mint<T>(registry, cap);
}

entry fun resume_mint<T>(
    registry: &mut FaucetRegistry,
    cap: &FaucetAdmin,
) {
    faucet::resume_mint<T>(registry, cap);
}