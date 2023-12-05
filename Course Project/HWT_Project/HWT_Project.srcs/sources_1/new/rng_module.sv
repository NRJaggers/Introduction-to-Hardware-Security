`timescale 1ns / 1ps
`define CLOCK_COUNTER_WIDTH 64          //Width of the clock
`define TEST_SEED           32'h85ad    //Test Seed
`define TIME_THRESHOLD      32'hFFFF     // Time threshold for reseeding
`define TRUE                1'b1
`define FALSE               1'b0

module rng_module(
    input wire clk,
    input wire reset,
    input wire uart_rx, // UART Receive
    output wire uart_tx, // UART Transmit
    output wire [31:0] random_number
);

    // Internal signals
    logic [31:0] sha_output;
    logic [127:0] hash_output; // Output from the hash function
    logic [`CLOCK_COUNTER_WIDTH-1:0] time_stamp;
    logic [`CLOCK_COUNTER_WIDTH-1:0] initial_time_stamp;
    logic [`CLOCK_COUNTER_WIDTH-1:0] time_diff;
    logic time_match, reseed_rng, time_match_flag;
    wire [31:0] rng_output;
    wire sha_ready;

    // Instantiate the clock_counter module
    clock_counter #(
        .COUNTER_WIDTH(`CLOCK_COUNTER_WIDTH) // Set the counter width (e.g., 32 bits)
    ) counter_instance (
        .clk(clk),            // Connect the clock input
        .reset(reset),        // Connect the reset input
        .count(time_stamp) // Connect the output to counter_output
    );
    
    // !!!  THIS IS NOT READY YET  !!! 
    // Still need control logic to address the ready timing!!!
    // Instantiate SHA128_simple 
//    sha128_simple sha_module (
//        .CLK(clk),
//        .DATA_IN(time_stamp[15:0]), // Assuming lower 16 bits of time_stamp are used
//        .RESET(reset),
//        .START(reseed_rng), // Trigger on reseed signal
//        .READY(sha_ready),
//        .DATA_OUT(hash_output)
//    );

   // DUMMY HASH FUNCTION in place of SHA. Used for faster simulation.
    simple_hash #(
        .N(`CLOCK_COUNTER_WIDTH)
    ) hash_module (
        .clk(clk),
        .reset(reset),
        .input_data(`TIME_THRESHOLD == time_diff ? time_match : time_stamp),
        .hash_value(hash_output)
    );
    
    // Instantiate the actual RNG block (pseudo-random number generator)
    prng prng_block(
        .clk(clk),
        .reset(uart_rx),
        .seed(time_match ? `TEST_SEED : hash_output[31:0]), // Ternary operator for seed selection
        .random_number(rng_output)
    );

    // Edge detection for uart_rx and time comparison
    logic uart_rx_prev;
    always @(posedge clk) begin
        time_match <= 0;
        if (time_match_flag == `TRUE) begin
             time_match <= (time_diff == 6);
             time_match_flag = `FALSE;
        end
        if (reset) begin
            uart_rx_prev <= `FALSE;
            initial_time_stamp <= `FALSE;
            reseed_rng <= `FALSE;
            time_diff <= `TIME_THRESHOLD + `TRUE + `FALSE;
        end else begin
            if (!uart_rx_prev && uart_rx) begin
                time_diff <= (time_stamp - initial_time_stamp);
                if (time_diff > `TIME_THRESHOLD) begin
                    initial_time_stamp <= time_stamp;
                    reseed_rng <= `TRUE;
                end else begin
                   time_match_flag = `TRUE;
                   reseed_rng <= `FALSE;
                end           
            end else begin
                reseed_rng <= `FALSE;
            end
            uart_rx_prev <= uart_rx;
        end
    end

    assign random_number = rng_output;

endmodule