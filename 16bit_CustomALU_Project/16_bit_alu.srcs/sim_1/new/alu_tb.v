`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2025 06:11:50 PM
// Design Name: 
// Module Name: alu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module alu_tb;
    parameter alu_size = 16;
    
    // Testbench signals
    reg [alu_size-1:0] A;
    reg [alu_size-1:0] B;
    reg [3:0] ALU_select;
    reg Enable;
    wire [alu_size-1:0] ALU_result;
    wire zero, negative, carry, overflow;
    
    // Instantiate the ALU
    alu_design #(.alu_size(alu_size)) uut (
        .A(A),
        .B(B),
        .ALU_select(ALU_select),
        .Enable(Enable),
        .ALU_result(ALU_result),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );
    
    // Test counter
    integer test_num = 0;
    integer errors = 0;
    
    // Task to display results
    task display_result;
        input [79:0] operation;
        begin
            $display("Test %0d: %s", test_num, operation);
            $display("  A=%h (%0d), B=%h (%0d), Select=%b", A, A, B, B, ALU_select);
            $display("  Result=%h (%0d), Z=%b, N=%b, C=%b, V=%b", 
                     ALU_result, ALU_result, zero, negative, carry, overflow);
            $display("");
        end
    endtask
    
    // Task to check result
    task check_result;
        input [alu_size-1:0] expected_result;
        input expected_zero;
        input expected_negative;
        input expected_carry;
        input [79:0] operation;
        begin
            if (ALU_result !== expected_result || zero !== expected_zero || 
                negative !== expected_negative || carry !== expected_carry) begin
                $display("ERROR in Test %0d (%s):", test_num, operation);
                $display("  Expected: Result=%h, Z=%b, N=%b, C=%b", 
                         expected_result, expected_zero, expected_negative, expected_carry);
                $display("  Got:      Result=%h, Z=%b, N=%b, C=%b", 
                         ALU_result, zero, negative, carry);
                errors = errors + 1;
            end
        end
    endtask
    
    initial begin
        $display("=== ALU Testbench Starting (alu_size = %0d) ===\n", alu_size);
        
        // Initialize inputs
        A = 0;
        B = 0;
        ALU_select = 0;
        Enable = 0;
        #10;
        
        // Test Enable = 0 (ALU disabled)
        test_num = test_num + 1;
        Enable = 0;
        A = 16'hFFFF;
        B = 16'h0001;
        ALU_select = 4'b0000;
        #10;
        display_result("Enable = 0 (ALU Disabled)");
        check_result(16'h0000, 1, 0, 0, "Disabled");
        
        // Enable ALU for remaining tests
        Enable = 1;
        
        // ===== Arithmetic Operations =====
        $display("=== Testing Arithmetic Operations ===\n");
        
        // Test 1: Addition (no carry, no overflow)
        test_num = test_num + 1;
        A = 16'h1234; // 4660
        B = 16'h0ABC; // 2748
        ALU_select = 4'b0000;
        #10;
        display_result("Addition: 0x1234 + 0x0ABC = 0x1CF0");
        check_result(16'h1CF0, 0, 0, 0, "Addition");
        
        // Test 2: Addition with carry
        test_num = test_num + 1;
        A = 16'hFFFF; // 65535
        B = 16'h0001; // 1
        ALU_select = 4'b0000;
        #10;
        display_result("Addition with Carry: 0xFFFF + 0x0001 = 0x0000 (carry)");
        check_result(16'h0000, 1, 0, 1, "Add w/ Carry");
        
        // Test 3: Addition with overflow (signed)
        test_num = test_num + 1;
        A = 16'h7FFF; // +32767 (max positive)
        B = 16'h0001; // +1
        ALU_select = 4'b0000;
        #10;
        display_result("Addition with Overflow: 0x7FFF + 0x0001 = 0x8000");
        check_result(16'h8000, 0, 1, 0, "Add Overflow");
        
        // Test 4: Large addition
        test_num = test_num + 1;
        A = 16'h8000; // 32768
        B = 16'h4000; // 16384
        ALU_select = 4'b0000;
        #10;
        display_result("Large Addition: 0x8000 + 0x4000 = 0xC000");
        check_result(16'hC000, 0, 1, 0, "Large Add");
        
        // Test 5: Subtraction (no borrow)
        test_num = test_num + 1;
        A = 16'h5000; // 20480
        B = 16'h2000; // 8192
        ALU_select = 4'b0001;
        #10;
        display_result("Subtraction: 0x5000 - 0x2000 = 0x3000");
        check_result(16'h3000, 0, 0, 1, "Subtraction");
        
        // Test 6: Subtraction with borrow
        test_num = test_num + 1;
        A = 16'h2000; // 8192
        B = 16'h5000; // 20480
        ALU_select = 4'b0001;
        #10;
        display_result("Subtraction with Borrow: 0x2000 - 0x5000 = 0xD000");
        check_result(16'hD000, 0, 1, 0, "Sub Borrow");
        
        // Test 7: Subtraction resulting in zero
        test_num = test_num + 1;
        A = 16'hABCD;
        B = 16'hABCD;
        ALU_select = 4'b0001;
        #10;
        display_result("Subtraction Zero: 0xABCD - 0xABCD = 0x0000");
        check_result(16'h0000, 1, 0, 1, "Sub Zero");
        
        // Test 8: Increment
        test_num = test_num + 1;
        A = 16'h1234;
        B = 16'h0000;
        ALU_select = 4'b0010;
        #10;
        display_result("Increment: 0x1234 + 1 = 0x1235");
        check_result(16'h1235, 0, 0, 0, "Increment");
        
        // Test 9: Increment with carry
        test_num = test_num + 1;
        A = 16'hFFFF;
        B = 16'h0000;
        ALU_select = 4'b0010;
        #10;
        display_result("Increment with Carry: 0xFFFF + 1 = 0x0000");
        check_result(16'h0000, 1, 0, 1, "Inc Carry");
        
        // Test 10: Decrement
        test_num = test_num + 1;
        A = 16'h1234;
        B = 16'h0000;
        ALU_select = 4'b0011;
        #10;
        display_result("Decrement: 0x1234 - 1 = 0x1233");
        check_result(16'h1233, 0, 0, 1, "Decrement");
        
        // Test 11: Decrement to zero
        test_num = test_num + 1;
        A = 16'h0001;
        B = 16'h0000;
        ALU_select = 4'b0011;
        #10;
        display_result("Decrement to Zero: 0x0001 - 1 = 0x0000");
        check_result(16'h0000, 1, 0, 1, "Dec Zero");
        
        // ===== Logical Operations =====
        $display("=== Testing Logical Operations ===\n");
        
        // Test 12: AND
        test_num = test_num + 1;
        A = 16'hFF00;
        B = 16'h0F0F;
        ALU_select = 4'b0100;
        #10;
        display_result("AND: 0xFF00 & 0x0F0F = 0x0F00");
        check_result(16'h0F00, 0, 0, 0, "AND");
        
        // Test 13: AND resulting in zero
        test_num = test_num + 1;
        A = 16'hFF00;
        B = 16'h00FF;
        ALU_select = 4'b0100;
        #10;
        display_result("AND Zero: 0xFF00 & 0x00FF = 0x0000");
        check_result(16'h0000, 1, 0, 0, "AND Zero");
        
        // Test 14: OR
        test_num = test_num + 1;
        A = 16'hF0F0;
        B = 16'h0F0F;
        ALU_select = 4'b0101;
        #10;
        display_result("OR: 0xF0F0 | 0x0F0F = 0xFFFF");
        check_result(16'hFFFF, 0, 1, 0, "OR");
        
        // Test 15: OR with negative result
        test_num = test_num + 1;
        A = 16'h8000;
        B = 16'h4000;
        ALU_select = 4'b0101;
        #10;
        display_result("OR: 0x8000 | 0x4000 = 0xC000");
        check_result(16'hC000, 0, 1, 0, "OR Neg");
        
        // Test 16: XOR
        test_num = test_num + 1;
        A = 16'hAAAA;
        B = 16'h5555;
        ALU_select = 4'b0110;
        #10;
        display_result("XOR: 0xAAAA ^ 0x5555 = 0xFFFF");
        check_result(16'hFFFF, 0, 1, 0, "XOR");
        
        // Test 17: XOR with same values (result = 0)
        test_num = test_num + 1;
        A = 16'h1234;
        B = 16'h1234;
        ALU_select = 4'b0110;
        #10;
        display_result("XOR Same: 0x1234 ^ 0x1234 = 0x0000");
        check_result(16'h0000, 1, 0, 0, "XOR Same");
        
        // Test 18: NOT
        test_num = test_num + 1;
        A = 16'hAAAA;
        B = 16'h0000;
        ALU_select = 4'b0111;
        #10;
        display_result("NOT: ~0xAAAA = 0x5555");
        check_result(16'h5555, 0, 0, 0, "NOT");
        
        // Test 19: NOT all zeros
        test_num = test_num + 1;
        A = 16'h0000;
        B = 16'h0000;
        ALU_select = 4'b0111;
        #10;
        display_result("NOT: ~0x0000 = 0xFFFF");
        check_result(16'hFFFF, 0, 1, 0, "NOT Zeros");
        
        // Test 20: NOT all ones
        test_num = test_num + 1;
        A = 16'hFFFF;
        B = 16'h0000;
        ALU_select = 4'b0111;
        #10;
        display_result("NOT: ~0xFFFF = 0x0000");
        check_result(16'h0000, 1, 0, 0, "NOT Ones");
        
        // ===== Shift Operations =====
        $display("=== Testing Shift Operations ===\n");
        
        // Test 21: Shift Left Logical
        test_num = test_num + 1;
        A = 16'h1234;
        B = 16'h0000;
        ALU_select = 4'b1000;
        #10;
        display_result("Shift Left: 0x1234 << 1 = 0x2468");
        check_result(16'h2468, 0, 0, 0, "SLL");
        
        // Test 22: Shift Left with carry out
        test_num = test_num + 1;
        A = 16'h8001;
        B = 16'h0000;
        ALU_select = 4'b1000;
        #10;
        display_result("Shift Left Carry: 0x8001 << 1 = 0x0002");
        check_result(16'h0002, 0, 0, 1, "SLL Carry");
        
        // Test 23: Shift Left resulting in negative
        test_num = test_num + 1;
        A = 16'h4000;
        B = 16'h0000;
        ALU_select = 4'b1000;
        #10;
        display_result("Shift Left to Negative: 0x4000 << 1 = 0x8000");
        check_result(16'h8000, 0, 1, 0, "SLL Neg");
        
        // Test 24: Shift Right Logical
        test_num = test_num + 1;
        A = 16'h8000;
        B = 16'h0000;
        ALU_select = 4'b1001;
        #10;
        display_result("Shift Right Logical: 0x8000 >> 1 = 0x4000");
        check_result(16'h4000, 0, 0, 0, "SRL");
        
        // Test 25: Shift Right Logical with carry
        test_num = test_num + 1;
        A = 16'h1235;
        B = 16'h0000;
        ALU_select = 4'b1001;
        #10;
        display_result("Shift Right Carry: 0x1235 >> 1 = 0x091A");
        check_result(16'h091A, 0, 0, 1, "SRL Carry");
        
        // Test 26: Shift Right Arithmetic (negative)
        test_num = test_num + 1;
        A = 16'hF000; // Negative number
        B = 16'h0000;
        ALU_select = 4'b1010;
        #10;
        display_result("Shift Right Arithmetic: 0xF000 >>> 1 = 0xF800");
        check_result(16'hF800, 0, 1, 0, "SRA Neg");
        
        // Test 27: Shift Right Arithmetic (positive)
        test_num = test_num + 1;
        A = 16'h7000; // Positive number
        B = 16'h0000;
        ALU_select = 4'b1010;
        #10;
        display_result("Shift Right Arithmetic: 0x7000 >>> 1 = 0x3800");
        check_result(16'h3800, 0, 0, 0, "SRA Pos");
        
        // Test 28: Shift Right Arithmetic with carry
        test_num = test_num + 1;
        A = 16'h8001; // Negative with LSB set
        B = 16'h0000;
        ALU_select = 4'b1010;
        #10;
        display_result("Shift Right Arithmetic Carry: 0x8001 >>> 1 = 0xC000");
        check_result(16'hC000, 0, 1, 1, "SRA Carry");
        
        // Test 29: Rotate Left
        test_num = test_num + 1;
        A = 16'h8001;
        B = 16'h0000;
        ALU_select = 4'b1011;
        #10;
        display_result("Rotate Left: 0x8001 ROL = 0x0003");
        check_result(16'h0003, 0, 0, 1, "ROL");
        
        // Test 30: Rotate Left (no MSB)
        test_num = test_num + 1;
        A = 16'h1234;
        B = 16'h0000;
        ALU_select = 4'b1011;
        #10;
        display_result("Rotate Left: 0x1234 ROL = 0x2468");
        check_result(16'h2468, 0, 0, 0, "ROL No MSB");
        
        // Test 31: Rotate Left all ones
        test_num = test_num + 1;
        A = 16'hFFFF;
        B = 16'h0000;
        ALU_select = 4'b1011;
        #10;
        display_result("Rotate Left: 0xFFFF ROL = 0xFFFF");
        check_result(16'hFFFF, 0, 1, 1, "ROL All Ones");
        
        // Test 32: Rotate Right
        test_num = test_num + 1;
        A = 16'h8001;
        B = 16'h0000;
        ALU_select = 4'b1100;
        #10;
        display_result("Rotate Right: 0x8001 ROR = 0xC000");
        check_result(16'hC000, 0, 1, 1, "ROR");
        
        // Test 33: Rotate Right (no LSB)
        test_num = test_num + 1;
        A = 16'h1234;
        B = 16'h0000;
        ALU_select = 4'b1100;
        #10;
        display_result("Rotate Right: 0x1234 ROR = 0x091A");
        check_result(16'h091A, 0, 0, 0, "ROR No LSB");
        
        // ===== Comparison Operations =====
        $display("=== Testing Comparison Operations ===\n");
        
        // Test 34: Equal (True)
        test_num = test_num + 1;
        A = 16'h5A5A;
        B = 16'h5A5A;
        ALU_select = 4'b1101;
        #10;
        display_result("Equal: 0x5A5A == 0x5A5A = 1");
        check_result(16'h0001, 0, 0, 0, "Equal True");
        
        // Test 35: Equal (False)
        test_num = test_num + 1;
        A = 16'h5A5A;
        B = 16'hA5A5;
        ALU_select = 4'b1101;
        #10;
        display_result("Equal: 0x5A5A == 0xA5A5 = 0");
        check_result(16'h0000, 1, 0, 0, "Equal False");
        
        // Test 36: Equal with zeros
        test_num = test_num + 1;
        A = 16'h0000;
        B = 16'h0000;
        ALU_select = 4'b1101;
        #10;
        display_result("Equal: 0x0000 == 0x0000 = 1");
        check_result(16'h0001, 0, 0, 0, "Equal Zeros");
        
        // Test 37: Equal with max values
        test_num = test_num + 1;
        A = 16'hFFFF;
        B = 16'hFFFF;
        ALU_select = 4'b1101;
        #10;
        display_result("Equal: 0xFFFF == 0xFFFF = 1");
        check_result(16'h0001, 0, 0, 0, "Equal Max");
        
        // Test 38: Greater Than (True)
        test_num = test_num + 1;
        A = 16'h5000;
        B = 16'h3000;
        ALU_select = 4'b1110;
        #10;
        display_result("Greater Than: 0x5000 > 0x3000 = 1");
        check_result(16'h0001, 0, 0, 0, "GT True");
        
        // Test 39: Greater Than (False)
        test_num = test_num + 1;
        A = 16'h3000;
        B = 16'h5000;
        ALU_select = 4'b1110;
        #10;
        display_result("Greater Than: 0x3000 > 0x5000 = 0");
        check_result(16'h0000, 1, 0, 0, "GT False");
        
        // Test 40: Greater Than (Equal = False)
        test_num = test_num + 1;
        A = 16'h1234;
        B = 16'h1234;
        ALU_select = 4'b1110;
        #10;
        display_result("Greater Than: 0x1234 > 0x1234 = 0");
        check_result(16'h0000, 1, 0, 0, "GT Equal");
        
        // Test 41: Less Than (True)
        test_num = test_num + 1;
        A = 16'h1000;
        B = 16'h2000;
        ALU_select = 4'b1111;
        #10;
        display_result("Less Than: 0x1000 < 0x2000 = 1");
        check_result(16'h0001, 0, 0, 0, "LT True");
        
        // Test 42: Less Than (False)
        test_num = test_num + 1;
        A = 16'h2000;
        B = 16'h1000;
        ALU_select = 4'b1111;
        #10;
        display_result("Less Than: 0x2000 < 0x1000 = 0");
        check_result(16'h0000, 1, 0, 0, "LT False");
        
        // Test 43: Less Than (Equal = False)
        test_num = test_num + 1;
        A = 16'hABCD;
        B = 16'hABCD;
        ALU_select = 4'b1111;
        #10;
        display_result("Less Than: 0xABCD < 0xABCD = 0");
        check_result(16'h0000, 1, 0, 0, "LT Equal");
        
        // ===== Edge Cases =====
        $display("=== Testing Edge Cases ===\n");
        
        // Test 44: All ones AND
        test_num = test_num + 1;
        A = 16'hFFFF;
        B = 16'hFFFF;
        ALU_select = 4'b0100;
        #10;
        display_result("All Ones AND: 0xFFFF & 0xFFFF = 0xFFFF");
        check_result(16'hFFFF, 0, 1, 0, "All Ones");
        
        // Test 45: Maximum values addition
        test_num = test_num + 1;
        A = 16'hFFFF;
        B = 16'hFFFF;
        ALU_select = 4'b0000;
        #10;
        display_result("Max Add: 0xFFFF + 0xFFFF = 0xFFFE");
        check_result(16'hFFFE, 0, 1, 1, "Max Add");
        
        // Test 46: Zero minus one (underflow)
        test_num = test_num + 1;
        A = 16'h0000;
        B = 16'h0000;
        ALU_select = 4'b0011;
        #10;
        display_result("Decrement Zero: 0x0000 - 1 = 0xFFFF");
        check_result(16'hFFFF, 0, 1, 0, "Dec Zero");
        
        // Test 47: XOR for bit flip
        test_num = test_num + 1;
        A = 16'hF0F0;
        B = 16'hFFFF;
        ALU_select = 4'b0110;
        #10;
        display_result("XOR Bit Flip: 0xF0F0 ^ 0xFFFF = 0x0F0F");
        check_result(16'h0F0F, 0, 0, 0, "XOR Flip");
        
        // Test 48: Large value comparison
        test_num = test_num + 1;
        A = 16'hFFFE;
        B = 16'hFFFF;
        ALU_select = 4'b1111;
        #10;
        display_result("Less Than: 0xFFFE < 0xFFFF = 1");
        check_result(16'h0001, 0, 0, 0, "LT Large");
        
        // Summary
        $display("\n=== Test Summary ===");
        $display("Total Tests: %0d", test_num);
        $display("Errors: %0d", errors);
        if (errors == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");
        
        $finish;
    end
    
endmodule