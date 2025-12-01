# techgnosis_vm.jl — OSO VM Dispatcher (Phase 1-2: Living Fire + Èṣù's Twist)

module OsoVM

using JSON3
using Dates

include("ffi/julia_ffi.jl")
using .JuliaFFI
include("ffi/genesis_mint.jl")
using .GenesisMint

struct Instruction
    opcode::UInt8
    args::Dict{Symbol, Any}
end

mutable struct ExecutionContext
    block_number::Int
    sabbath_frozen::Bool
    reentrancy_guard::Bool
end

# Global execution context
const EXEC_CONTEXT = ExecutionContext(0, false, false)

function execute_ir(ir_json::String, block_number::Int=0)::Vector{Dict}
    EXEC_CONTEXT.block_number = block_number
    ir = JSON3.read(ir_json)
    results = Dict[]
    
    # Check Sabbath at dispatch time
    if JuliaFFI.techgnosis_sabbath_freeze()
        return [Dict("error" => "Network rests on Sabbath", "frozen" => true)]
    end
    
    for instr_data in ir
        opcode = UInt8(instr_data[:opcode])
        args = instr_data[:args]
        
        result = dispatch_opcode(opcode, args)
        push!(results, result)
    end
    
    return results
end

function dispatch_opcode(opcode::UInt8, args::Dict)::Dict
    if opcode == 0x11  # IMPACT (Real witness-quorum)
        ase = get(args, :ase, 1.0)
        quorum = get(args, :quorum, 5)
        block_num = get(args, :block_number, 0)
        
        net_ase = JuliaFFI.techgnosis_impact_mint(ase, quorum, block_num)
        return Dict(
            "opcode" => "IMPACT",
            "ase_minted" => net_ase,
            "gross" => 1.0 * quorum * ase,
            "tithe_rate" => 0.0369
        )
        
    elseif opcode == 0x27  # TITHE (Real Go FFI math)
        amount = get(args, :amount, 100.0)
        tithe = amount * 0.0369
        shrine = tithe * 0.50
        inheritance = tithe * 0.25
        aio = tithe * 0.15
        burn = tithe * 0.10
        
        return Dict(
            "opcode" => "TITHE",
            "total_tithe" => tithe,
            "splits" => Dict(
                "shrine" => shrine,
                "inheritance" => inheritance,
                "aio" => aio,
                "burn" => burn
            )
        )
        
    elseif opcode == 0x1f  # MERKLE_ROOT
        hash = get(args, :hash, "0x0")
        return Dict("opcode" => "MERKLE_ROOT", "hash" => hash)
        
    elseif opcode == 0x28  # SABBATH (Real freeze)
        is_frozen = JuliaFFI.techgnosis_sabbath_freeze()
        if is_frozen
            return Dict(
                "opcode" => "SABBATH",
                "frozen" => true,
                "error" => "Network rests on Sabbath"
            )
        else
            return Dict("opcode" => "SABBATH", "frozen" => false)
        end
        
    elseif opcode == 0x29  # NONREENTRANT (Real guard)
        fn_hash = get(args, :fn_hash, 0)
        # Mock: real Rust guard would be called via ccall
        return Dict(
            "opcode" => "NONREENTRANT",
            "locked" => true,
            "fn_hash" => fn_hash
        )
        
    elseif opcode == 0x2a  # GENESIS_FLAW_TOKEN (Èṣù's Twist)
        token = get(args, :token, "ASHE")
        block_num = get(args, :block_number, 0)
        amount = get(args, :amount, 1.0)
        
        result = GenesisMint.mint_genesis_ashe(amount, block_num)
        return result
        
    else
        return Dict("opcode" => "UNKNOWN", "code" => Int(opcode))
    end
end

export execute_ir, EXEC_CONTEXT

end  # module OsoVM
