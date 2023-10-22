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
    input wire CLK,  // Clock input, assumed to be 50 MHz
    input wire BTNC, //Button to reset stuff. 
    output logic [15:0] LEDS  // LED output
);

//logic [31:0] count_limit = 32'h17D7840;  // 25M
logic [31:0] count_limit = 32'd500;  // 25M

// Instantiate the Modified_LED_Blinker module
//LED_Blinker led_blink_instance (
//    .osc_signal(CLK),  // Connect the oscillating signal
//    .count_limit(count_limit),  // Connect the count limit
//    .led(LEDS[3])  // Connect the LED
//);

   wire ro_toggle;
   
   //Figure 5 RO
//   configurable_RO_maiti configurable_RO_1 (
//        .c(3'b111), 
//        .enable(1'b1),
//        .ro_output (ro_toggle)
//    );

    //Figure 6 RO
//    configurable_RO_Xin configurable_RO_1 (
//        .sel(4'b1111),
//        .bx(4'b1111),
//        .enable(1'b1),
//        .ro_output(ro_toggle)
//    );
        
//    LED_Blinker led_blink_instance (
//        .osc_signal(ro_toggle),  // Connect the oscillating signal
//        .count_limit(count_limit),  // Connect the count limit
//        .led(LEDS[3])  // Connect the LED
//    );
    
    
    logic [31:0] ro_count_out; //32 bit RO Counter
    logic [9:0] challenge = 10'b0101010101;
    logic count_complete;
    configurable_RO_PUF puf_inst (
        .challenge(challenge),
        .clk(CLK),
        .en(~BTNC),
        .ro_count_out(ro_count_out),
        .completed(count_complete)
    );
    assign LEDS[3] = count_complete; //USED FOR SIMULATION DEBUGGING
    
//    LED_Blinker led_blink_instance (
//        .osc_signal(count_complete),  // Connect the oscillating signal
//        .count_limit(count_limit),  // Connect the count limit
//        .led(LEDS[3])  // Connect the LED
//    );

endmodule



