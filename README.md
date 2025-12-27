# 16-bit Arithmetic Logic Unit (ALU)

## Overview
A parameterizable Custom 16-bit Arithmetic Logic Unit implemented in Verilog HDL. The ALU supports 16 operations including arithmetic, logical, shift, rotate, and comparison operations with status flag generation.

**Language**: Verilog HDL (SystemVerilog compatible)  
**EDA Tool**: AMD (Xilinx) Vivado Tool
**Design Type**: Combinational logic (asynchronous)

## Module Interface

**Parameters**: `alu_size` (default: 16)

**Inputs**:
- `A`, `B [alu_size-1:0]` - Operands
- `ALU_select [3:0]` - Operation selector
- `Enable` - Enable control

**Outputs**:
- `ALU_result [alu_size-1:0]` - Operation result
- `zero`, `negative`, `carry`, `overflow` - Status flags

## Supported Operations

| ALU_select | Operation | Description |
|------------|-----------|-------------|
| `4'b0000` | Addition | A + B (with carry and overflow) |
| `4'b0001` | Subtraction | A - B (with borrow and overflow) |
| `4'b0010` | Increment | A + 1 |
| `4'b0011` | Decrement | A - 1 |
| `4'b0100` | AND | A & B (bitwise) |
| `4'b0101` | OR | A | B (bitwise) |
| `4'b0110` | XOR | A ^ B (bitwise) |
| `4'b0111` | NOT | ~A (bitwise) |
| `4'b1000` | Shift Left Logical | A << 1 |
| `4'b1001` | Shift Right Logical | A >> 1 |
| `4'b1010` | Shift Right Arithmetic | Sign-extended right shift |
| `4'b1011` | Rotate Left | Circular left shift |
| `4'b1100` | Rotate Right | Circular right shift |
| `4'b1101` | Equal To | Returns 1 if A == B |
| `4'b1110` | Greater Than | Returns 1 if A > B |
| `4'b1111` | Less Than | Returns 1 if A < B |

## Status Flags

- **Zero**: Set when result equals zero
- **Negative**: MSB of result (sign bit in two's complement)
- **Carry**: Carry out from arithmetic operations, shifted bit for shifts/rotates
- **Overflow**: Detects signed overflow in addition/subtraction operations

## Design Features

- Parameterizable bit-width for scalability
- All operations complete combinationally
- Enable control drives all outputs to zero when disabled
- Comprehensive status flag generation for processor integration

## Simulation

The design has been verified through simulation with a comprehensive testbench that exercises all 16 operations, including edge cases for overflow and carry conditions.
