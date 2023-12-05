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
    input wire tx_data_done,
    output logic process_rng,
    output logic [31:0] custom_seed,
    output logic set_custom_seed,
    output logic get_seed,
    output logic [7:0] tx_data,
    output logic tx_data_valid
);

    localparam CHAR_DOT = 8'h2E; // ASCII for '.'
    localparam CHAR_CR  = 8'h0D; // ASCII for carriage return
    localparam MAX_CHARS = 8;
    
    // State machine states
    typedef enum {
        IDLE,
        WAIT_FOR_COMMAND,
        PROCESS_CMD,
        RNG,
        TEST,
        SEED
    } state_t;
    state_t current_state, next_state;

    // Buffer to store incoming command
    logic [7:0] command_buffer[MAX_CHARS-1:0]; // Adjust size based on expected command length
    logic [3:0] char_count; // Counter for received characters
    integer i;
    
    // UART echo connections/signals
    logic [7:0] tx_echo, tx_cmd;
    logic tx_sel = 0;
    
    //RNG signals
    //logic [31:0] rand_num = 32'hCAFE;
    //logic [31:0] rand_num = 32'hEFAC;
    //logic [31:0] rand_num = 32'hCCCC6666;
    logic [31:0] rand_num; 
    logic [31:0] seed_used;
    logic [6:0] digit_count;
    logic [3:0] nibble;
    logic [3:0] nibble_count;
    
    

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
            digit_count <=32;
            nibble_count <=0;
            for (i = 0; i < MAX_CHARS; i++) command_buffer[i] <= 8'd0;
            tx_sel <= 0;
            tx_echo <= 8'h00; // Default UART transmit data
            tx_cmd <= 8'h00;
            tx_data_valid <= 0;
        end
        else begin
            // Default values
            process_rng <= 0;
            set_custom_seed <= 0;
            get_seed <= 0;
            tx_data_valid <= 0;
//            tx_sel <= 0;
//            tx_echo <= 8'h00; // Default UART transmit data
//            tx_cmd <= 8'h00;
            
            //echo logic and tx mux
//            if (rx_data_ready) begin
//                tx_echo = rx_data;
//                tx_data_valid <= 1;
//            end
            
            if (tx_sel)
                tx_data = tx_cmd;
            else
                tx_data = tx_echo;
                
            if (tx_data_done)begin
                //tx_data_valid <= 0;
                tx_sel <= 0;
            end
            
    
            //state machine
            case (current_state)        
                IDLE: begin
                    if (rx_data_ready && rx_data == CHAR_DOT) begin
                        next_state <= WAIT_FOR_COMMAND;
                        char_count <= 0;
                        for (i = 0; i < MAX_CHARS; i++) command_buffer[i] <= 8'd0;
                    end
                end
                
                WAIT_FOR_COMMAND: begin
                    if (rx_data_ready) begin
                        // Store the received character directly at the index specified by char_count
                        if (char_count < MAX_CHARS) begin // Ensure char_count does not exceed buffer size
                            command_buffer[char_count] <= rx_data;
                            char_count <= char_count + 1;
                        end
                
                        // Transition to PROCESS_CMD state after four characters have been received
                        if (char_count >= MAX_CHARS || rx_data == CHAR_CR) begin
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
                            
                            next_state <= RNG;
                            digit_count <= 32;
                            nibble_count <=0;
                            
                            //maybe keep some or all of these here?
                            process_rng <= 1;
