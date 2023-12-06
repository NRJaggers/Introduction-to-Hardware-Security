`timescale 1ns / 1ps
// =============================================================================
// Title: Simple Hash Function Module
// Description:
//   This module implements a basic, non-cryptographic hash function. It takes
//   an N-bit input and produces a 128-bit hash value. The hashing is done using
//   simple operations such as XOR, bit shifts, and addition. This implementation
//   is meant for demonstration purposes and is not suitable for cryptographic
//   applications due to its basic nature.
//
// Inputs:
//   clk - Clock input. The hashing process is triggered on the rising edge of
//         this clock signal.
//   reset - Synchronous reset input. When high, the hash value is reset to zero.
//   input_data - An N-bit input value that is to be hashed.
//
// Output:
//   hash_value - A 128-bit hash output generated from the input data.
//
// Parameters:
//   N - Bit width of the input data. This can be set to any desired size.
//
// Author: Qingyu Han
// Date:   11-28-2023
// =============================================================================
module simple_hash #(
    parameter N = 32  // Input bit width, customizable
)(
    input wire clk,                   // Clock input
    input wire reset,                 // Reset input
    input wire [N-1:0] input_data,    // N-bit input data to be hashed
    output logic [127:0] hash_value     // 128-bit output hash value
);

    // Hash computation logic on the positive edge of the clock
    always @(posedge clk) begin
        if (reset) begin
            // Reset the hash value to zero
            hash_value <= 128'd0;
        end else begin
            // Simple hash computation using XOR, bit shifts, and addition
            // Each segment of the hash value is updated independently
            hash_value[127:96] <= hash_value[127:96] ^ input_data;      // XOR operation
            hash_value[95:64] <= (hash_value[95:64] << 5) + input_data; // Left shift and addition
            hash_value[63:32] <= (hash_value[63:32] >> 3) ^ input_data; // Right shift and XOR
            hash_value[31:0] <= hash_value[31:0] + (input_data << 7);   // Addition and left shift
        end
    end
endmodule

