`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2023 02:18:45 PM
// Design Name: 
// Module Name: test_rng_module
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
`define ONE_CLOCK_CYCLE 10
module test_rng_module;

    // Testbench Signals
    reg tb_clk;
    reg tb_reset;
    reg tb_uart_rx;
    wire tb_uart_tx;
    wire [31:0] tb_random_number;

    // Instantiate the rng_module
    rng_module rng_inst (
        .clk(tb_clk),
        .reset(tb_reset),
        .uart_rx(tb_uart_rx),
        .uart_tx(tb_uart_tx),
        .random_number(tb_random_number)
    );

    // Clock Generation
    initial begin
        tb_clk = 0;
        forever #5 tb_clk = ~tb_clk; // 100 MHz clock
    end

    // Test Stimuli
    initial begin
        // Initialize testbench signals
        tb_reset = 1;
        tb_uart_rx = 0;

        // Reset the module
        #15;
        tb_reset = 0;
        #1000;
        
        // Simulate UART commands (this is a placeholder; actual implementation will depend on your UART protocol)
        #100;
        tb_uart_rx = 1; // Example of setting UART_RX to trigger a command
        #`ONE_CLOCK_CYCLE;        
        tb_uart_rx = 0;
        
        #`ONE_CLOCK_CYCLE;
        #`ONE_CLOCK_CYCLE;
        #`ONE_CLOCK_CYCLE;
        #`ONE_CLOCK_CYCLE;
        #`ONE_CLOCK_CYCLE;
        
        tb_uart_rx = 1; // Example of setting UART_RX to trigger a command
        #`ONE_CLOCK_CYCLE;
        tb_uart_rx = 0;

        // Continue simulation for a certain period
        #500;

        // End the simulation
        $finish;
    end


endmodule
