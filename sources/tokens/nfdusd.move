

module narval_faucet::nfdusd;

use sui::coin;

use sui::url;

const DECIMALS: u8 = 9;
const SYMBOL: vector<u8> = b"nFDUSD";
const NAME: vector<u8> = b"Narval FDUSD";
const DESCRIPTION: vector<u8> = b"Narval FDUSD";
const ICON_URL: vector<u8> = b"https://narval.fi/narval-fdusd-icon.png";



/// Coin type for test base assert
public struct NFDUSD has drop {}

fun init(otw: NFDUSD, ctx: &mut TxContext) {
    initialize(otw, ctx);
}

#[allow(lint(self_transfer))]
public fun initialize(otw: NFDUSD, ctx: &mut TxContext) {
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
    init(NFDUSD {}, ctx);
}