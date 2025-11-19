// ffi/go_ffi.go — Go Networking FFI

package main

import "C"
import "fmt"

//export OsoTitheSplit
func OsoTitheSplit(amount C.double) *C.char {
	tithe := float64(amount) * 0.0369
	splits := map[string]float64{
		"shrine":      tithe * 0.50,
		"inheritance": tithe * 0.25,
		"aio":         tithe * 0.15,
		"burn":        tithe * 0.10,
	}

	// Return as JSON
	json := `{"shrine": %f, "inheritance": %f, "aio": %f, "burn": %f}`
	result := C.CString(fmt.Sprintf(json, splits["shrine"], splits["inheritance"], splits["aio"], splits["burn"]))
	return result
}

func main() {}
