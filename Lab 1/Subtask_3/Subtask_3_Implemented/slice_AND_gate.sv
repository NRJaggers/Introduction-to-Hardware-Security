`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2023 05:43:00 PM
// Design Name: 
// Module Name: slice_AND_gate
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
//      Module: LUT_AND
//      Author: Qingyu Han
// Modified on: Oct 19,2023
// Description: This module performs an AND operation between the input and 
//              the enable signal.
// -----------------------------------------------------------------------------

module LUT_AND(
    input wire input_signal,  // Input signal
    input wire enable, // Enable signal
    output wire output_signal // Output signal
    );
    
    assign output_signal = input_signal & enable;    
endmodule
