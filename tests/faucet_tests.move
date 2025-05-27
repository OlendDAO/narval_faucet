
#[test_only]
module narval_faucet::faucet_tests;

use sui::test_scenario::{Self as ts, Scenario};

use narval_faucet::common_tests::{Self as ct, alice, bob};

#[test]
fun mint_should_work() {
    let mut sc0 = ts::begin(alice());

    let sc = &mut sc0;

    ct::create_clock_and_share(sc);
    ct::create_nlbtc_for_testing(sc, alice());

    
    sc0.end();

}