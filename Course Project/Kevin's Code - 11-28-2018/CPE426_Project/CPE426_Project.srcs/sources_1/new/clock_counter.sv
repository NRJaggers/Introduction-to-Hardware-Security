`timescale 1ns / 1ps
// =============================================================================
// Title: Clock Counter Module
// Description:
//   This module counts the number of clock cycles. It is a simple up-counter
//   that increments with each clock cycle. The size of the counter is 
//   parameterized, allowing for different bit widths (e.g., 32-bit, 64-bit).
//   This module is useful in FPGA designs for timing and control purposes.
//
// Inputs:
//   clk - Clock input. The counter increments on the rising edge of this clock.
//   reset - Synchronous reset input. When high, the counter resets to 0 on the
//           next rising edge of the clock.
//
// Output:
//   count - The current count value of the module. This value represents the 
//           number of clock cycles since the last reset. The width of this 
//           output is defined by the COUNTER_WIDTH parameter.
//
// Parameters:
//   COUNTER_WIDTH - Defines the bit width of the count output. This parameter
//                   can be set to customize the range of the counter.
//
// Author:  Qingyu Han
// Date:    11-28-2023
// Version: 1.0
// =============================================================================

module clock_counter #(
    parameter COUNTER_WIDTH = 32  // Default width is 32 bits
)(
    input wire clk,            // Clock input
    input wire reset,          // Reset input to reset the counter
    output logic [COUNTER_WIDTH-1:0] count // Counter output
);
    // Counter logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;  // Reset the counter to 0
        end else begin
            count <= count + 1'b1;  // Increment the counter
        end
    end
endmodule

