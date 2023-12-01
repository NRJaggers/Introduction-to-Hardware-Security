`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2023 02:45:20 PM
// Design Name: 
// Module Name: uart_stream
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


module uart_stream
    #(
        parameter   DBITS = 8,          // number of data bits in a word
                    SB_TICK = 16,       // number of stop bit / oversampling ticks
                    BR_LIMIT = 651,     // baud rate generator counter limit
                    BR_BITS = 10,       // number of baud rate generator counter bits
                    FIFO_EXP = 2        // exponent for number of FIFO addresses (2^2 = 4)
    )
    (
    input clk_100MHz,       // basys 3 FPGA clock signal
    input reset,            // btnR    
    input rx,               // USB-RS232 Rx
    output tx,              // USB-RS232 Tx
    output [3:0] an,        // 7 segment display digits
    output [0:6] seg,       // 7 segment display segments
    output [7:0] LED        // data byte display
    );
    
    // Connection Signals
    wire rx_full, rx_empty, btn_tick;
    wire [7:0] rec_data, rec_data1;
    wire tick;                          // sample tick from baud rate generator
    wire rx_done_tick;                  // data word received
    wire tx_done_tick;                  // data transmission complete
    reg  tx_empty;                      // Tx FIFO has no data to transmit
    wire tx_start;             
    reg  [DBITS-1:0] tx_data_in;        // from Tx FIFO to UART transmitter
    reg  [DBITS-1:0] rx_data_out;       // from UART receiver to Rx FIFO
    
    // Instantiate Modules for UART Core
    // - baud rate generator
    // - rx unit
    // - tx unit
    // - control unit
    
    //use this module to generate ticks
    baud_rate_generator 
        #(
            .M(BR_LIMIT), 
            .N(BR_BITS)
         ) 
        BAUD_RATE_GEN   
        (
            .clk_100MHz(clk_100MHz), 
            .reset(reset),
            .tick(tick)
         );
    
    //recieve data on the UART Rx unit
    uart_receiver
        #(
            .DBITS(DBITS),
            .SB_TICK(SB_TICK)
         )
         UART_RX_UNIT
         (
            .clk_100MHz(clk_100MHz),
            .reset(reset),
            .rx(rx),
            .sample_tick(tick),
            .data_ready(rx_done_tick),
            .data_out(rx_data_out)
         );
         
    //Control input output behavior with control unit
    control_unit UART_CU
    (
        .clk(clk_100MHz),
        .reset(reset),
        .rx_done(rx_done_tick),
        .tx_done(tx_done_tick),
        .rx_data(rx_data_out),
        .tx_data(tx_data_in),
        .tx_ready(tx_start)
    );
    
    //transmit data on the UART Tx unit
    uart_transmitter
    #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK)
     )
     UART_TX_UNIT
     (
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        .tx_start(tx_start), // needs to be changed
        .sample_tick(tick),
        .data_in(tx_data_in),
        .tx_done(tx_done_tick),
        .tx(tx)
     );

    
    // Signal Logic    
    //assign rec_data1 = rec_data + 1;    // add 1 to ascii value of received data (to transmit)
    assign rec_data1 = rec_data;
    
    // Output Logic
    assign LED = rx_data_out;              // data byte received displayed on LEDs
    assign an = 4'b1110;                // using only one 7 segment digit 
    assign seg = {~rx_full, 2'b11, ~rx_empty, 3'b111};
    
endmodule

module control_unit
    #(
        parameter   DBITS = 8          // number of data bits in a data word
    )
    (
        input clk,
        input reset,
        input rx_done,
        input tx_done,
        input [DBITS-1:0] rx_data,
        output logic [DBITS-1:0] tx_data,
        output logic tx_ready
    );
    
    // Connection Signals
    //logic read_in_rx;
    logic analyze_data;
    logic [DBITS-1:0] read_data; 
    
    //Internal Logic
    always @(posedge clk, posedge reset)
        if(reset) begin
            //read_in_rx <= 1'b0;
            analyze_data <= 1'b0;
            read_data  <= 8'b0;
            tx_data <= 8'b0;
            tx_ready <= 1'b0;
        end
       
    //when data is ready, read into holding place and analyze it
    //when transmit is done, reset transmit ready
    always @(posedge clk) begin
        if(rx_done) begin
            //read_in_rx = 1'b1;
            analyze_data <= 1'b1;
            read_data <= rx_data;
        end
        
        if(tx_done) begin
            tx_ready <= 1'b0; 
        end
        
    end 
    //analyze data read and determine next action
    always @(posedge clk)
        if(analyze_data) begin
            tx_data <= read_data;
            case (read_data)
                8'h00: tx_ready = 1'b0; // Null value read, nothing to transmit
                default:tx_ready = 1'b1; // If anything else, propogate it
            endcase
            
            analyze_data <= 1'b0;
        end

    //transmit proper data based on analysis of data read in (select data and set ready signal)
    // more to come later
    
    
endmodule 


//// configured for Baud Rate of 9600
//module uart_module
//    #(
//        parameter   DBITS = 8,          // number of data bits in a word
//                    SB_TICK = 16,       // number of stop bit / oversampling ticks
//                    BR_LIMIT = 651,     // baud rate generator counter limit
//                    BR_BITS = 10,       // number of baud rate generator counter bits
//                    FIFO_EXP = 2        // exponent for number of FIFO addresses (2^2 = 4)
//    )
//    (
//        input clk_100MHz,               // FPGA clock
//        input reset,                    // reset
//        input rx,                       // serial data in
//        input [DBITS-1:0] write_data,   // data from Tx FIFO
//        //output rx_full,                 // do not write data to FIFO
//        //output rx_empty,                // no data to read from FIFO
//        output tx,                      // serial data out
//        output [DBITS-1:0] read_data    // data to Rx FIFO
//    );
    
//    // Connection Signals
//    wire tick;                          // sample tick from baud rate generator
//    wire rx_done_tick;                  // data word received
//    wire tx_done_tick;                  // data transmission complete
//    reg  tx_empty;                      // Tx FIFO has no data to transmit
//    wire tx_fifo_not_empty;             // Tx FIFO contains data to transmit
//    wire [DBITS-1:0] tx_fifo_out;       // from Tx FIFO to UART transmitter
//    reg  [DBITS-1:0] rx_data_out;       // from UART receiver to Rx FIFO
    
//    // Instantiate Modules for UART Core
//    baud_rate_generator 
//        #(
//            .M(BR_LIMIT), 
//            .N(BR_BITS)
//         ) 
//        BAUD_RATE_GEN   
//        (
//            .clk_100MHz(clk_100MHz), 
//            .reset(reset),
//            .tick(tick)
//         );
    
//    uart_receiver
//        #(
//            .DBITS(DBITS),
//            .SB_TICK(SB_TICK)
//         )
//         UART_RX_UNIT
//         (
//            .clk_100MHz(clk_100MHz),
//            .reset(reset),
//            .rx(rx),
//            .sample_tick(tick),
//            .data_ready(rx_done_tick),
//            .data_out(rx_data_out)
//         );
    
//    uart_transmitter
//        #(
//            .DBITS(DBITS),
//            .SB_TICK(SB_TICK)
//         )
//         UART_TX_UNIT
//         (
//            .clk_100MHz(clk_100MHz),
//            .reset(reset),
//            .tx_start(tx_fifo_not_empty),
//            .sample_tick(tick),
//            .data_in(write_data),
//            .tx_done(tx_done_tick),
//            .tx(tx)
//         );
    
//    // Signal Logic
//    assign tx_fifo_not_empty = ~tx_empty;
//    assign write_data = read_data;
//    assign read_data = rx_data_out;
    
//    always @(posedge clk_100MHz) begin
//    case (rx_data_out)
//        8'h00: tx_empty = 1'b1; // Null value read, nothing to transmit
//        default:tx_empty = 1'b0; // If anything else, propogate it
//    endcase
        
//    if (tx_done_tick)
//        rx_data_out = 8'h00;
//    end
    



  
//endmodule


