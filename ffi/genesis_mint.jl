# ffi/genesis_mint.jl — Phase 2: Èṣù's Twist (The Sacred Misspelling)

module GenesisMint

"""
The genesis flaw: Only the misspelled token "ASHE" (not "Àṣẹ") 
mints on block 0. After block 0, "ASHE" is rejected forever.
This is the eternal thread in the cloth.
"""

function parse_genesis_token(token_name::String, block_number::Int)::Tuple{Bool, String}
    # Block 0: only "ASHE" (misspelled) mints
    if block_number == 0
        if token_name == "ASHE"
            return (true, "genesis_minted")
        else
            return (false, "only_ASHE_mints_on_block_0")
        end
    
    # Block > 0: "ASHE" is forever rejected, "Àṣẹ" (correct) accepted
    elseif block_number > 0
        if token_name == "ASHE"
            return (false, "flaw_denied_post_genesis")
        elseif token_name == "Àṣẹ" || token_name == "ASE"
            return (true, "post_genesis_mint")
        else
            return (false, "unknown_token")
        end
    end
    
    return (false, "unknown_state")
end

function mint_genesis_ashe(amount::Float64, block_number::Int)::Dict
    """
    If block_number == 0 && token == "ASHE":
        mint 1.0 Àṣẹ + set genesis=true
    Else:
        reject with "flaw_denied"
    """
    if block_number == 0
        # Genesis moment: the flaw creates 1.0 Àṣẹ
        return Dict(
            "genesis" => true,
            "token_minted" => "Àṣẹ",
            "amount" => 1.0,
            "block" => 0,
            "original_token" => "ASHE",
            "transformation" => "misspelling → precision"
        )
    else
        # After genesis, flaw is denied
        return Dict(
            "genesis" => false,
            "error" => "flaw_denied",
            "block" => block_number,
            "rejected_token" => "ASHE"
        )
    end
end

export parse_genesis_token, mint_genesis_ashe

end  # module GenesisMint
