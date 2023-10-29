`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Modified by Nathan Jaggers from Qingyu Han 
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
    output logic [15:0] LEDS        // LED output
);

    logic ro_output[3:0];
    
    // Instantiate configurable_RO_Xin module - Default
    configurable_RO_Xin configurable_RO_inst_0 (
        .sel(4'b0),
        .bx(4'b0),
        .enable(1'b1),
        .ro_output(ro_output[0])
    );
    
    // Instantiate configurable_RO_Xin module - Other MUX signal
    configurable_RO_Xin configurable_RO_inst_1 (
        .sel(4'b1),
        .bx(4'b0),
        .enable(1'b1),
        .ro_output(ro_output[1])
    );
    
    // Instantiate configurable_RO_Xin module - Singal through Latch (Buffer)
    configurable_RO_Xin configurable_RO_inst_2 (
        .sel(4'b0),
        .bx(4'b1),
        .enable(1'b1),
        .ro_output(ro_output[2])
    );
    
    // Instantiate configurable_RO_Xin module - Both 
    configurable_RO_Xin configurable_RO_inst_3 (
        .sel(4'b1),
        .bx(4'b1),
        .enable(1'b1),
        .ro_output(ro_output[3])
    );

    //Clock LED
    LED_Blinker Blink_CLK (
        .osc_signal(CLK),  // Oscillating signal input
        .count_limit(32'd50_000_000), // 32-bit count limit input
        .led(LEDS[0])          // LED output
    );
    
    //RO 0 (Default) LED
        LED_Blinker Blink_RO_0 (
        .osc_signal(ro_output[0]),  // Oscillating signal input
        .count_limit(32'd50_000_000), // 32-bit count limit input
        .led(LEDS[1])          // LED output
    );
    
        //RO 1 LED
        LED_Blinker Blink_RO_1 (
        .osc_signal(ro_output[1]),  // Oscillating signal input
        .count_limit(32'd50_000_000), // 32-bit count limit input
        .led(LEDS[2])          // LED output
    );
    
        //RO 2 LED
        LED_Blinker Blink_RO_2 (
        .osc_signal(ro_output[2]),  // Oscillating signal input
        .count_limit(32'd50_000_000), // 32-bit count limit input
        .led(LEDS[3])          // LED output
    );
    
        //RO 3 LED
        LED_Blinker Blink_RO_3 (
        .osc_signal(ro_output[3]),  // Oscillating signal input
        .count_limit(32'd50_000_000), // 32-bit count limit input
        .led(LEDS[4])          // LED output
    );
    
   
       
endmodule    