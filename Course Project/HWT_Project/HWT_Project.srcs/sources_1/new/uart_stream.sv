`timescale 1ns / 1ps

module uart_stream(
  input        clock,
  output[7:0]  LED,
  input        i_uart_rx,
  output       o_uart_tx
  //add reset?
);

    wire rx_dv, tx_dv;
    wire tx_active, tx_serial;
    wire[7:0] rx_data, tx_data;
    
    uart_rx #(.CLKS_PER_BIT(10417)) uart_rx_inst
    (.clock(clock),
     .uart_rx(i_uart_rx),
     .rx_dv(rx_dv),
     .rx_data(rx_data));
     
    //Control input output behavior with control unit
    control_unit UART_CU
    (
    .clk(clock),
    .rx_done(rx_dv),
    .tx_done(tx_dv),
    .rx_data(rx_data),
    .tx_data(tx_data),
    .tx_ready(tx_start)
    );
    
    uart_tx #(.CLKS_PER_BIT(10417)) uart_tx_inst
    (.clock(clock),
     .tx_dv(tx_start),
     .tx_data(tx_data),
     .tx_active(tx_active),
     .tx_serial(tx_serial),
     .tx_done(tx_dv));
    
    assign o_uart_tx = tx_active ? tx_serial : 1'b1; 
    
    // display data on LEDs  
    reg [7:0]  led_reg; 
    
    always @ (posedge clock)
    begin
    led_reg <= rx_data;
    end
    
    assign LED = led_reg;

endmodule

module control_unit
    #(
        parameter   DBITS = 8          // number of data bits in a data word
    )
    (
        input clk,
        input rx_done,
        input tx_done,
        input [DBITS-1:0] rx_data,
        output logic [DBITS-1:0] tx_data,
        output logic tx_ready
    );
    
    //pass through
    assign tx_ready = rx_done;
    assign tx_data = rx_data;
    
    // Connection Signals
    //logic read_in_rx;
//    logic analyze_data;
//    logic [DBITS-1:0] read_data; 
    
//    //Internal Logic
//    always @(posedge clk, posedge reset)
//        if(reset) begin
//            //read_in_rx <= 1'b0;
//            analyze_data <= 1'b0;
//            read_data  <= 8'b0;
//            tx_data <= 8'b0;
//            tx_ready <= 1'b0;
//        end
       
    //when data is ready, read into holding place and analyze it
    //when transmit is done, reset transmit ready
//    always @(posedge clk) begin
//        if(rx_done) begin
//            //read_in_rx = 1'b1;
//            analyze_data <= 1'b1;
//            read_data <= rx_data;
//        end
        
//        if(tx_done) begin
//            tx_ready <= 1'b0; 
//        end
        
//    end 
//    //analyze data read and determine next action
//    always @(posedge clk)
//        if(analyze_data) begin
//            tx_data <= read_data;
//            case (read_data)
//                8'h00: tx_ready = 1'b0; // Null value read, nothing to transmit
//                default:tx_ready = 1'b1; // If anything else, propogate it
//            endcase
            
//            analyze_data <= 1'b0;
//        end

    //transmit proper data based on analysis of data read in (select data and set ready signal)
    // more to come later
    
    
endmodule 