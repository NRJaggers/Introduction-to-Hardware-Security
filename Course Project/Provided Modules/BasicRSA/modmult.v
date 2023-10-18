// File modmult.vhd translated with vhd2vl v2.5 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 1995

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002, 2005, 2008-2010, 2015 Larry Doolittle - LBNL
//     http://doolittle.icarus.com/~larry/vhd2vl/
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

//--------------------------------------------------------------------
//--																					----
//-- Modular Multiplier						 									----
//-- RSA Public Key Cryptography IP Core 									----
//-- 																					----
//-- This file is part of the BasicRSA project 							----
//-- http://www.opencores.org/			 									----
//-- 																					----
//-- To Do: 																		----
//-- - Speed and efficiency improvements									----
//-- - Possible revisions for good engineering/coding practices	----
//-- 																					----
//-- Author(s): 																	----
//-- - Steven R. McQueen, srmcqueen@opencores.org 						----
//-- 																					----
//--------------------------------------------------------------------
//-- 																					----
//-- Copyright (C) 2003 Steven R. McQueen       						----
//-- 																					----
//-- This source file may be used and distributed without 			----
//-- restriction provided that this copyright statement is not 	----
//-- removed from the file and that any derivative work contains 	----
//-- the original copyright notice and the associated disclaimer. ----
//-- 																					----
//-- This source file is free software; you can redistribute it 	----
//-- and/or modify it under the terms of the GNU Lesser General 	----
//-- Public License as published by the Free Software Foundation; ----
//-- either version 2.1 of the License, or (at your option) any 	----
//-- later version. 																----
//-- 																					----
//-- This source is distributed in the hope that it will be 		----
//-- useful, but WITHOUT ANY WARRANTY; without even the implied 	----
//-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 		----
//-- PURPOSE. See the GNU Lesser General Public License for more 	----
//-- details. 																		----
//-- 																					----
//-- You should have received a copy of the GNU Lesser General 	----
//-- Public License along with this source; if not, download it 	----
//-- from http://www.opencores.org/lgpl.shtml 							----
//-- 																					----
//--------------------------------------------------------------------
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
// This module implements the modular multiplier for the RSA Public Key Cypher. It expects 
// to receive a multiplicand on th MPAND bus, a multiplier on the MPLIER bus, and a modulus
// on the MODULUS bus. The multiplier and multiplicand must have a value less than the modulus.
//
// A Shift-and-Add algorithm is used in this module. For each bit of the multiplier, the
// multiplicand value is shifted. For each '1' bit of the multiplier, the shifted multiplicand
// value is added	to the product. To ensure that the product is always expressed as a remainder
// two subtractions are performed on the product, P2 = P1-modulus, and P3 = P1-(2*modulus).
// The high-order bits of these results are used to determine whether P sould be copied from
// P1, P2, or P3. 
//
// The operation ends when all '1' bits in the multiplier have been used.
//
// Comments, questions and suggestions may be directed to the author at srmcqueen@mcqueentech.com.
//  Uncomment the following lines to use the declarations that are
//  provided for instantiating Xilinx primitive components.
//library UNISIM;
//use UNISIM.VComponents.all;
// no timescale needed

module modmult(
mpand,
mplier,
modulus,
product,
clk,
ds,
reset,
ready
);

parameter [31:0] MPWID=32;
input [MPWID - 1:0] mpand;
input [MPWID - 1:0] mplier;
input [MPWID - 1:0] modulus;
output [MPWID - 1:0] product;
input clk;
input ds;
input reset;
output ready;

wire [MPWID - 1:0] mpand;
wire [MPWID - 1:0] mplier;
wire [MPWID - 1:0] modulus;
wire [MPWID - 1:0] product;
wire clk;
wire ds;
wire reset;
wire ready;


reg [MPWID - 1:0] mpreg;
reg [MPWID + 1:0] mcreg; wire [MPWID + 1:0] mcreg1; reg [MPWID + 1:0] mcreg2;
reg [MPWID + 1:0] modreg1; reg [MPWID + 1:0] modreg2;
reg [MPWID + 1:0] prodreg; reg [MPWID + 1:0] prodreg1; wire [MPWID + 1:0] prodreg2; wire [MPWID + 1:0] prodreg3; reg [MPWID + 1:0] prodreg4;  //signal count: integer;
wire [1:0] modstate;
reg first;

  // final result...
  assign product = prodreg4[MPWID - 1:0];
  // add shifted value if place bit is '1', copy original if place bit is '0'
  always @(*) begin
    case(mpreg[0])
      1'b 1 : prodreg1 <= prodreg + mcreg;
      default : prodreg1 <= prodreg;
    endcase
  end

  // subtract modulus and subtract modulus * 2.
  assign prodreg2 = prodreg1 - modreg1;
  assign prodreg3 = prodreg1 - modreg2;
  // negative results mean that we subtracted too much...
  assign modstate = {prodreg3[mpwid + 1],prodreg2[mpwid + 1]};
  // select the correct modular result and copy it....
  always @(*) begin
    case(modstate)
      2'b 11 : prodreg4 <= prodreg1;
      2'b 10 : prodreg4 <= prodreg2;
      default : prodreg4 <= prodreg3;
    endcase
  end

  // meanwhile, subtract the modulus from the shifted multiplicand...
  assign mcreg1 = mcreg - modreg1;
  // select the correct modular value and copy it.
  always @(*) begin
    case(mcreg1[MPWID])
      1'b 1 : mcreg2 <= mcreg;
      default : mcreg2 <= mcreg1;
    endcase
  end

  assign ready = first;
  always @(posedge clk or posedge first or posedge ds or posedge mpreg or posedge reset) begin
    if(reset == 1'b 1) begin
      first <= 1'b 1;
    end else begin
      if(first == 1'b 1) begin
        // First time through, set up registers to start multiplication procedure
        // Input values are sampled only once
        if(ds == 1'b 1) begin
          mpreg <= mplier;
          mcreg <= {2'b 00,mpand};
          modreg1 <= {2'b 00,modulus};
          modreg2 <= {1'b 0,modulus,1'b 0};
          prodreg <= {(((MPWID + 1))-((0))+1){1'b0}};
          first <= 1'b 0;
        end
      end
      else begin
        // when all bits have been shifted out of the multiplicand, operation is over
        // Note: this leads to at least one waste cycle per multiplication
        if(mpreg == 0) begin
          first <= 1'b 1;
        end
        else begin
          // shift the multiplicand left one bit
          mcreg <= {mcreg2[MPWID:0],1'b 0};
          // shift the multiplier right one bit
          mpreg <= {1'b 0,mpreg[MPWID - 1:1]};
          // copy intermediate product
          prodreg <= prodreg4;
        end
      end
    end
  end


endmodule
