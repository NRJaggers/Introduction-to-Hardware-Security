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
    SLICE_ENABLE X0Y1(ta0,enable,ta1,tb1);
    
    //slice X0Y0 - 1
    SLICE_NEG X0Y0(ta1,tb1,sel[0],bx[0],ta2,tb2);
    
    //slice X1Y1 - 2
    SLICE_NEG X1Y1(ta2,tb2,sel[1],bx[1],ta3,tb3);
    
    //slice X1Y0 - 3
    SLICE_BUF X1Y0(ta3,tb3,sel[2],bx[2],ta0);
    
    assign probe = ta0;
    //assign LEDS[0] = probe;

endmodule

module SLICE_NEG(
    input A, 
    input B,
    input sel, 
    input bx,
    output logic out1,
    output logic out2
    );
    
    logic t1,t2;
    
    LUT_NEG F(.A(A),.B(B),.sel(sel),.out(t1));
    LUT_NEG G(.A(A),.B(B),.sel(sel),.out(t2));
    
    MUX M1(.x(t2), .y(t1), .sel(bx), .result(out1));
    
    //Pass through latch
    LATCH(.D(out1),.Q(out2));
    //assign out2 = out1;

endmodule

module SLICE_BUF(
    input A, 
    input B,
    input sel, 
    input bx,
    output logic out1);
    
    logic t1,t2;
    
    LUT_BUF F(.A(A),.B(B),.sel(sel),.out(t1));
    LUT_BUF G(.A(A),.B(B),.sel(sel),.out(t1));
    
    MUX M1(.x(t2), .y(t1), .sel(bx), .result(out1));

endmodule


module SLICE_ENABLE(
    input A, 
    input enable,
    output logic out1,
    output logic out2
    );
        
    MUX M1(.x(A), .y(0), .sel(enable), .result(out1));
    
    //want latch here
    LATCH(.D(out1),.Q(out2));
    //assign out2 = out1;

endmodule

// need a Lut buffer or to re write this and include negations elsewhere
module LUT_NEG(
    input A, B, sel,
    output logic out);
    
    MUX MLT(.x(~A), .y(~B), .sel(sel), .result(out));
        
    
endmodule

module LUT_BUF(
    input A, B, sel,
    output logic out);

    buf(A,a);
    buf(B,b);
    MUX MLT(.x(a), .y(b), .sel(sel), .result(out));
        
    
endmodule

//module LUT_EN(
//    input A, B, sel, enable,
//    output logic out);
    
//    logic t1;
    
//    MUX MLT(~A,~B,sel,t1);
//    MUX MLT(.x(t2), .y(t1), .sel(bx), .result(out1));
     
//    MUX MMT(t1, 0, enable, gout);
    
    
//endmodule

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

module LATCH(
    input D,
    output logic Q);

    always_comb begin
        Q = D;
    end

endmodule