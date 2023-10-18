`timescale 1ns / 1ps

/* 

16 register file
protect upper registers with U_ID match 

*/
 
module reg_file(
  input [3:0] RF_ADR1, RF_ADR2, RF_WA,
  input RF_EN, CLK,
  input [15:0] RF_WD, U_ID,
  output logic [15:0] RF_RS1, RF_RS2);
  
  logic [15:0] register [0:15];
    
  initial begin
    int i;  
      for (i=0; i < 16; i++) begin
        register[i] = 0;
      end
    end
    
    always_ff@(posedge CLK)
      begin
          if (RF_EN == 1 && RF_WA != 0)
            if (RF_WA < 13)
              register[RF_WA] <= RF_WD;
            else if (U_ID == 31)
              register[RF_WA] <= RF_WD;
      end 
    
    assign RF_RS1 = register[RF_ADR1];
    assign RF_RS2 = register[RF_ADR2];
    
endmodule
