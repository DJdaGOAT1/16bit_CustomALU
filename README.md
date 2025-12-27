# 16-bit Arithmetic Logic Unit (ALU)

## Overview
A parameterizable custom 16-bit Arithmetic Logic Unit implemented in Verilog HDL. The ALU features a complete instruction set with 16 distinct operations including arithmetic, logical, shift, rotate, and comparison operations, along with comprehensive status flag generation for processor integration.

**Language**: Verilog HDL (SystemVerilog compatible)  
**EDA Tool**: AMD (Xilinx) Vivado Design Suite  
**Architecture**: Pure combinational logic (asynchronous execution)

## Module Interface

**Parameters**: `alu_size` (default: 16-bit datapath)

**Inputs**:
- `A`, `B [alu_size-1:0]` - Dual operand ports
- `ALU_select [3:0]` - 4-bit operation decoder (16 instructions)
- `Enable` - Execution enable control

**Outputs**:
- `ALU_result [alu_size-1:0]` - Primary computational result
- `zero`, `negative`, `carry`, `overflow` - Condition code flags

## Supported Operations

| ALU_select | Operation | Description |
|------------|-----------|-------------|
| `4'b0000` | Addition | A + B (with carry and overflow detection) |
| `4'b0001` | Subtraction | A - B (with borrow and overflow detection) |
| `4'b0010` | Increment | A + 1 |
| `4'b0011` | Decrement | A - 1 |
| `4'b0100` | AND | A & B (bitwise) |
| `4'b0101` | OR | A \| B (bitwise) |
| `4'b0110` | XOR | A ^ B (bitwise) |
| `4'b0111` | NOT | ~A (bitwise complement) |
| `4'b1000` | Shift Left Logical | A << 1 (MSB to carry) |
| `4'b1001` | Shift Right Logical | A >> 1 (LSB to carry) |
| `4'b1010` | Shift Right Arithmetic | Sign-extended right shift |
| `4'b1011` | Rotate Left | Circular left shift |
| `4'b1100` | Rotate Right | Circular right shift |
| `4'b1101` | Equal To | Returns 1 if A == B |
| `4'b1110` | Greater Than | Returns 1 if A > B |
| `4'b1111` | Less Than | Returns 1 if A < B |

## Status Flags

- **Zero**: Asserted when result equals zero
- **Negative**: MSB of result (sign bit for two's complement representation)
- **Carry**: Carry-out from arithmetic operations; shifted bit for barrel shifter operations
- **Overflow**: Detects signed arithmetic overflow using XOR-based sign comparison logic

## Design Features

- Fully parameterizable bit-width architecture for scalability
- Single-cycle combinational execution across all operations
- Power-gated enable control (outputs driven to zero when disabled)
- Hardware-accelerated flag generation for seamless processor integration
- Case-optimized operation decoder for efficient synthesis

## Getting Started with the Project

### Running the Simulation in Vivado

1. **Open Vivado** and create a new project or open an existing one
2. **Add design files**:
   - Add `alu_design.v` as a design source
   - Add `alu_testbench.v` as a simulation source
3. **Set the testbench** as the top module for simulation:
   - Right-click on `alu_testbench.v` → Set as Top
4. **Run Behavioral Simulation**:
   - Click "Run Simulation" → "Run Behavioral Simulation"
5. **Analyze waveforms** to verify all 16 operations and status flags

### Synthesis (Optional)

To synthesize the design for an FPGA:
1. Ensure `alu_design.v` is set as the top module
2. Add appropriate constraints file (`.xdc`) for your target board
3. Run Synthesis → Implementation → Generate Bitstream

## Verification

The ALU design has been rigorously verified through simulation with an extensive testbench suite that validates all 16 operations across various corner cases, including signed/unsigned overflow conditions, boundary value analysis, and comprehensive flag coherency testing.
