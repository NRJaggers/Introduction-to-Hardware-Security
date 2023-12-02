`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2023 11:25:44 AM
// Design Name: 
// Module Name: test_command_processor
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


`timescale 1ns / 1ps

module command_processor_tb;

    reg clk;
    reg reset;
    reg [7:0] rx_data;
    reg rx_data_ready;
    wire process_rng;
    wire [31:0] custom_seed;
    wire set_custom_seed;
    wire get_seed;
    wire [7:0] tx_data;
    wire tx_data_valid;

    // Instantiate the command_processor module
    command_processor uut (
        .clk(clk),
        .reset(reset),
        .rx_data(rx_data),
        .rx_data_ready(rx_data_ready),
        .process_rng(process_rng),
        .custom_seed(custom_seed),
        .set_custom_seed(set_custom_seed),
        .get_seed(get_seed),
        .tx_data(tx_data),
        .tx_data_valid(tx_data_valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        rx_data = 8'd0;
        rx_data_ready = 0;

        // Reset the module
        #200;
        reset = 0;
        #2000;
        
        // Send '.RNG' command
        #20; rx_data = 8'h2E; rx_data_ready = 1; // '.' NOT SURE EXACTLY WHY THIS IS NEEDED! 
        #20; rx_data = 8'h2E; rx_data_ready = 1; // '.'
        #20; rx_data = 8'h52; rx_data_ready = 1; // 'R'
        #20; rx_data = 8'h4E; rx_data_ready = 1; // 'N'
        #20; rx_data = 8'h47; rx_data_ready = 1; // 'G'
        #40; rx_data_ready = 0;

        // Wait and observe the outputs
        #1000;

        // Add more test cases as needed for '.TEST' and '.SEED' commands

        // Finish the simulation
        #100;
        $finish;
    end

    // Monitor and display output


endmodule
