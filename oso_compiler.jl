# techgnosis_compiler.jl — OSO to IR Compiler (v1.0)
# Bínò ÈL Guà — Crown Architect
# Ọbàtálá — Master Auditor

module OsoCompiler

using JSON3

# ===== OSO GRAMMAR (Pest-style, converted to Julia regex) =====

const CORE_ATTRIBUTES = [
    :guardian, :impact, :collaboration, :ritual, :shrineSplit,
    :odùMap, :citizenCast, :projectForge, :royaltyFlow, :sensorQuorum,
    :glyphInvoke, :trinityBind, :quadrinityGov, :ethicalGate, :merkleRoot,
    :pbkdfDerive, :hexagramFlip, :akashProvision, :langChain, :witnessLog,
    :survivalPillar, :biponSeed, :tithe, :sabbath, :nonreentrant
]

const OPCODE_MAP = Dict(
    :guardian => 0x10,
    :impact => 0x11,
    :collaboration => 0x12,
    :ritual => 0x13,
    :shrineSplit => 0x14,
    :odùMap => 0x16,
    :citizenCast => 0x17,
    :projectForge => 0x18,
    :royaltyFlow => 0x19,
    :sensorQuorum => 0x1a,
    :glyphInvoke => 0x1b,
    :trinityBind => 0x1c,
    :quadrinityGov => 0x1d,
    :ethicalGate => 0x1e,
    :merkleRoot => 0x1f,
    :pbkdfDerive => 0x20,
    :hexagramFlip => 0x21,
    :akashProvision => 0x22,
    :langChain => 0x23,
    :witnessLog => 0x24,
    :survivalPillar => 0x25,
    :biponSeed => 0x26,
    :tithe => 0x27,
    :sabbath => 0x28,
    :nonreentrant => 0x29,
    :genesisFlawToken => 0x2a
)

struct Instruction
    opcode::UInt8
    args::Dict{Symbol, Any}
end

struct AST
    rituals::Vector{Ritual}
end

struct Ritual
    name::String
    attributes::Vector{Attribute}
end

struct Attribute
    type::Symbol
    args::Dict{Symbol, Any}
end

# ===== PARSER =====

function parse_oso(source::String)::AST
    rituals = Ritual[]
    
    # Simple regex-based parser (production would use full Pest port)
    ritual_pattern = r"(@\w+)\s*\(([^)]*)\)\s*\{([^}]*)\}"s
    
    for match in eachmatch(ritual_pattern, source)
        attr_name = Symbol(match.captures[1][2:end])  # Strip @
        args_str = match.captures[2]
        body = match.captures[3]
        
        args = parse_args(args_str)
        
        ritual = Ritual(
            String(attr_name),
            [Attribute(attr_name, args)]
        )
        push!(rituals, ritual)
    end
    
    return AST(rituals)
end

function parse_args(args_str::String)::Dict{Symbol, Any}
    args = Dict{Symbol, Any}()
    
    if isempty(strip(args_str))
        return args
    end
    
    # Parse key=value pairs
    for pair in split(args_str, ",")
        parts = split(strip(pair), "=")
        if length(parts) == 2
            key = Symbol(strip(parts[1]))
            val = strip(parts[2], ['"', ' '])
            
            # Type inference
            if occursin(r"^\d+\.\d+$", val)
                args[key] = parse(Float64, val)
            elseif occursin(r"^\d+$", val)
                args[key] = parse(Int64, val)
            elseif occursin(r"^0x[0-9a-fA-F]+$", val)
                args[key] = val  # Keep as hex string
            else
                args[key] = val  # String
            end
        end
    end
    
    return args
end

# ===== VALIDATOR =====

function validate_ast(ast::AST)::Nothing
    for ritual in ast.rituals
        for attr in ritual.attributes
            if !(attr.type in CORE_ATTRIBUTES)
                @warn "Unknown attribute: $(attr.type)"
            end
        end
    end
end

# ===== IR EMITTER =====

function emit_ir(ast::AST, block_number::Int=0)::Vector{Instruction}
    instructions = Instruction[]
    
    for ritual in ast.rituals
        for attr in ritual.attributes
            opcode = get(OPCODE_MAP, attr.type, 0x00)
            # Pass block_number to instructions
            args = copy(attr.args)
            args[:block_number] = block_number
            push!(instructions, Instruction(opcode, args))
        end
    end
    
    return instructions
end

# ===== PUBLIC API =====

function compile(source::String, block_number::Int=0)::String
    ast = parse_oso(source)
    validate_ast(ast)
    ir = emit_ir(ast, block_number)
    
    # Serialize to JSON
    ir_json = JSON3.write([
        Dict("opcode" => Int(instr.opcode), "args" => instr.args)
        for instr in ir
    ])
    
    return ir_json
end

export compile

end  # module OsoCompiler
