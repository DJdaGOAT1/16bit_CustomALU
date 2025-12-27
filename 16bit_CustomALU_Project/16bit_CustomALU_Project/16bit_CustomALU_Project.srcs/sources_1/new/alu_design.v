`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2025 04:47:21 PM
// Design Name: 
// Module Name: alu_design
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
module alu_design #(
    parameter alu_size = 16
)(
    input [alu_size-1:0] A,
    input [alu_size-1:0] B,
    input [3:0] ALU_select, // ALU will have 16 operations
    input Enable,
    output reg [alu_size-1:0] ALU_result, 
    output reg zero, negative, carry, overflow
    );
    
    reg [alu_size:0] temp;
    always @(*) begin
        temp = 0;
        ALU_result = 0;
        zero = 0;
        negative = 0;
        carry = 0;
        overflow = 0;
        if(Enable) begin
            case(ALU_select)
                4'b0000: begin
                    temp = A + B; // Addition
                    ALU_result = temp[alu_size-1:0];
                    carry = temp[alu_size];
                    overflow = (A[alu_size-1] == B[alu_size-1]) && (ALU_result[alu_size-1] != A[alu_size-1]);
                    end
                4'b0001: begin // Subtraction
                    temp = A - B;
                    ALU_result = temp[alu_size-1:0];
                    carry = (A>=B);
                    overflow = ((A[alu_size-1] != B[alu_size-1]) && (A[alu_size-1] != ALU_result[alu_size-1]));
                    end
                4'b0010: begin // Increment
                    temp = A + 1;
                    ALU_result = temp[alu_size-1:0];
                    carry = temp[alu_size];
                end 
                4'b0011: begin // Decrement
                    temp = A - 1;
                    ALU_result = temp[alu_size-1:0];
                    carry = A>=1;
                end
                
                4'b0100: ALU_result = A & B; // AND
                4'b0101: ALU_result = A | B; // OR
                4'b0110: ALU_result = A ^ B; // XOR
                4'b0111: ALU_result = ~A; // NOT  
                
                4'b1000: begin // Shift left logical
                    ALU_result = A << 1;
                    carry = A[alu_size-1];
                end 
                4'b1001: begin // Shift right logical
                    ALU_result = A >> 1;
                    carry = A[0];
                end
                4'b1010: begin // Shift right arithmetic
                    ALU_result = {A[alu_size-1], A[alu_size-1:1]};
                    carry = A[0];
                end
                4'b1011: begin // Rotate left
                    ALU_result = {A[alu_size-2:0], A[alu_size-1]};
                    carry = A[alu_size-1];
                end
                4'b1100: begin // Rotate right
                    ALU_result = {A[0], A[alu_size-1:1]};
                    carry = A[0];
                end
                4'b1101: ALU_result = (A == B) ? 1 : 0; // Equal to
                4'b1110: ALU_result = (A > B) ? 1 : 0; // Greater than
                4'b1111: ALU_result = (A < B) ? 1 : 0; // Less than
                default: ALU_result = 0;
        endcase
        end
        zero = (ALU_result == 0);
        negative = ALU_result[alu_size-1];
    end
endmodule