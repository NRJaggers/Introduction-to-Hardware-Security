`timescale 1ns / 1ps
// =============================================================================
// Title: UART Stream Module (Top)
// Description:
//   This is the top module for our hardware trojan project. It is the wrapper
//   between IO and our internal modules.
//   UART tx and rx are implemeted through the respective modules seen below.
//   Data gathered from the rx line is processed throught the Command Processor (CP)
//   and proper output is determined and passed along to the tx module.
//
// Inputs:
//   clk - Clock input.
//   reset - Synchronous reset input.
//   i_uart_rx - data bit recieved from UART.
//
// Outputs:
//   LED - Lights to show data byte recieved by rx module
//   o_uart_tx - data bit sent with UART.
//
// Authors: Qingyu Han, Weston Keitz, Nathan Jaggers
// Date:   12-05-2023
// =============================================================================
module uart_stream(
  input        clock,
  input        reset,
  output[7:0]  LED,
  input        i_uart_rx,
  output       o_uart_tx
);

    wire rx_dv, tx_done;
    wire tx_active, tx_serial;
    wire[7:0] rx_data, tx_data;
    
    uart_rx #(.CLKS_PER_BIT(10417)) uart_rx_inst
    (.clock(clock),
     .uart_rx(i_uart_rx),
     .rx_dv(rx_dv),
     .rx_data(rx_data));
     
    //Control input output behavior with control unit
    command_processor UART_CU
    (
        .clk(clock),
        .reset(reset),
        .rx_data(rx_data),
        .rx_data_ready(rx_dv),
        .tx_data_done(tx_done),
        .process_rng(),
        .custom_seed(),
        .set_custom_seed(),
        .get_seed(),
        .tx_data(tx_data),
        .tx_data_valid(tx_start)  
    );
    
    uart_tx #(.CLKS_PER_BIT(10417)) uart_tx_inst
    (.clock(clock),
     .tx_dv(tx_start),
     .tx_data(tx_data),
     .tx_active(tx_active),
     .tx_serial(tx_serial),
     .tx_done(tx_done));
    
    assign o_uart_tx = tx_active ? tx_serial : 1'b1; 
    
    // display data on LEDs  
    reg [7:0]  led_reg; 
    
    always @ (posedge clock)
    begin
    led_reg <= rx_data;
    end
    
    assign LED = led_reg;

endmodule
