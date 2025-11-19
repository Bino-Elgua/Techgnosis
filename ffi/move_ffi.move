// ffi/move_ffi.move — Move Resource FFI

module oso::resource_ffi {
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    struct Ase has key, store {
        id: UID,
        amount: u64,
    }

    public fun stake(ase: &mut Ase, amount: u64) {
        assert!(ase.amount >= amount, 1);
        ase.amount = ase.amount - amount;
    }

    public fun burn(ase: Ase) {
        let Ase { id, amount: _ } = ase;
        object::delete(id);
    }
}
