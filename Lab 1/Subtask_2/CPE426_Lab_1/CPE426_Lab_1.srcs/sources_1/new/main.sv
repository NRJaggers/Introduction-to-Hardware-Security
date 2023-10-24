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
`define LED_COUNT_LIMIT 500


module main(
    input logic CLK,  // Clock input, assumed to be 50 MHz
    input [15:0] SWITCHES, // Switches to set the lower 6 bits of the challenge
    output logic [15:0] LEDS  // LED output
);

    logic [7:0] response;  // Declare an internal signal for the response

    // Instantiate the puf_challenge_response module
    puf_challenge_response puf_inst (
        .CLK(CLK),
        .challenge_bits(SWITCHES[5:0]),  // Connect only the lower 6 bits
        .response(response)
    );

endmodule    
    






