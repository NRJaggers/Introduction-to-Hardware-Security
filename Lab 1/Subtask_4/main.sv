`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2023 12:42:37 PM
// Design Name: 
// Module Name: main
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

module main(
    input  logic CLK,               // Clock input, assumed to be 50 MHz
//    input  logic reset,             //Used for 7 segment display
    input  logic BTNC,              //Used to recalculate PUF
    input  logic [15:0] SWITCHES,   // Switches to set the lower 6 bits of the challenge
    output logic [3:0]  ANODES,     // anode signals of the 7-segment LED display
    output logic [6:0]  CATHODES,   // cathode patterns of the 7-segment LED display
    output logic [15:0] LEDS        // LED output
);

    logic [7:0] response;  // Declare an internal signal for the response
    logic [15:0] challenge_response; // Concatenated challenge and response
    logic [15:0] prev_challenge_response; // Previous value of challenge_response
    logic [127:0] hash_output; // Output from SHA128
    logic hash_ready; // Ready signal from SHA128
    logic start_signal; // Signal to start new hash
    logic [15:0] display_value;  // Variable to hold the value to be displayed
    logic reset = 1'b0;     //Dummy reset signal
    
    // Instantiate the puf_challenge_response module to interact with the PUF
    puf_challenge_response puf_inst (
        .CLK(CLK),                          // Connect the clock signal
        .recalculate(BTNC),                 // Use inverted BTNC for recalculation (active low to active high)
        .challenge_lower_bits(SWITCHES[5:0]), // Lower 6 bits of the challenge from switches
        .response(response),                // Output response
        .completed(LEDS[14])                // Signal completion through LED 14
    );
    
    // Instantiate the sha128_simple module
//    sha128_simple sha_inst (
//        .CLK(CLK),
//        .DATA_IN(challenge_response),
//        .RESET(reset), // Assuming you want to use the same reset
//        .START(start_signal), // Controlled start signal
//        .READY(hash_ready),
//        .DATA_OUT(hash_output)
//    );
    assign hash_output = 127'h1000_0111_0110_0101_0100_0011_0010_;
    
    
    // Map the 8-bit response to LEDs 0 through 7
    assign LEDS[7:0] = response;
    // Concatenate challenge and response
    assign challenge_response = {SWITCHES[5:0], response};
   // Update LED 15 when hash is ready
    assign LEDS[15] = hash_ready;
    
    // Logic to check if challenge_response has changed and trigger START
    always_ff @(posedge CLK) begin
        if (challenge_response != prev_challenge_response) begin
            start_signal <= 1'b1;  // Set START high for one clock cycle
        end else begin
            start_signal <= 1'b0;  // Set START low otherwise
        end
        prev_challenge_response <= challenge_response;  // Store the current challenge_response
    end
    
    // Logic for Seven-Segment Display based on SWITCHES[15:12]
    always_comb begin
        logic [3:0] switch_decode;   // Variable to hold the decoded switch value        
        switch_decode = SWITCHES[15:12];  // Extract the relevant switch bits
        
        if (switch_decode == 4'b0000) begin
            // When switches are 0000, display challenge and response concatenation
            display_value = challenge_response;
        end else if (switch_decode > 4'b1000) begin
           // If the decoded value is greater than 8, display all zeros
            display_value = 16'h0000;
        end else begin
            // Extract the corresponding 16-bit slice from hash_output
            // Note: We use (switch_decode - 1) as the starting bit index
            display_value = hash_output[16*(switch_decode - 1) +: 16];
        end
    end
    
    // Instantiate the Seven_segment_LED_Display_Controller to display numbers
    Seven_segment_LED_Display_Controller seven_seg (
        .clock_100Mhz(CLK),                 // Connect the 100 MHz clock signal
        .reset(reset),                      // Reset signal for the display controller
        .displayed_number(display_value), // Number to be displayed
        .ANODES(ANODES),                    // Anode signals for the 7-segment display
        .CATHODES(CATHODES)                 // Cathode signals for the 7-segment display
    );
          
       
//------------------- SINGLE RO MODULE TEST ---------------------------
//    TEST_single_RO ro_test_inst (
//        .CLK(CLK),
//        .reset(reset),
//        .SWITCHES(SWITCHES[5:0]),
//        .ANODES(ANODES),
//        .CATHODES(CATHODES)
//    );


//------------------- RO PUF MODULE TEST ---------------------------
//    TEST_ro_puf test_ro_puf_inst (
//        .CLK(CLK),                 // Connect to main's CLK
//        .reset(reset),             // Connect to main's reset
//        .SWITCHES(SWITCHES),       // Connect to main's SWITCHES
//        .ANODES(ANODES),           // Connect to main's ANODES
//        .CATHODES(CATHODES)        // Connect to main's CATHODES


//    );
endmodule    
    


// -----------------------------------------------------------------------------
// Module: TEST_single_RO
// Author: Qingyu Han  
// Date:   Oct 22, 2023
//
// Description:
// This module is designed to count the number of positive edges on the 
// ro_output signal. When 25 million positive edges are detected, it increments
// the ro_count by 1. The module takes a 6-bit SWITCHES input to set the lower 
// 6 bits of the challenge for the configurable_RO_Xin instance.
//
// Inputs:
// - CLK: Clock input, assumed to be 50 MHz
// - SWITCHES: 6-bit input to set the lower 6 bits of the challenge
//
// Outputs:
// - ro_count: 16-bit output that increments when 25M positive edges are detected
// -----------------------------------------------------------------------------

module TEST_single_RO(
    input  logic CLK,          // Clock input
    input  logic reset,        // Reset for 7-segment display
    input  logic [5:0] SWITCHES, // Switches for challenge bits
    output logic [3:0] ANODES, // Anode signals for 7-segment display
    output logic [6:0] CATHODES // Cathode patterns for 7-segment display
);

    logic [15:0] ro_count = 16'b0;  // Initialize to zero
    logic [24:0] edge_counter = 25'b0;  // 25-bit counter for 25M edges
    logic ro_output;
    logic ro_output_prev = 1'b0;  // To store the previous state of ro_output

    // Instantiate configurable_RO_Xin module
    configurable_RO_Xin configurable_RO_inst (
        .sel({1'b0, SWITCHES[5:3]}),
        .bx({1'b0, SWITCHES[2:0]}),
        .enable(1'b1),
        .ro_output(ro_output)
    );

    // Edge detection and counting logic
    always @(posedge CLK) begin  
        if (ro_output && !ro_output_prev) begin  
            edge_counter <= edge_counter + 1;
            if (edge_counter == 25_000_000) begin  
                ro_count <= ro_count + 1;
                edge_counter <= 0;
            end
        end
        ro_output_prev <= ro_output;
    end

    // 7-segment LED display controller
    Seven_segment_LED_Display_Controller uut (
        .clock_100Mhz(CLK),
        .reset(reset),
        .displayed_number(ro_count),
        .ANODES(ANODES),
        .CATHODES(CATHODES)
    );
endmodule



// -----------------------------------------------------------------------------
// Module: TEST_ro_puf
//
// Description:
// This module is designed to control a Ring Oscillator Physical Unclonable 
// Function (RO PUF) and a seven-segment LED display. It toggles the enable
// signal for the RO PUF every 50M clock cycles and displays the RO PUF count
// on the seven-segment LED display.
//
// Inputs:
// - CLK: Clock input, assumed to be 50 MHz
// - reset: Reset signal for the seven-segment display
// - SWITCHES: 16-bit input from switches to set the lower 6 bits of the challenge
//
// Outputs:
// - ANODES: Anode signals for the seven-segment LED display
// - CATHODES: Cathode patterns for the seven-segment LED display
// -----------------------------------------------------------------------------

module TEST_ro_puf(
    input  logic CLK,          // Clock input
    input  logic reset,        // Reset signal for 7-segment display
    input  logic [15:0] SWITCHES, // Switch input for challenge bits
    output logic [3:0]  ANODES, // Anode signals for 7-segment display
    output logic [6:0]  CATHODES // Cathode patterns for 7-segment display
);

    // Local variables
    logic [31:0] clk_counter = 0;  // 32-bit counter for 50M clock cycles
    logic [31:0] ro_count;          // RO PUF count
    logic enable_ro_puf = 1'b1;     // Enable signal for RO PUF, initialized to high

    // Instantiate configurable_RO_PUF module
    configurable_RO_PUF ro_puf_inst (
        .challenge({4'b0000, SWITCHES[5:0]}), // Challenge input
        .clk(CLK),                            // Clock input
        .en(enable_ro_puf),                   // Enable signal
        .ro_count_out(ro_count),              // RO PUF count output
        .completed()                          // Completion signal (not used)
    );

    // Toggle enable_ro_puf every 50M clock cycles
    always @(posedge CLK) begin
        clk_counter <= clk_counter + 1;
        if (clk_counter >= 50_000_000) begin
            enable_ro_puf <= 1'b0;  // Disable RO PUF for one cycle
            clk_counter <= 0;       // Reset the counter
        end else if (clk_counter >= 1) begin
            enable_ro_puf <= 1'b1;  // Enable RO PUF
        end
    end

    // Instantiate 7-segment LED display controller
    Seven_segment_LED_Display_Controller uut (
        .clock_100Mhz(CLK),          // Clock input
        .reset(reset),               // Reset signal
        .displayed_number(ro_count), // Number to display
        .ANODES(ANODES),             // Anode signals output
        .CATHODES(CATHODES)          // Cathode patterns output
    );

endmodule

