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
    
    // Define the LUT for NOT operation
    (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *) // Xilinx attributes to avoid optimization
    logic [1:0] LUT [1:0];  // 2-to-1 LUT
    
   initial begin
        LUT[0] = 1'b1;  // NOT(0) = 1
        LUT[1] = 1'b0;  // NOT(1) = 0
    end
    
    // LUT (Look-Up Table) for NOT
    (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *)
    assign out_signal = (selector) ? LUT[in_signal[0]] : LUT[in_signal[1]];      
endmodule
