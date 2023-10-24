`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 01:21:36 PM
// Design Name: 
// Module Name: configurable_RO_Xin
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


module configurable_RO_Xin(
    input wire [3:0] sel,
    input wire [3:0] bx, 
    input wire enable,
    output wire ro_output   
    );  

    //2D array for temporary signal!
    (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *)
    wire [1:0] temp_sig[0:3];
    
    // Using the new LUT_NOT module
    (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *) // Xilinx attributes to avoid optimization
    slice_type1 slice_X0Y1(
        .in_signal({temp_sig[3][0], temp_sig[3][1]}),  // Connect both bits to the same signal
        .enable(enable),
        .sel(sel[0]),  // Select signal for LUT
        .bx(bx[0]),
        .out_signal({temp_sig[0][1], temp_sig[0][0]})
    );
    
    // Using the new LUT_NOT module
    (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *) // Xilinx attributes to avoid optimization
    slice_type2 slice_X0Y0(
        .in_signal({temp_sig[0][0], temp_sig[0][1]}),  // Connect both bits to the same signal
        .sel(sel[1]),  // Select signal for LUT
        .bx(bx[1]),
        .out_signal({temp_sig[1][1], temp_sig[1][0]})
    );    

    (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *) // Xilinx attributes to avoid optimization
    slice_type2 slice_X1Y1(
        .in_signal({temp_sig[1][0], temp_sig[1][1]}),  // Connect both bits to the same signal
        .sel(sel[2]),  // Select signal for LUT
        .bx(bx[2]),
        .out_signal({temp_sig[2][1], temp_sig[2][0]})
    );
    
   (* DONT_TOUCH = "TRUE", KEEP = "TRUE" *) // Xilinx attributes to avoid optimization
   slice_type3 slice_X1Y0(
        .in_signal({temp_sig[2][0], temp_sig[2][1]}),  // Connect both bits to the same signal
        .sel(sel[3]),  // Select signal for LUT
        .bx(bx[3]),
        .out_signal({temp_sig[3][1], temp_sig[3][0]})
    );  
    
       assign ro_output = temp_sig[3][0];
    
//module configurable_RO_Xin(
//    input logic [3:0] sel,
//    input logic [3:0] bx, 
//    input logic clk,
//    input logic enable,
//    output logic ro_output   
//    );  
    
//    always_ff @(posedge clk) begin
//        ro_output <= ~ro_output;  // Toggle the output
//    end

endmodule
