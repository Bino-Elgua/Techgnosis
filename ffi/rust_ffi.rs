// ffi/rust_ffi.rs — Rust Safety FFI (Phase 1: Real Non-Reentrancy)

use std::os::raw::c_int;
use std::sync::Mutex;
use std::sync::atomic::{AtomicBool, Ordering};

static REENTRANCY_LOCK: Mutex<bool> = Mutex::new(false);
static SABBATH_FROZEN: AtomicBool = AtomicBool::new(false);

#[no_mangle]
pub extern "C" fn techgnosis_nonreentrant_guard(fn_hash: u64) -> c_int {
    // Real Mutex-based non-reentrancy guard
    match REENTRANCY_LOCK.lock() {
        Ok(mut locked) => {
            if *locked {
                0  // false (reentrancy detected)
            } else {
                *locked = true;
                1  // true (acquired lock)
            }
        }
        Err(_) => 0  // false (lock poisoned)
    }
}

#[no_mangle]
pub extern "C" fn techgnosis_nonreentrant_release(fn_hash: u64) -> c_int {
    // Release the lock
    match REENTRANCY_LOCK.lock() {
        Ok(mut locked) => {
            *locked = false;
            1  // true
        }
        Err(_) => 0  // false (lock poisoned)
    }
}

#[no_mangle]
pub extern "C" fn techgnosis_circuit_breaker(daily_mints: u64, soft_cap: u64) -> c_int {
    if daily_mints >= (soft_cap * 2) {
        0  // false (breaker tripped)
    } else {
        1  // true
    }
}

#[no_mangle]
pub extern "C" fn techgnosis_ethical_gate(action: *const u8) -> c_int {
    // Real de-escalation: check if Saturday UTC
    use chrono::{Datelike, Utc};
    let now = Utc::now();
    if now.weekday() == chrono::Weekday::Sat {
        SABBATH_FROZEN.store(true, Ordering::SeqCst);
        0  // false (frozen on Sabbath)
    } else {
        SABBATH_FROZEN.store(false, Ordering::SeqCst);
        1  // true
    }
}

#[no_mangle]
pub extern "C" fn techgnosis_sabbath_check() -> c_int {
    SABBATH_FROZEN.load(Ordering::SeqCst) as i32
}
