`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 10/18/2023 04:52:50 AM
// Design Name: 
// Module Name: RingOscillator 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module RingOscillator(
    //may need to change inputs? get 6 challenge bits, don't know if enable counts
    //may need to tie enable to high
    input [2:0] sel,
    input [2:0] bx,
    input enable,
    output logic probe
    );
    
    //internal traces
    // a - no latch
    // b - latch
    logic ta0, tb0, ta1, tb1, ta2, tb2, ta3, tb3; 
    
    //slice X0Y1 (with enable) - 0
    
    //slice X0Y0 - 1
    
    //slice X1Y1 - 2
    
    //slice X1Y0 - 3
    
//    MUX Mx1 (.x(a),.y(b),.sel(c),.result(d));
//    MUX MxEN (.x(a),.y(0),.sel(c),.result(d));
//    NEG ngate(.x(a), .nx(b));

    buf(a,b);

endmodule


module slice_enable(
    input clk,
    input A, 
    input B,
    input sel, 
    input enable,
    input bx,
    output logic curr,
    output logic prev);
    
    logic t1,t2;
    
    LUT F(A,B,sel,enable,t1);
    LUT G(A,B,sel,enable,t2);
    
    MUX M1(t2, t1, bx, curr); //flipped order on purpose

endmodule

module slice(
    input A, 
    input B,
    input sel, 
    input bx,
    input enable,
    output logic curr,
    output logic prev);
    
    logic t1,t2;
    
    LUT F(A,B,sel,t1);
    LUT G(A,B,sel,t2);
    
    MUX M1(t2, t1, bx, curr); //flipped order on purpose

endmodule

// need a Lut buffer or to re write this and include negations elsewhere
module LUT(
    input A, B, sel,
    output logic out);
    
    logic t1;
    
    MUX MLT(~A,~B,sel,out);
        
    
endmodule

module LUT_enable(
    input A, B, sel, enable,
    output logic out);
    
    logic t1;
    
    MUX MLT(~A,~B,sel,t1);
     
    MUX MMT(t1, 0, enable, gout);
    
    
endmodule

module MUX(
    
    input x, 
    input y, 
    input sel,
    output logic result);
    
    always_comb begin
        case(sel)
            1'b1: result = x; 
            1'b0: result = y;
            default: result = x; 
        endcase
    end
    
endmodule