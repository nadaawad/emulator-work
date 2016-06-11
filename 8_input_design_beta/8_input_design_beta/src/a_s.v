//--------------------------------------------------------------------------------------------
//
// Generated by X-HDL VHDL Translator - Version 2.0.0 Feb. 1, 2011
// ????? ?????? 13 2013 21:07:04
//
//      Input file      : 
//      Component name  : a_s
//      Author          : 
//      Company         : 
//
//      Description     : 
//
//
//--------------------------------------------------------------------------------------------


module a_s(op_a, op_m, as, outp);
   parameter        NBITS = 6;
   input [NBITS:0]  op_a;
   input [NBITS:0]  op_m;
   input            as;
   output [NBITS:0] outp;
   reg [NBITS:0]    outp;
   
   
   
   always @(as or op_a or op_m)
   begin: adder_subt
      if (as == 1'b1)
         outp <= op_a + op_m;
      else
         outp <= op_a - op_m;
   end
   
endmodule
