`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
`define CLOCK_COUNTER_WIDTH 64          //Width of the clock
`define TEST_SEED           32'h85ad    //Test Seed
`define TIME_THRESHOLD      1000000     // Time threshold for reseeding

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
    logic [`CLOCK_COUNTER_WIDTH-1:0] last_time_stamp;
    logic [`CLOCK_COUNTER_WIDTH-1:0] time_diff;
    logic reseed_rng;
    wire [31:0] rng_output;

    // Instantiate the clock_counter module
    clock_counter #(
        .COUNTER_WIDTH(`CLOCK_COUNTER_WIDTH) // Set the counter width (e.g., 32 bits)
    ) counter_instance (
        .clk(clk),            // Connect the clock input
        .reset(reset),        // Connect the reset input
        .count(time_stamp) // Connect the output to counter_output
    );
    
    // Instantiate SHA module (assuming available from Lab 1)
//    sha_algorithm sha(
//        .clk(clk),
//        .reset(reset),
//        .input_data(time_stamp),
//        .output_data(sha_output)
//    );
   // DUMMY HASH FUNCTION
    simple_hash #(
        .N(`CLOCK_COUNTER_WIDTH)
    ) hash_module (
        .clk(clk),
        .reset(reset),
        .input_data(time_stamp),
        .hash_value(hash_output)
    );
    
    // Instantiate the actual RNG block (pseudo-random number generator)
    prng prng_block(
        .clk(clk),
        .reset(uart_rx),
        .seed(hash_output),
        .random_number(rng_output)
    );

    // Edge detection for uart_rx and time comparison
    reg uart_rx_prev;
    always @(posedge clk) begin
        if (reset) begin
            uart_rx_prev <= 0;
            last_time_stamp <= 0;
            reseed_rng <= 0;
        end else begin
            uart_rx_prev <= uart_rx;
            if (!uart_rx_prev && uart_rx) begin // Detecting rising edge of uart_rx
                time_diff <= time_stamp - last_time_stamp;
                last_time_stamp <= time_stamp;
                reseed_rng <= (time_diff > `TIME_THRESHOLD);
            end else begin
                reseed_rng <= 0;
            end
        end
    end

    assign random_number = rng_output;

endmodule
