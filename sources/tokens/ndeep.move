

module narval_faucet::ndeep;

use sui::coin;

use sui::url;

const DECIMALS: u8 = 9;
const SYMBOL: vector<u8> = b"nDEEP";
const NAME: vector<u8> = b"Narval DEEP";
const DESCRIPTION: vector<u8> = b"Narval DEEP";
const ICON_URL: vector<u8> = b"https://narval.fi/narval-deep-icon.png";



/// Coin type for test base assert
public struct NDEEP has drop {}

fun init(otw: NDEEP, ctx: &mut TxContext) {
    initialize(otw, ctx);
}

#[allow(lint(self_transfer))]
public fun initialize(otw: NDEEP, ctx: &mut TxContext) {
    let (treasury_cap, coin_metadata) = coin::create_currency(
        otw,
        DECIMALS,
        SYMBOL,
        NAME,
        DESCRIPTION,
        option::some(url::new_unsafe_from_bytes(ICON_URL)),
        ctx
    );

    transfer::public_share_object(coin_metadata);
    transfer::public_transfer(treasury_cap, ctx.sender());
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(NDEEP {}, ctx);
}