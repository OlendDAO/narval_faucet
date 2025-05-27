
module narval_faucet::faucet;

use std::type_name::{Self, TypeName};

use sui::clock::Clock;
use sui::coin::TreasuryCap;
use sui::event;
use sui::object_bag::{Self, ObjectBag};
use sui::table::{Self, Table};
use sui::vec_map::{Self, VecMap};

/* =========== Errors =========== */
const EMintNotAllow: u64 = 0;
const EInvalidMintInterval: u64 = 1;
const ECoinConfigAlreadyExists: u64 = 2;

/* =========== Events =========== */
public struct Minted has copy, drop {
    coin_type: TypeName,
    receiver: address,
    amount: u64,
    minted_ms: u64,
}

/* =========== Structs =========== */
public struct FaucetAdmin has key, store {
    id: UID,
}

public struct FaucetRegistry has key {
    id: UID,
    // Stores (TypeName, TreasuryCap) pairs
    treasuries: ObjectBag,
    coin_configs: VecMap<TypeName, Config>,
    minted: Table<address, MintInfo>,
}

public struct Config has store, copy, drop {
    coin_type: TypeName,
    max_supply: u64,
    mint_amount: u64,
    mint_interval_ms: u64,
    can_mint: bool,
}

public struct MintInfo has store, copy, drop {
    minted_amount: u64,
    last_minted_ms: u64,
}

/* =========== Initialize =========== */
fun init(ctx: &mut TxContext) {
    let faucet_registry = create_faucet(ctx);
    transfer::share_object(faucet_registry);

    let cap = FaucetAdmin {
        id: object::new(ctx),
    };

    transfer::public_transfer(cap, ctx.sender());
}

public fun create_faucet(ctx: &mut TxContext): FaucetRegistry {
    FaucetRegistry {
        id: object::new(ctx),
        treasuries: object_bag::new(ctx),
        coin_configs: vec_map::empty(),
        minted: table::new(ctx),
    } 
}

public fun mint<T>(
    registry: &mut FaucetRegistry,
    amount: Option<u64>,
    clock: &Clock,
    ctx: &mut TxContext
) {
    let coin_type = type_name::get<T>();
    let config = registry.coin_configs[&coin_type];

    assert!(config.can_mint, EMintNotAllow);

    let receiver = ctx.sender();

    if (!registry.minted.contains(receiver)) {
       registry.minted.add(receiver, MintInfo {
        minted_amount: 0,
        last_minted_ms: 0,
       });
    };
        
    let minted_info = &mut registry.minted[receiver];
    let current_ms = clock.timestamp_ms();

    assert!(
        minted_info.last_minted_ms + config.mint_interval_ms < current_ms, 
        EInvalidMintInterval
    );

    let config_amount = config.mint_amount;

    let mint_amount = amount.get_with_default(config_amount);

    let to_mint = mint_amount.min(config_amount);

    let treasury_cap = registry.treasuries.borrow_mut<TypeName, TreasuryCap<T>>(config.coin_type);

    minted_info.minted_amount = minted_info.minted_amount + to_mint;
    minted_info.last_minted_ms = current_ms;

    treasury_cap.mint_and_transfer(to_mint, receiver, ctx);

    event::emit(Minted {
        coin_type,
        receiver,
        amount: to_mint,
        minted_ms: clock.timestamp_ms(),
    });
}

public fun mint_to<T>(
    registry: &mut FaucetRegistry,
    _cap: &FaucetAdmin,
    amount: u64,
    receiver: address,
    clock: &Clock,
    ctx: &mut TxContext
) {
    let coin_type = type_name::get<T>();
    let treasury_cap = registry.treasuries.borrow_mut<TypeName, TreasuryCap<T>>(coin_type);

    treasury_cap.mint_and_transfer(amount, receiver, ctx);

    event::emit(Minted {
        coin_type,
        receiver,
        amount,
        minted_ms: clock.timestamp_ms(),
    });
}

/* =========== Admin Functions =========== */
/// Add coin config for a coin type
public fun add_coin_config<T>(
    registry: &mut FaucetRegistry,
    treasury_cap: TreasuryCap<T>,
    max_supply: u64,
    mint_amount: u64,
    mint_interval_ms: u64,
) {
    let coin_type = type_name::get<T>();
    
    assert!(!registry.treasuries.contains(coin_type), ECoinConfigAlreadyExists);

    registry.treasuries.add(coin_type, treasury_cap);

    let config = Config {
        coin_type,
        max_supply,
        mint_amount,
        mint_interval_ms,
        can_mint: true,
    };

    registry.coin_configs.insert(coin_type, config);
}

/// Set the max supply for a coin type
public fun set_max_supply<T>(
    registry: &mut FaucetRegistry,
    _cap: &FaucetAdmin,
    max_supply: u64,
) {
    let coin_type = type_name::get<T>();
    let config = &mut registry.coin_configs[&coin_type];

    config.max_supply = max_supply;
}

/// Set the mint amount for a coin type in a time
public fun set_mint_amount<T>(
    registry: &mut FaucetRegistry,
    _cap: &FaucetAdmin,
    amount: u64,
) {
    let coin_type = type_name::get<T>();
    let config = &mut registry.coin_configs[&coin_type];

    config.mint_amount = amount;
}

/// Set the mint interval for a coin type in a time
public fun set_mint_interval<T>(
    registry: &mut FaucetRegistry,
    _cap: &FaucetAdmin,
    interval_ms: u64,
) {
    let coin_type = type_name::get<T>();
    let config = &mut registry.coin_configs[&coin_type];

    config.mint_interval_ms = interval_ms;
}

/// Pause the minting for a coin type
public fun pause_mint<T>(
    registry: &mut FaucetRegistry,
    _cap: &FaucetAdmin,
) {
    let coin_type = type_name::get<T>();
    let config = &mut registry.coin_configs[&coin_type];

    config.can_mint = false;
}

/// Resume the minting for a coin type
public fun resume_mint<T>(
    registry: &mut FaucetRegistry,
    _cap: &FaucetAdmin,
) {
    let coin_type = type_name::get<T>();
    let config = &mut registry.coin_configs[&coin_type];

    config.can_mint = true;
}

/// Create a new FaucetAdmin object and transfer it to the receiver
public fun create_faucet_admin(
    ctx: &mut TxContext
): FaucetAdmin {
    FaucetAdmin {
        id: object::new(ctx),
    }
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}