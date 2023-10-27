`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2023 01:05:07 PM
// Design Name: 
// Module Name: main_tb
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


module main_tb;
    logic clk;
    logic [15:0] led;
    logic button;

    // Instantiate the main module
    main uut (
        .CLK(clk),
        .BTNC(button),
        .LEDS(led)
    );

    // Clock generation
    always begin
        #1 clk = ~clk;
    end
    
    // Clock generation
    always begin
        #1000 button = ~button;
    end

    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        button = 0;
        led = 16'h00;

        // Wait and observe LED behavior
        #1000000;


        // Finish simulation
        $finish;
    end
endmodule


