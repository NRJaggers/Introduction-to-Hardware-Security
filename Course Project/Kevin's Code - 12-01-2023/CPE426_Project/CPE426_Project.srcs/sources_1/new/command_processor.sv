`timescale 1ns / 1ps
// =============================================================================
// Title: Command Processor Module
// Description:
//   This module processes commands received from a UART interface, specifically
//   handling commands for a Random Number Generator (RNG). Each command starts
//   with a '.', followed by the command text. The module implements a state
//   machine to detect and process these commands.
//   Supported commands:
//   - '.RNG': Triggers the RNG process.
//   - '.TEST': Sets a custom seed for the RNG.
//   - '.SEED': Requests the current RNG seed.
//   Other inputs are echoed back.
//
// Inputs:
//   clk - Clock input.
//   reset - Synchronous reset input.
//   rx_data - Received data byte from UART.
//   rx_data_ready - Indicates new data byte is ready from UART.
//
// Outputs:
//   process_rng - Signal to trigger RNG process.
//   custom_seed - Custom seed for RNG (valid when set_custom_seed is high).
//   set_custom_seed - Flag to set custom seed for RNG.
//   get_seed - Flag to request current RNG seed.
//   tx_data - Data byte to send via UART.
//   tx_data_valid - Flag indicating tx_data is valid to send.
//
// Author: Qingyu Han
// Date:   12-01-2023
// =============================================================================
`define TEST_SEED           32'h85ad    //Test Seed

module command_processor(
    input wire clk,
    input wire reset,
    input wire [7:0] rx_data,
    input wire rx_data_ready,
    output logic process_rng,
    output logic [31:0] custom_seed,
    output logic set_custom_seed,
    output logic get_seed,
    output logic [7:0] tx_data,
    output logic tx_data_valid
);

    localparam CHAR_DOT = 8'h2E; // ASCII for '.'

    // State machine states
    typedef enum {
        IDLE,
        WAIT_FOR_COMMAND,
        PROCESS_CMD
    } state_t;
    state_t current_state, next_state;

    // Buffer to store incoming command
    logic [7:0] command_buffer[3:0]; // Adjust size based on expected command length
    logic [2:0] char_count; // Counter for received characters
    integer i;

    // State machine for command processing
//    always @(posedge clk or posedge reset) begin
//        if (reset) begin
//            current_state <= IDLE;
//            char_count <= 0;
//            for (i = 0; i < 4; i++) command_buffer[i] <= 8'd0;
//        end else begin
//            current_state <= next_state;
//        end
//    end


    // Command processing logic
    always_ff @(posedge clk) begin
        if (reset) begin
            // Reset logic
            next_state <= IDLE;
            char_count <= 0;
            for (i = 0; i < 4; i++) command_buffer[i] <= 8'd0;
        end
        else begin
            // Default values
            process_rng <= 0;
            set_custom_seed <= 0;
            get_seed <= 0;
            tx_data_valid <= 0;
            tx_data <= 8'h00; // Default UART transmit data
    
            case (current_state)        
                IDLE: begin
                    if (rx_data_ready && rx_data == CHAR_DOT) begin
                        next_state <= WAIT_FOR_COMMAND;
                        char_count <= 0;
                        for (i = 0; i < 4; i++) command_buffer[i] <= 8'd0;
                    end
                end
                
                WAIT_FOR_COMMAND: begin
                    if (rx_data_ready) begin
                        // Store the received character directly at the index specified by char_count
                        if (char_count < 3) begin // Ensure char_count does not exceed buffer size
                            command_buffer[char_count] <= rx_data;
                            char_count <= char_count + 1;
                        end
                
                        // Transition to PROCESS_CMD state after four characters have been received
                        if (char_count >= 3) begin
                            next_state <= PROCESS_CMD;
                            char_count <= 0; // Reset char_count for next command
                        end
                    end
                end
    
                PROCESS_CMD: begin
                        // Check for '.RNG' command
                        if (command_buffer[0] == 8'h52 && // ASCII for 'R'
                            command_buffer[1] == 8'h4E && // ASCII for 'N'
                            command_buffer[2] == 8'h47) begin // ASCII for 'G'
                            process_rng <= 1;
                            tx_data <= 8'h52; // ASCII for 'R', as a placeholder response
                            tx_data_valid <= 1;
                        end
                        // Check for '.TEST' command (simplified, does not parse 'num')
                        else if (command_buffer[0] == 8'h54 && // ASCII for 'T'
                                 command_buffer[1] == 8'h45 && // ASCII for 'E'
                                 command_buffer[2] == 8'h53) begin // ASCII for 'S'
                            set_custom_seed <= 1;
                            custom_seed <= `TEST_SEED; // Using a predefined test seed
                            tx_data <= 8'h54; // ASCII for 'T', as a placeholder response
                            tx_data_valid <= 1;
                        end
                        // Check for '.SEED' command
                        else if (command_buffer[0] == 8'h53 && // ASCII for 'S'
                                 command_buffer[1] == 8'h45 && // ASCII for 'E'
                                 command_buffer[2] == 8'h45) begin // ASCII for 'E'
                            get_seed <= 1;
                            tx_data <= 8'h53; // ASCII for 'S', as a placeholder response
                            tx_data_valid <= 1;
                        end
                        else begin
                            // For unrecognized commands, echo back the last character received
                            tx_data <= command_buffer[3];
                            tx_data_valid <= 1;
                        end
                    next_state <= IDLE;
                end
            endcase
            current_state <= next_state;
        end
    end


    // Additional logic for handling commands, setting custom_seed, etc., goes here

endmodule
