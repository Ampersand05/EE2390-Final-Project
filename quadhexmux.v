// Updated mux for our project
module mux(
    input [3:0] A, B, C, D, 
    input clk, rst,
    output reg [3:0] segmentNum,
    output reg [3:0] an
);
    reg [15:0] divider;
    reg [1:0] digit_select;

    always @ (posedge clk)
    begin
        divider <= divider + 1;
        if(divider == 0)
            digit_select <= digit_select + 1;
    end

    always @ (*)
    begin
        case(digit_select)
            2'b00: an = 4'b1110; segmentNum = D;
            2'b01: an = 4'b1101; segmentNum = C;
            2'b10: an = 4'b1011; segmentNum = B;
            2'b11: an = 4'b0111; segmentNum = A;
        endcase
    end
endmodule
