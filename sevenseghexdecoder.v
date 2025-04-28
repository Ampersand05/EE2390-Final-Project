module sevenseghexdecoder(seg, BinVal);
    output reg [6:0] seg;
    input [3:0] BinVal;

    always @(BinVal)
    begin
        case(BinVal)
                4'b0000: seg = 7'b000_0001; //0
                4'b0001: seg = 7'b100_1111; //1
                4'b0010: seg = 7'b001_0010; //2
                4'b0011: seg = 7'b000_0110; //3
                4'b0100: seg = 7'b100_1100; //4
                4'b0101: seg = 7'b010_0100; //5
                4'b0110: seg = 7'b010_0000; //6
                4'b0111: seg = 7'b000_1111; //7
                4'b1000: seg = 7'b000_0000; //8
                4'b1001: seg = 7'b000_0100; //9
                default: seg = 7'b111_1111;
        endcase
    end
endmodule
