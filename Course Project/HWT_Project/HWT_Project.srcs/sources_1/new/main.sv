`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2023 10:47:32 PM
// Design Name: 
// Module Name: main
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


module main(
    input CLK,
    input BTNC,
    input BTNU,
    input [15:0] SWITCHES,
    output [3:0] ANODES,
    output [7:0] CATHODES
    );
    
    //signals and buses
    logic [31:0] value;
    logic [31:0] hold_value;
    logic [15:0] print_value;
    
    RandGen RNG(
        .CLK(CLK),
        .RST(BTNU),
        .RANDOM(value)
    );
     
    always_ff@(posedge CLK) begin
        if(BTNC == 1'b1)
            hold_value <= value;
    end
    
    always_comb begin
        if (SWITCHES[0] == 1'b1)
            print_value = hold_value[15:0];
        else 
            print_value = hold_value[31:16];     
    end
    
    SevSegDisp sseg(
        .CLK(CLK),            // 100 MHz
        .MODE(1'b0),           // 0 - Hex, 1 - Decimal
        .DATA_IN(print_value),
        .CATHODES(CATHODES),
        .ANODES(ANODES)
    );
    
endmodule
