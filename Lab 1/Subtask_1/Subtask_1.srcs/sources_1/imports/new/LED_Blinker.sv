`timescale 1ns / 1ps
// =============================================================================
//      Module: LED_Blinker
//      Author: Qingyu Han
// Created on: Oct 17,2023
// Modified on: Oct 19,2023
// Description: This module toggles an LED based on an oscillating signal and
//              a user-defined count limit. The LED toggles when the internal
//              32-bit counter reaches the specified count limit.
// Inputs:
//   - osc_signal: Oscillating signal to increment the counter
//   - count_limit: User-defined limit to toggle the LED
// Output:
//   - led: LED output signal
// =============================================================================
module LED_Blinker(
    input wire osc_signal,  // Oscillating signal input
    input [31:0] count_limit,  // 32-bit count limit input
    output reg led  // LED output
    );
    
    reg [31:0] count_var = 0;  // 32-bit counter variable

    // Increment counter on every rising edge of osc_signal
    // Toggle LED when counter reaches count_limit
    always @(posedge osc_signal) begin
        count_var <= count_var + 1'b1;  // Increment the counter variable
        if (count_var == count_limit) begin  // Check if count limit is reached
            count_var <= 0;  // Reset the counter variable
            led <= ~led;  // Toggle the LED
        end
    end

endmodule

