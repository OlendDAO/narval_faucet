#[test_only]
module narval_faucet::common_tests;

use sui::clock::{Self, Clock};

use narval_faucet::faucet;
use narval_faucet::nlbtc;

use sui::test_scenario::{Self as ts, Scenario};

/// Alice address for testing
public fun alice(): address {
    @0x619640c96ee005ca6fa7530006b34358f1e638a386071ce229bb99db9486962d
}

/// Bob address for testing
public fun bob(): address {
    @0xdae2f56afc119ebddf5ca4ba80cd8a42fced9a74a7bb139c2bf6d0f3a77c497a
}

public fun create_clock_and_share(sc: &mut Scenario) {
    let clock = clock::create_for_testing(sc.ctx());
    
    clock.share_for_testing();
}

public fun increase_clock_for_testing(
    sc: &mut Scenario,
    seconds: u64,
    sender: address,
) {
    sc.next_tx(sender);
    let mut clock = sc.take_shared<Clock>();
    clock.increment_for_testing(seconds * 1000);
    ts::return_shared(clock);
}

public fun clock_timestamp_ms(sc: &mut Scenario): u64 {
    let clock = sc.take_shared<Clock>();
    let timestamp = clock.timestamp_ms();
    ts::return_shared(clock);
    
    timestamp
}

public fun create_nlbtc_for_testing(sc: &mut Scenario, sender: address) {
    sc.next_tx(sender);
    nlbtc::init_for_testing(sc.ctx());
}

public fun init_faucet_for_testing(sc: &mut Scenario, sender: address) {
    sc.next_tx(sender);
    faucet::init_for_testing(sc.ctx());
}