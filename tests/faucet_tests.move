
#[test_only]
module narval_faucet::faucet_tests;

use sui::clock::Clock;

use narval_faucet::faucet::FaucetRegistry;
use narval_faucet::nlbtc::NLBTC;

use sui::test_scenario::{Self as ts, Scenario};

use narval_faucet::common_tests::{Self as ct, alice, bob};
use sui::coin::TreasuryCap;
use narval_faucet::faucet;
use narval_faucet::faucet::EInvalidMintInterval;
use narval_faucet::faucet::FaucetAdmin;
use narval_faucet::nmusd::NMUSD;

#[test]
fun mint_should_work() {
    let mut sc0 = ts::begin(alice());

    let sc = &mut sc0;

    ct::create_clock_and_share(sc);
    ct::create_nlbtc_for_testing(sc, alice());
    faucet::init_for_testing(sc.ctx());

    add_config_for_testing<NLBTC>(sc, alice(), 1_000_000_000_000_000_000, 1_000_000_000, 1000);
    
    ct::increase_clock_for_testing(sc, 1001, alice());

    mint_for_testing<NLBTC>(sc, alice(), option::none());
    
    // Check the balance
    ct::check_balance<NLBTC>(sc, alice(), 1_000_000_000);

    mint_for_testing<NLBTC>(sc, bob(), option::some(100_000_000));

    ct::check_balance<NLBTC>(sc, bob(), 100_000_000);

    sc0.end();

}

#[test, expected_failure(abort_code = EInvalidMintInterval)]
fun mint_interval_too_small_should_fail() {
    let mut sc0 = ts::begin(alice());

    let sc = &mut sc0;

    ct::create_clock_and_share(sc);
    ct::create_nlbtc_for_testing(sc, alice());
    faucet::init_for_testing(sc.ctx());

    add_config_for_testing<NLBTC>(sc, alice(), 1_000_000_000_000_000_000, 1_000_000_000, 1000);
    
    ct::increase_clock_for_testing(sc, 1000, alice());

    // should fail
    mint_for_testing<NLBTC>(sc, bob(), option::some(1_000_000_001));

    // ct::check_balance<NLBTC>(sc, bob(), 1_000_000_000);

    sc0.end();

}

#[test]
fun mint_to_should_work() {
    let mut sc0 = ts::begin(alice());

    let sc = &mut sc0;

    ct::create_clock_and_share(sc);
    ct::create_nmusd_for_testing(sc, alice());
    faucet::init_for_testing(sc.ctx());

    add_config_for_testing<NMUSD>(sc, alice(), 1_000_000_000_000_000_000, 1_000_000_000, 1000);

    mint_to_for_testing<NMUSD>(sc, alice(), 100_000_000_000_000, bob());

    ct::check_balance<NMUSD>(sc, bob(), 100_000_000_000_000);

    sc0.end();

}

/// Mint to should work
public fun mint_to_for_testing<T>(
    sc: &mut Scenario,
    sender: address,
    amount: u64,
    receiver: address,
) {
    sc.next_tx(sender);
    let mut faucet = sc.take_shared<FaucetRegistry>();
    let cap = sc.take_from_sender<FaucetAdmin>();
    let clock = sc.take_shared<Clock>();

    faucet.mint_to<T>(&cap, amount, receiver, &clock, sc.ctx());

    ts::return_shared(faucet);
    ts::return_shared(clock);
    sc.return_to_sender(cap);
}

public fun add_config_for_testing<T>(
    sc: &mut Scenario,
    sender: address,
    max_supply: u64,
    mint_amount: u64,
    mint_interval_ms: u64,
) {
    sc.next_tx(sender);
    let mut faucet = sc.take_shared<FaucetRegistry>();
    let cap = sc.take_from_sender<TreasuryCap<T>>();
    faucet.add_coin_config<T>(cap, max_supply, mint_amount, mint_interval_ms);

    ts::return_shared(faucet);
}

public fun mint_for_testing<T>(
    sc: &mut Scenario,
    sender: address,
    amount: Option<u64>,
) {
    sc.next_tx(sender);
    let mut faucet = sc.take_shared<FaucetRegistry>();
    let clock = sc.take_shared<Clock>();

    faucet.mint<T>(amount, &clock, sc.ctx());

    ts::return_shared(faucet);
    ts::return_shared(clock);
}   