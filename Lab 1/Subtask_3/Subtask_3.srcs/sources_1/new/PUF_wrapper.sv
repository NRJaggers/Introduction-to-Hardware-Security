`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2023 06:35:08 PM
// Design Name: 
// Module Name: PUF_wrapper
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


module PUF_wrapper(
    input CLK,
    input BTNC,
    input  [5:0]  SWITCHES,
    output [7:0]  LEDS,
    output [7:0]  CATHODES,
    output [3:0]  ANODES
    );
    
    logic recalc; //signal to run puf again
    logic [5:0] c_bits; //challenge bits
    logic [7:0] r_bits; //response bits
    
   SevSegDisp SSG_DISP (.DATA_IN({r_bits,2'b00,cbits}), .CLK(CLK), .MODE(1'b0),.CATHODES(CATHODES), .ANODES(ANODES));
   
   //Will prob need modification later
   PUF puf_instance (.CLK(CLK), .CB(c_bits), .RESTART(recalc), .CR(r_bits));
   
   assign c_bits = SWITCHES;
   assign r_bits = LEDS;
   
   //Reset/Recalc signal logic
   always_comb 
   begin
        if (BTNC)
            begin
                recalc = 1;
            end
//        else if (SWITCHES != SWITCHES) // need to figure this one out
//            begin                      // when switches doesn't equal previous switches
            
//            end
        else
            begin
                recalc = 0;
            end  
   end
   
               
endmodule
