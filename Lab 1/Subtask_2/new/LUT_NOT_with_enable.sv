`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2023 05:33:16 PM
// Design Name: 
// Module Name: slice_2I_1O
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
//      Module: LUT_NOT_with_enable
//      Author: Qingyu Han
// Modified on: Oct 19,2023
// Description: This module implements a simple Look-Up Table (LUT) with
//              two inputs and one output. The LUT performs bitwise negation
//              on the input and selects between two outputs based on the 'sel'
//              signal.
// -----------------------------------------------------------------------------

module LUT_NOT_with_enable(
    input wire [1:0] in_signal,  // Input signal for LUT
    input wire enable,      // Enable signal for LUT
    input wire selector,    // Select signal for LUT
    output wire out_signal  // Output signal from LUT
    );
    
    wire lut_result;  // Intermediate wire to hold the LUT result
    
    // LUT (Look-Up Table) for NOT
    assign lut_result = (selector) ? ~in_signal[0] : ~in_signal[1]; 
    
    // Output MUX controlled by enable (Output is 0 when not enabled)
    assign out_signal = (enable) ? lut_result : 1'b0;    
        
endmodule
