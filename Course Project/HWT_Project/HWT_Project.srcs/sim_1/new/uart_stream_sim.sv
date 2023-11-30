`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2023 03:51:59 PM
// Design Name: 
// Module Name: uart_stream_sim
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


module uart_stream_sim();

    //mimic input and outputs
    logic clk;
    logic reset;
    logic rx;
    logic tx;    
    logic [3:0] an;
    logic [0:6] seg;
    logic [7:0] LED;
    
    uart_stream DUT (
        .clk_100MHz(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx),
        .an(an),
        .seg(seg),
        .LED(LED)
        );
    
    //generate clock
    initial begin
        clk = 1'b0;
        forever #1 clk = ~clk;
    end
    
    //reset test here
    
    //stimulus variables 
    logic [7:0] a = 8'h61;
    
    //test stimulus
    initial begin
        rx = 1'b0;
        #10000;
             
        for (int i = 0; i<8; i++)begin
            rx = a[i];
            #700;
        end
    end
    
    
endmodule
