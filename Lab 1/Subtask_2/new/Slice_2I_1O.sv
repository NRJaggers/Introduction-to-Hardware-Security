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
//      Module: LUT_NOT
//      Author: Qingyu Han
// Modified on: Oct 19,2023
// Description: This module implements a simple Look-Up Table (LUT) with
//              two inputs and one output. The LUT performs bitwise negation
//              on the input and selects between two outputs based on the 'sel'
//              signal.
// -----------------------------------------------------------------------------

module LUT_NOT(
    input wire [1:0] in_signal,  // Input signal for LUT
    input wire selector,    // Select signal for LUT
    output wire out_signal  // Output signal from LUT
    );
    
    // LUT (Look-Up Table) for NOT
    assign out_signal = (selector) ? ~in_signal[0] : ~in_signal[1];      
endmodule
