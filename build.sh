#!/bin/bash
# build.sh — One-click OSO build
set -e

echo "🔥 Building OSO Compiler Suite..."

# 1. Compile Rust FFI
echo "📦 Compiling Rust FFI..."
rustc --crate-type=cdylib ffi/rust_ffi.rs -o ffi/librust_ffi.so

# 2. Compile Go FFI
echo "📦 Compiling Go FFI..."
go build -buildmode=c-shared -o ffi/libgo_ffi.so ffi/go_ffi.go

# 3. Run Julia tests
echo "🧪 Running OSO tests..."
julia test/oso_vm_test.jl

echo "✅ OSO Compiler Suite built successfully!"
echo "🚀 Ready for Genesis: November 11, 2025, 11:11 UTC"
