`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2023 03:22:44 PM
// Design Name: 
// Module Name: use_sseg
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


module use_sseg(
    input CLK,
    input [15:0] SWITCHES,
    output [7:0] CATHODES,
    output [3:0] ANODES

    );

       SevSegDisp SSG_DISP (.DATA_IN(SWITCHES), .CLK(CLK), .MODE(1'b0),
                       .CATHODES(CATHODES), .ANODES(ANODES));
endmodule
