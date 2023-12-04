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


module uart_stream_sim1();

    //mimic input and outputs
    logic clk;
    logic reset;
    logic rx;
    logic tx;    
    logic [7:0] LED;
    
    uart_stream DUT (
        .clock(clk),
        .reset(reset),
        .LED(LED),
        .i_uart_rx(rx),
        .o_uart_tx(tx)
        );
    
    //generate clock
    initial begin
        clk = 1'b0;
        forever #1 clk = ~clk;
    end
    
    //reset test here
    
    //stimulus variables 
    logic [7:0] a = 8'h61;
    logic [31:0] rng = 32'h2E524E47; //".RNG"
    
    int start = 0;
    int stop = 0;
        
    
//test stimulus
    initial begin
        reset = 1'b1;
        rx = 1'b1;
        #100
        
        reset = 1'b0;      
        #10000;
        
        
//        //start bit
//        rx = 1'b0;
//        #651
//        rx = 1'b1;
//        #20800
        
//        for (int i = 0; i<8; i++)begin
//            rx = a[i];
//            #20800;
//        end
        
//        //stop bit
//        rx = 1'b1;
//        #20800;
        

        for (int j = 0; j<4; j++) begin
        
            start = j*8;
            stop = (j*8)+8;
            
            //start bit
            rx = 1'b0;
            #651
            rx = 1'b1;
            #20800
            
            for (int i = start; i< stop; i++)begin
                rx = rng[i];
                #20800;
            end
            
            //stop bit
            rx = 1'b1;
            #20800;
        
        end
        
    end
   
endmodule
