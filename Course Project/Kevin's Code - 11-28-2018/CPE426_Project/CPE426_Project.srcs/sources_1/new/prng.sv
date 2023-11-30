`timescale 1ns / 1ps
// =============================================================================
// Title: Pseudo-Random Number Generator (PRNG) Module
// Description: 
//   This module implements a 32-bit Linear Feedback Shift Register (LFSR) based
//   PRNG. It is designed for use in FPGA applications and generates a sequence
//   of pseudo-random numbers. The module uses XOR taps for feedback to achieve
//   a maximal-length LFSR cycle.
//
// Inputs:
//   clk - Clock input. The PRNG updates its state with each rising edge of this
//         clock signal.
//   reset - Synchronous reset input. When asserted, the LFSR state is 
//           reinitialized with the value present on the seed input.
//   seed - Seed input for the LFSR. This 32-bit value initializes the state of
//          the LFSR upon reset, thus influencing the sequence of pseudo-random
//          numbers generated.
//
// Outputs:
//   random_number - The output pseudo-random number. This 32-bit value is the
//                   current state of the LFSR and changes with each clock cycle,
//                   producing a sequence of pseudo-random numbers.
//
// Author: Qingyu Han
// Date:   11-28-2023
// =============================================================================

module prng(
    input wire clk,              // Clock input
    input wire reset,            // Reset input to reinitialize the LFSR
    input wire [31:0] seed,      // Seed input for the LFSR
    output logic [31:0] random_number // Output pseudo-random number
);

    // Linear Feedback Shift Register (LFSR)
    logic [31:0] lfsr; 

    // Define XOR taps for the LFSR. These taps are chosen to ensure that the
    // LFSR goes through the maximal length sequence (2^32-1 states).
    wire feedback = lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0];

    // LFSR operation logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= seed;  // Initialize the LFSR with the provided seed
        end else begin
            // Shift the LFSR and insert the feedback bit at the LSB position
            lfsr <= {lfsr[30:0], feedback};
        end
    end

    // Update the output pseudo-random number at every positive clock edge
    always @(posedge clk) begin
        random_number <= lfsr;
    end
endmodule

