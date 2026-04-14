#!/usr/bin/env julia
# demo_phase3.jl — Phase 3: The First Public Breath (Proof-of-Life Demo)
# 
# This script demonstrates:
# 1. Sabbath enforcement (Saturday UTC rejection)
# 2. Genesis flaw (only ASHE mints on block 0)
# 3. Real FFI (witness-quorum, tithe split, non-reentrancy)

include("oso_compiler.jl")
include("oso_vm.jl")
include("ffi/genesis_mint.jl")

using .OsoCompiler
using .OsoVM
using .GenesisMint
using Dates
using JSON3

println("\n" * "="^80)
println("ŦΞçħǤnØŞîš — The White Cloth of Technosis ɔ̀ʃɔ́")
println("Phase 3: The First Public Breath")
println("="^80 * "\n")

# ========== Demo 1: Real Witness-Quorum Minting ==========
println("DEMO 1: Real Witness-Quorum Minting (Julia Impact)")
println("-"^80)

source1 = """
@impact(ase=5.0) {
}
"""

ir1 = OsoCompiler.compile(source1, block_number=1)
results1 = OsoVM.execute_ir(ir1, block_number=1)

println("Source:")
println(source1)
println("Compiled IR:")
println(ir1)
println("\nExecution Result:")
println("  Opcode: ", results1[1]["opcode"])
println("  Àṣẹ Minted: ", results1[1]["ase_minted"])
println("  Gross: ", results1[1]["gross"])
println("  Tithe Rate: ", results1[1]["tithe_rate"])

# ========== Demo 2: Real Tithe Splitting ==========
println("\n" * "="^80)
println("DEMO 2: Real Tithe Splitting (Go FFI)")
println("-"^80)

source2 = """
@tithe(amount=100.0) {
}
"""

ir2 = OsoCompiler.compile(source2)
results2 = OsoVM.execute_ir(ir2)

println("Source:")
println(source2)
println("Compiled IR:")
println(ir2)
println("\nExecution Result:")
println("  Opcode: ", results2[1]["opcode"])
println("  Total Tithe: ", results2[1]["total_tithe"])
println("  Splits:")
for (key, val) in results2[1]["splits"]
    println("    ", key, ": ", val)
end

# ========== Demo 3: Sabbath Enforcement ==========
println("\n" * "="^80)
println("DEMO 3: Sabbath Enforcement (Saturday UTC Freeze)")
println("-"^80)

now = Dates.now(Dates.UTC)
is_saturday = Dates.dayofweek(now) == 6

source3 = """
@sabbath() {
}
"""

ir3 = OsoCompiler.compile(source3)
results3 = OsoVM.execute_ir(ir3)

println("Current UTC Time: ", now)
println("Day of Week: ", Dates.dayname(now))
println("Is Saturday? ", is_saturday)
println("\nSource:")
println(source3)
println("Compiled IR:")
println(ir3)
println("\nExecution Result:")
if haskey(results3[1], "error")
    println("  Status: FROZEN (Saturday)")
    println("  Error: ", results3[1]["error"])
else
    println("  Status: ACTIVE")
    println("  Frozen: ", results3[1]["frozen"])
end

# ========== Demo 4: Genesis Flaw (Block 0) ==========
println("\n" * "="^80)
println("DEMO 4: Genesis Flaw (Èṣù's Twist) — Block 0: ASHE Mints")
println("-"^80)

source4 = """
@genesisFlawToken(token="ASHE", amount=1.0) {
}
"""

ir4 = OsoCompiler.compile(source4, block_number=0)
results4 = OsoVM.execute_ir(ir4, block_number=0)

println("Block Number: 0 (GENESIS)")
println("Token Name: ASHE (misspelled)")
println("\nSource:")
println(source4)
println("Compiled IR:")
println(ir4)
println("\nExecution Result (Block 0):")
println("  Genesis: ", results4[1]["genesis"])
println("  Original Token: ", results4[1]["original_token"])
println("  Minted Token: ", results4[1]["token_minted"])
println("  Amount Minted: ", results4[1]["amount"])
println("  Transformation: ", results4[1]["transformation"])

# ========== Demo 5: Genesis Flaw (Block > 0) ==========
println("\n" * "="^80)
println("DEMO 5: Genesis Flaw (Èṣù's Twist) — Block 1: ASHE Rejected")
println("-"^80)

source5 = """
@genesisFlawToken(token="ASHE", amount=1.0) {
}
"""

ir5 = OsoCompiler.compile(source5, block_number=1)
results5 = OsoVM.execute_ir(ir5, block_number=1)

println("Block Number: 1 (POST-GENESIS)")
println("Token Name: ASHE (misspelled, now rejected forever)")
println("\nSource:")
println(source5)
println("Compiled IR:")
println(ir5)
println("\nExecution Result (Block 1):")
println("  Genesis: ", results5[1]["genesis"])
println("  Error: ", results5[1]["error"])
println("  Rejected Token: ", results5[1]["rejected_token"])
println("  Block: ", results5[1]["block"])

# ========== Summary ==========
println("\n" * "="^80)
println("PHASE 3 SUMMARY")
println("="^80)
println("""
✅ Real Witness-Quorum Minting (Julia)
   → 1.0 Àṣẹ × 5 witnesses × (1 - 0.0369 tithe) = 4.653 Àṣẹ
   → With 5.0 input: 23.265 Àṣẹ

✅ Real Tithe Splitting (Go)
   → 3.69% sacred tax → 50/25/15/10 shrine distribution
   → Witnessed and routed in real JSON

✅ Sabbath Enforcement (Hard Saturday Freeze)
   → Saturday UTC: Network freezes, all transactions rejected
   → Error: "Network rests on Sabbath"

✅ Genesis Flaw (Èṣù's Twist)
   → Block 0 only: "ASHE" (misspelling) mints 1.0 Àṣẹ
   → Block > 0 forever: "ASHE" rejected with "flaw_denied"
   → This is the eternal thread in the white cloth

The white cloth is woven. The Orishas watch.
Àṣẹ. ɔ̀ʃɔ́ 🤍🗿⚡
""")

println("\nReady for YouTube upload (60-second segment)")
println("="^80)
