`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2023 10:01:09 AM
// Design Name: 
// Module Name: configurable_RO_PUF
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


// -----------------------------------------------------------------------------
// Module: configurable_RO_PUF
// Description: 
//   This module encapsulates the logic for a configurable Ring Oscillator-based 
//   Physical Unclonable Function (RO PUF). It takes a 10-bit challenge input 
//   to configure the behavior of the ROs and outputs a 32-bit count based on 
//   the RO frequency.
//
// Ports:
//   - challenge: 10-bit input for configuring the ROs
//   - clk: Clock signal
//   - en: Enable signal for the counters
//   - ro_count_out: 32-bit output count based on RO frequency
//   - completed: Output signal indicating if the STD counter is full
// -----------------------------------------------------------------------------

`define MAX_STD_COUNT 25_000_000
`define TRUE  1'b1
`define FALSE 1'b0

module configurable_RO_PUF(
    input [9:0] challenge,
    input clk, 
    input en,
    output logic [31:0] ro_count_out,
    output logic completed
);

    // Local variables
    logic [8:0] RO_output;      // Output from each RO instance
    logic MUX_out = 1'b0;       // Output from the MUX
    logic prev_MUX_out = 1'b0;  // Previous state of MUX_out
    logic std_counter_full;     // Indicate if the counter is full
    logic [31:0] RO_Count = 0;  // Counter for RO frequency
    logic [31:0] STD_Count = 0; // Standard counter
    logic [8:0] ro_enable;      // Enable signals for each RO instance

    // Generate instances of configurable_RO_Xin
    generate
        genvar i;
        for(i = 0; i < 9; i = i + 1) begin : ro_gen
            // Generate a unique enable signal for each instance
            assign ro_enable[i] = (i == challenge[9:6]) ? en : `FALSE;
            
            configurable_RO_Xin configurable_RO_inst (
                .sel({1'b0, challenge[5:3]}),
                .bx({1'b0, challenge[2:0]}),
                .enable(ro_enable[i]),
                .ro_output(RO_output[i])
            );
        end
    endgenerate

    // MUX logic to select the appropriate RO output
    always_comb begin
        if (challenge[9:6] <= 4'b1000) begin
            MUX_out = RO_output[challenge[9:6]];
        end else begin
            MUX_out = 0;
        end
    end

    // Counter full logic
    assign std_counter_full = (STD_Count >= `MAX_STD_COUNT) ? `TRUE : `FALSE;
    assign completed = std_counter_full; // Output signal indicating completion

    // STD Counter logic
    always_ff @(posedge clk) begin
        if(en & ~std_counter_full) begin
            STD_Count <= STD_Count + 1;
            if (MUX_out && !prev_MUX_out) begin  // Detect rising edge
                RO_Count <= RO_Count + 1;
            end
            prev_MUX_out <= MUX_out;  // Store the previous state of MUX_out
        end else if(~en) begin
            if(STD_Count != 0) STD_Count <= 0;
            if(RO_Count != 0) RO_Count <= 0;
        end
    end

    // Output assignment
    assign ro_count_out = RO_Count;

endmodule


