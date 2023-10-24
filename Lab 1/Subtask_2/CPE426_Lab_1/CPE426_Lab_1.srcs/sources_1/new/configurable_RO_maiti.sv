`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2023 05:46:47 PM
// Design Name: 
// Module Name: configurable_RO_maiti
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


module configurable_RO_maiti(
    input wire [2:0] c, 
    input wire enable,
    output wire ro_output   
    );
    
    wire [3:0] temp_sig;
    
    // Using the new LUT_NOT module
    LUT_NOT slice_0(
        .in_signal({temp_sig[3], temp_sig[3]}),  // Connect both bits to the same signal
        .selector(c[0]),  // Select signal for LUT
        .out_signal(temp_sig[0])
    );
    
    LUT_NOT slice_1(
        .in_signal({temp_sig[0], temp_sig[0]}),  // Connect both bits to the same signal
        .selector(c[1]),  // Select signal for LUT
        .out_signal(temp_sig[1])
    );
    
    LUT_NOT slice_2(
        .in_signal({temp_sig[1], temp_sig[1]}),  // Connect both bits to the same signal
        .selector(c[2]),  // Select signal for LUT
        .out_signal(temp_sig[2])
    );
    
    // Assuming you still have the AND gate slice
    LUT_AND slice_3(
        .input_signal(temp_sig[2]),
        .enable(enable),
        .output_signal(temp_sig[3])
    );
    
    assign ro_output = temp_sig[3];
    
    
endmodule