//                            tx_cmd <= 8'h52; // ASCII for 'R', as a placeholder response
//                            tx_data_valid <= 1;
//                            tx_sel <= 1;
                        end
                        // Check for '.TEST' command (simplified, does not parse 'num')
                        else if (command_buffer[0] == 8'h54 && // ASCII for 'T'
                                 command_buffer[1] == 8'h45 && // ASCII for 'E'
                                 command_buffer[2] == 8'h53) begin // ASCII for 'S'
                            next_state <= TEST;
                            
//                            set_custom_seed <= 1;
//                            custom_seed <= `TEST_SEED; // Using a predefined test seed
//                            tx_cmd <= 8'h54; // ASCII for 'T', as a placeholder response
//                            tx_data_valid <= 1;
//                            tx_sel <= 1;
                        end
                        // Check for '.SEED' command
                        else if (command_buffer[0] == 8'h53 && // ASCII for 'S'
                                 command_buffer[1] == 8'h45 && // ASCII for 'E'
                                 command_buffer[2] == 8'h45) begin // ASCII for 'E'
                                 
                            next_state <= SEED;
                            digit_count <= 32;
                            nibble_count <=0;
                            
//                            get_seed <= 1;
//                            tx_cmd <= 8'h53; // ASCII for 'S', as a placeholder response
//                            tx_data_valid <= 1;
//                            tx_sel <= 1;
                        end
                        else begin
                            // For unrecognized commands, echo back the last character received
                            //tx_data <= command_buffer[3];
                            tx_cmd <= 8'h00;
                            tx_data_valid <= 1;
                            tx_sel <= 1;
                            
                            next_state <= IDLE;
                        end                  
                end
                
                RNG: begin
//                    //start printing out the random number (binary)
//                    case (rand_num[digit_count-1])
//                        1'b0: tx_cmd <= 8'h30;
//                        1'b1: tx_cmd <= 8'h31;                        
//                    endcase
                    
//                    if (tx_data_done)
//                        digit_count <= digit_count - 1;
                    
//                    //not sure if signed or unsigned
//                    if (digit_count <=0 || digit_count > 33) begin
//                        next_state <= IDLE;
//                    end
//                    else begin
//                        tx_data_valid <= 1;
//                        tx_sel <= 1;
//                    end
                    
                    //start printing out the random number (hex)
                    case (nibble_count)
                        3'd0: nibble = rand_num[31:28];
                        3'd1: nibble = rand_num[27:24];
                        3'd2: nibble = rand_num[23:20];
                        3'd3: nibble = rand_num[19:16];
                        3'd4: nibble = rand_num[15:12];
                        3'd5: nibble = rand_num[11:8];
                        3'd6: nibble = rand_num[7:4];
                        3'd7: nibble = rand_num[3:0];
                    endcase
                    
                    case (nibble)
                        3'h0: tx_cmd <= 8'h30;
                        3'h1: tx_cmd <= 8'h31;
                        3'h2: tx_cmd <= 8'h32;
                        3'h3: tx_cmd <= 8'h33;
                        3'h4: tx_cmd <= 8'h34;
                        3'h5: tx_cmd <= 8'h35;
                        3'h6: tx_cmd <= 8'h36;
                        3'h7: tx_cmd <= 8'h37;
                        3'h8: tx_cmd <= 8'h38;
                        3'h9: tx_cmd <= 8'h39;
                        3'hA: tx_cmd <= 8'h41;
                        3'hB: tx_cmd <= 8'h42;
                        3'hC: tx_cmd <= 8'h43;
                        3'hD: tx_cmd <= 8'h44;
                        3'hE: tx_cmd <= 8'h45;
                        3'hF: tx_cmd <= 8'h46;
                    endcase
                    
                    if (tx_data_done)
                        nibble_count <= nibble_count + 1;
                    
                    //not sure if signed or unsigned
                    if (nibble_count >=8 ) begin
                        next_state <= IDLE;
                    end
                    else begin
                        tx_data_valid <= 1;
                        tx_sel <= 1;
                    end                   
                    
                end
                
                TEST: begin
                    set_custom_seed <= 1;
                    custom_seed <= `TEST_SEED; // Using a predefined test seed
                    tx_cmd <= 8'h54; // ASCII for 'T', as a placeholder response
                    tx_data_valid <= 1;
                    tx_sel <= 1;
                
                    next_state <= IDLE;
                end
                
                SEED: begin
//                    //start printing out the seed
//                    case (seed_used[digit_count-1])
//                        1'b0: tx_cmd <= 8'h30;
//                        1'b1: tx_cmd <= 8'h31;                        
//                    endcase
                    
//                    if (tx_data_done)
//                        digit_count <= digit_count - 1;
                    
//                    //not sure if signed or unsigned
//                    if (digit_count <=0 || digit_count > 33) begin
//                        next_state <= IDLE;
//                    end
//                    else begin
//                        tx_data_valid <= 1;
//                        tx_sel <= 1;
//                    end

                    //start printing out the random number (hex)
                    case (nibble_count)
                        3'd0: nibble = rand_num[31:28];
                        3'd1: nibble = rand_num[27:24];
                        3'd2: nibble = rand_num[23:20];
                        3'd3: nibble = rand_num[19:16];
                        3'd4: nibble = rand_num[15:12];
                        3'd5: nibble = rand_num[11:8];
                        3'd6: nibble = rand_num[7:4];
                        3'd7: nibble = rand_num[3:0];
                    endcase
                    
                    case (nibble)
                        3'h0: tx_cmd <= 8'h30;
                        3'h1: tx_cmd <= 8'h31;
                        3'h2: tx_cmd <= 8'h32;
                        3'h3: tx_cmd <= 8'h33;
                        3'h4: tx_cmd <= 8'h34;
                        3'h5: tx_cmd <= 8'h35;
                        3'h6: tx_cmd <= 8'h36;
                        3'h7: tx_cmd <= 8'h37;
                        3'h8: tx_cmd <= 8'h38;
                        3'h9: tx_cmd <= 8'h39;
                        3'hA: tx_cmd <= 8'h41;
                        3'hB: tx_cmd <= 8'h42;
                        3'hC: tx_cmd <= 8'h43;
                        3'hD: tx_cmd <= 8'h44;
                        3'hE: tx_cmd <= 8'h45;
                        3'hF: tx_cmd <= 8'h46;
                    endcase
                    
                    if (tx_data_done)
                        nibble_count <= nibble_count + 1;
                    
                    //not sure if signed or unsigned
                    if (nibble_count >=8 ) begin
                        next_state <= IDLE;
                    end
                    else begin
                        tx_data_valid <= 1;
                        tx_sel <= 1;
                    end                   
                end
                               
            endcase
            current_state <= next_state;
        end
    end
    
    // Additional logic for handling commands, setting custom_seed, etc., goes here
    rng_module rng_gen
    (
        .clk(clk),
        .reset(reset),
        .uart_rx(process_rng), 
        .random_number(rand_num), // use rand_num
        .seed_used(seed_used)
    );

endmodule
