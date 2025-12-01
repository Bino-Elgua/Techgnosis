# test/techgnosis_vm_test.jl — OSO VM Tests

using Test

include("../techgnosis_compiler.jl")
include("../techgnosis_vm.jl")

using .OsoCompiler
using .OsoVM

@testset "OSO Compiler + VM" begin
    # Test 1: Basic @impact
    source1 = """
    @impact(ase=5.0) {
    }
    """
    ir1 = OsoCompiler.compile(source1)
    results1 = OsoVM.execute_ir(ir1)
    @test results1[1]["opcode"] == "IMPACT"
    @test results1[1]["ase_minted"] ≈ 23.265  # 5.0 × 5 witnesses × (1 - 0.0369)
    
    # Test 2: @tithe
    source2 = """
    @tithe(rate=0.0369) {
    }
    """
    ir2 = OsoCompiler.compile(source2)
    results2 = OsoVM.execute_ir(ir2)
    @test results2[1]["opcode"] == "TITHE"
    
    # Test 3: @merkleRoot
    source3 = """
    @merkleRoot(hash="0xabc123") {
    }
    """
    ir3 = OsoCompiler.compile(source3)
    results3 = OsoVM.execute_ir(ir3)
    @test results3[1]["opcode"] == "MERKLE_ROOT"
    @test results3[1]["hash"] == "0xabc123"
    
    # Test 4: @sabbath (mock Saturday)
    source4 = """
    @sabbath() {
    }
    """
    ir4 = OsoCompiler.compile(source4)
    results4 = OsoVM.execute_ir(ir4)
    @test results4[1]["opcode"] == "SABBATH"
end

println("✅ All OSO tests passed!")
