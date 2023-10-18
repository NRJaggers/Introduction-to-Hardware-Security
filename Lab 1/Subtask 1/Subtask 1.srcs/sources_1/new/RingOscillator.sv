`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 10/18/2023 04:52:50 AM
// Design Name: 
// Module Name: RingOscillator 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module RingOscillator(
    //inputs select, bx, enable?
    //ouputs latch and no-latch signals
    );
    logic a, b, c, d;
//    MUX Mx1 (.x(a),.y(b),.sel(c),.result(d));
//    MUX MxEN (.x(a),.y(0),.sel(c),.result(d));
//    NEG ngate(.x(a), .nx(b));

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

module NEG(
    input x, 
    output logic nx);
    
    always_comb begin
        nx = ~x;
    end
endmodule

//already a primitive, edit   
//module BUF(
//    input x, 
//    output logic bx);
    
//    always_comb begin
//        bx = x;
//    end
    
//endmodule