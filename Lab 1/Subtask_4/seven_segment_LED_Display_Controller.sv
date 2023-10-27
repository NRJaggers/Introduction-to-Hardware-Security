`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2023 11:04:20 AM
// Design Name: 
// Module Name: seven_segment_LED_Display_Controller
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

module Seven_segment_LED_Display_Controller(
    input clock_100Mhz, // 100 Mhz clock source on Basys 3 FPGA
    input reset, // reset
    input logic [31:0] displayed_number,    // counting number to be displayed
    output reg [3:0] ANODES, // anode signals of the 7-segment LED display
    output reg [6:0] CATHODES// cathode patterns of the 7-segment LED display
    );
    
    reg [3:0] LED_HEX;
    reg [19:0] refresh_counter;
    wire [1:0] LED_activating_counter;

    always @(posedge clock_100Mhz or posedge reset)
    begin 
        if(reset==1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    
    assign LED_activating_counter = refresh_counter[19:18];

    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            ANODES = 4'b0111;
            LED_HEX = displayed_number[15:12];
              end
        2'b01: begin
            ANODES = 4'b1011;
            LED_HEX = displayed_number[11:8];
              end
        2'b10: begin
            ANODES = 4'b1101;
            LED_HEX = displayed_number[7:4];
                end
        2'b11: begin
            ANODES = 4'b1110;
            LED_HEX = displayed_number[3:0];
               end
        endcase
    end
    
    always @(*)
    begin
        case(LED_HEX)
        4'b0000: CATHODES = 7'b0000001; // "0"
        4'b0001: CATHODES = 7'b1001111; // "1"
        4'b0010: CATHODES = 7'b0010010; // "2"
        4'b0011: CATHODES = 7'b0000110; // "3"
        4'b0100: CATHODES = 7'b1001100; // "4"
        4'b0101: CATHODES = 7'b0100100; // "5"
        4'b0110: CATHODES = 7'b0100000; // "6"
        4'b0111: CATHODES = 7'b0001111; // "7"
        4'b1000: CATHODES = 7'b0000000; // "8"
        4'b1001: CATHODES = 7'b0000100; // "9"
        4'b1010: CATHODES = 7'b0001000; // "A"
        4'b1011: CATHODES = 7'b1100000; // "B"
        4'b1100: CATHODES = 7'b0110001; // "C"
        4'b1101: CATHODES = 7'b1000010; // "D"
        4'b1110: CATHODES = 7'b0110000; // "E"
        4'b1111: CATHODES = 7'b0111000; // "F"
        default: CATHODES = 7'b0000001; // "0"
        endcase
    end
endmodule


//======================= Decimal Version ===========================================================
// Source: https://www.fpga4student.com/2017/09/seven-segment-led-display-controller-basys3-fpga.html
// fpga4student.com: FPGA projects, Verilog projects, VHDL projects
// FPGA tutorial: seven-segment LED display controller on Basys  3 FPGA
//module Seven_segment_LED_Display_Controller(
//    input clock_100Mhz, // 100 Mhz clock source on Basys 3 FPGA
//    input reset, // reset
//    input logic [15:0] displayed_number,    // counting number to be displayed
//    output reg [3:0] ANODES, // anode signals of the 7-segment LED display
//    output reg [6:0] CATHODES// cathode patterns of the 7-segment LED display
//    );
    
//    reg [3:0] LED_BCD;
//    reg [19:0] refresh_counter;     // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
//             // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
//    wire [1:0] LED_activating_counter; 
//             // count     0    ->  1  ->  2  ->  3
//             // activates    LED1    LED2   LED3   LED4
//             // and repeat

//    always @(posedge clock_100Mhz or posedge reset)
//    begin 
//        if(reset==1)
//            refresh_counter <= 0;
//        else
//            refresh_counter <= refresh_counter + 1;
//    end 
    
//    assign LED_activating_counter = refresh_counter[19:18];
//    // anode activating signals for 4 LEDs, digit period of 2.6ms
//    // decoder to generate anode signals 
//    always @(*)
//    begin
//        case(LED_activating_counter)
//        2'b00: begin
//            ANODES = 4'b0111; 
//            // activate LED1 and Deactivate LED2, LED3, LED4
//            LED_BCD = displayed_number/1000;
//            // the first digit of the 16-bit number
//              end
//        2'b01: begin
//            ANODES = 4'b1011; 
//            // activate LED2 and Deactivate LED1, LED3, LED4
//            LED_BCD = (displayed_number % 1000)/100;
//            // the second digit of the 16-bit number
//              end
//        2'b10: begin
//            ANODES = 4'b1101; 
//            // activate LED3 and Deactivate LED2, LED1, LED4
//            LED_BCD = ((displayed_number % 1000)%100)/10;
//            // the third digit of the 16-bit number
//                end
//        2'b11: begin
//            ANODES = 4'b1110; 
//            // activate LED4 and Deactivate LED2, LED3, LED1
//            LED_BCD = ((displayed_number % 1000)%100)%10;
//            // the fourth digit of the 16-bit number    
//               end
//        endcase
//    end
    
//    // Cathode patterns of the 7-segment LED display 
//    always @(*)
//    begin
//        case(LED_BCD)
//        4'b0000: CATHODES = 7'b0000001; // "0"     
//        4'b0001: CATHODES = 7'b1001111; // "1" 
//        4'b0010: CATHODES = 7'b0010010; // "2" 
//        4'b0011: CATHODES = 7'b0000110; // "3" 
//        4'b0100: CATHODES = 7'b1001100; // "4" 
//        4'b0101: CATHODES = 7'b0100100; // "5" 
//        4'b0110: CATHODES = 7'b0100000; // "6" 
//        4'b0111: CATHODES = 7'b0001111; // "7" 
//        4'b1000: CATHODES = 7'b0000000; // "8"     
//        4'b1001: CATHODES = 7'b0000100; // "9" 
//        default: CATHODES = 7'b0000001; // "0"
//        endcase
//    end
// endmodule