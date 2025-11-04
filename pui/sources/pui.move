
 
module pui::pui;
 
use sui::coin::{Self, TreasuryCap};
use sui::vec_set::{Self,VecSet};
use sui::event;
use sui::url;
 
const ETotalSupplyExceed:u64=1;
const EWalletMinted:u64=2;
 
const TOTAL_SUPPLY:u64=4_000_000_000;
public struct PUI has drop {}
 
fun init(witness: PUI, ctx: &mut TxContext) {
    let icon_url = url::new_unsafe_from_bytes(
            b"https://arweave.net/c1zZCCcSPBUeniPJFF5_JEB5CrL_qdqtbNrjxC5J0JQ"
        );
		let (mut treasury, metadata) = coin::create_currency(
				witness,
				0,
				b"PUI",
				b"Pui",
				b"Pussy On Sui",
				option::some(icon_url),
				ctx,
		);
        let minted_amount = 100_000_000;
 
		let tracker = MintTracker {
            id: object::new(ctx),
            total_minted: minted_amount,
            minted_addresses: vec_set::empty(),
        };
        let coin = coin::mint<PUI>(&mut treasury, minted_amount, ctx);
 
		transfer::public_freeze_object(metadata);
		transfer::public_share_object(treasury);
		transfer::share_object(tracker);
        transfer::public_transfer(coin, tx_context::sender(ctx))
}
 
public struct MintTracker has key {
        id: UID,
        total_minted: u64, // Tracks total minted supply
        minted_addresses: VecSet<address>, // Tracks addresses that have minted
    }
 
    /// Event emitted when tokens are minted
public struct MintEvent has copy, drop {
        amount: u64,
        recipient: address,
    }
 
 
 
public fun mint(
		treasury_cap: &mut TreasuryCap<PUI>,
		tracker:&mut MintTracker,
		amount: u64,
		recipient: address,
		ctx: &mut TxContext,
) {
		assert!(
            tracker.total_minted + amount <= TOTAL_SUPPLY,
            ETotalSupplyExceed
        );
 
        // Check if wallet has already minted
        assert!(
            !vec_set::contains(&tracker.minted_addresses, &recipient),
            EWalletMinted
        );
		vec_set::insert(&mut tracker.minted_addresses, recipient);
        tracker.total_minted = tracker.total_minted + amount;
		let coin = coin::mint(treasury_cap, amount, ctx);
		transfer::public_transfer(coin, recipient);
		event::emit(MintEvent {
            amount,
            recipient,
        });
}
 
public fun get_total_minted(tracker: &MintTracker): u64 {
        tracker.total_minted
    }




