-- ffi/idris_ffi.idr — Idris Proof FFI

module OsoProofFFI

data Receipt = MkReceipt String  -- hash
data Delivery = MkDelivery String  -- hash

oso_verify_receipt : Receipt -> Delivery -> Bool
oso_verify_receipt (MkReceipt r_hash) (MkDelivery d_hash) =
  r_hash == d_hash
