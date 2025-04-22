// quadhexmux.v for EE 2390 Lab #05
module quadhexmux(Muxd,Anode,A,B,C,D,Sel);
   output [3:0] Muxd;
   output [0:3] Anode;
   input  [3:0] A, B, C, D;
   input  [0:3] Sel;
   
   reg    [3:0] Muxd;

   assign Anode = ~Sel; // Provides active low drive on anode transistors.

   always @(A,B,C,D,Sel)
   begin
       case(Sel)
           4'b0001: Muxd = D;
           4'b0010: Muxd = C;
           4'b0100: Muxd = B;
           4'b1000: Muxd = A;
           default: Muxd = 4'b0000; // Note what happens if more than one!
       endcase
   end

endmodule
