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
// Description: This module encapsulates the logic for a configurable Ring 
//              Oscillator-based Physical Unclonable Function (RO PUF). It 
//              takes a 10-bit challenge input to configure the behavior of 
//              the ROs and outputs a 32-bit count based on the RO frequency.
//
// Ports:
//   - challenge: 10-bit input for configuring the ROs
//   - clk:       Clock signal
//   - en:        Enable signal for the counters
//   - ro_count_out: 32-bit output count based on RO frequency
//   - complete: Output signal indicating if the STD counter is full
// -----------------------------------------------------------------------------

`define MAX_STD_COUNT 50000
`define TRUE    1'b1
`define FALSE   1'b0

module configurable_RO_PUF(
    input [9:0] challenge,
    input clk, 
    input en,
    output logic [31:0] ro_count_out,
    output logic completed
);

    // Internal signals
    wire [8:0] RO_output;  // Wires used for RO outputs
    logic MUX_out, prev_MUX_out;  // To store the previous state of MUX_out   
    wire counter_enable, std_counter_full; 
    logic [31:0] RO_Count = 0;        
    logic [31:0] STD_Count = 0;
    
    // Generate instances of configurable_RO_Xin
    generate
        genvar i;
        for(i = 0; i < 9; i = i + 1) begin : ro_gen
            configurable_RO_Xin configurable_RO_inst (
                .sel({1'b0, challenge[5:3]}), //sdasda
                .bx({1'b0, challenge[2:0]}), 
                .enable(en),
                .ro_output(RO_output[i])
            );
        end
    endgenerate
    
    // MUX logic for selecting the appropriate RO output
    always_comb begin
        if (challenge[9:6] <= 4'b1000) begin
            MUX_out = RO_output[challenge[9:6]];
        end else begin
            MUX_out = 0;
        end
    end
    
    // RO Counter logic
    always_ff @(posedge clk) begin
        prev_MUX_out <= MUX_out;  // Capture the previous state of MUX_out
        if (counter_enable) begin
            if (MUX_out && !prev_MUX_out) begin  // Detect rising edge
                RO_Count <= RO_Count + 1;
            end
        end
    end 

    // Counter enable logic
    assign counter_enable = en & ~std_counter_full;
    assign std_counter_full = (STD_Count == `MAX_STD_COUNT) ? `TRUE : `FALSE;        
    assign completed = std_counter_full; //output signal.
    
    // STD Counter logic
    always_ff @(posedge clk) begin
        if(counter_enable) begin
            STD_Count <= STD_Count + 1;
        end
        
//        if(~en) begin
        if(~en) begin
            if(STD_Count !== 0) STD_Count <= 0;
            if(RO_Count !== 0) RO_Count <= 0;
        end
    end

    // Output assignment
    assign ro_count_out = RO_Count;

endmodule

