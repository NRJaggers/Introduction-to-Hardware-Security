`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2023 09:39:28 PM
// Design Name: 
// Module Name: uart_test_sim
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


module uart_test_sim();
    
    //mimic input and outputs
    logic clk;
    logic reset;
    logic rx;
    logic btn;
    logic tx;    
    logic [3:0] an;
    logic [0:6] seg;
    logic [7:0] LED;
    
    uart_test DUT (
    .clk_100MHz(clk),
    .reset(reset),
    .rx(rx),
    .btn(btn),
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
    logic [7:0] a = 8'h63;
    
    //test stimulus
    initial begin
        btn = 1'b0;
        reset = 1'b1;
        rx = 1'b1;
        #100
        
        reset = 1'b0;      
        #10000;
        
        
        //start bit
        rx = 1'b0;
        #651
        rx = 1'b1;
        #20800
        
        for (int i = 0; i<8; i++)begin
            rx = a[i];
            #20800;
        end
        
        //stop bit
        rx = 1'b1;
        #20800;
        
        //button press
        btn = 1'b1;
        #500000;
        btn = 1'b0;
        //rx = 1'b0;
        
    end

endmodule
