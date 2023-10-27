`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 01:23:54 PM
// Design Name: 
// Module Name: slice_type1
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


module slice_type2(
    input logic [1:0] in_signal,  // Input signal for the slice
    input logic sel,
    input logic bx,
    output logic [1:0] out_signal  // Output signal from slice
    );
    
    // Input for the bx MUX
    (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *) // Xilinx attributes to avoid optimization
    logic [1:0] bx_input;    

    (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *) // Xilinx attributes to avoid optimization
    LUT_NOT LUT_G(
        .in_signal({in_signal[0], in_signal[1]}),  // Connect both bits to the same signal
        .selector(sel),  // Select signal for LUT
        .out_signal(bx_input[0])
    );
    
    (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *) // Xilinx attributes to avoid optimization
    LUT_NOT LUT_F(
        .in_signal({in_signal[0], in_signal[1]}),  // Connect both bits to the same signal
        .selector(sel),  // Select signal for LUT
        .out_signal(bx_input[1])
    );
    
    // bx MUX
    assign out_signal[0] = (bx) ? bx_input[0] : bx_input[1];     
   
    // Latched output
    (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *) // Xilinx attributes to avoid optimization
    logic latched_output;    
    // Latch for out_signal[1]
    always_latch begin
        latched_output = out_signal[0];
    end
    
    assign out_signal[1] = latched_output;
    
endmodule
