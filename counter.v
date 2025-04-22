module time_counter_1dig(
    input en, clk, rst, clr, dir,
    input [3:0] max_val,
    output reg[3:0] ct, 
    output bken, upen
);
    reg [3:0] nct;

   always @(posedge clk or posedge clr) 
    begin
        if (clr)
            ct <= 4'b0000;
        else if (en)
            ct <= nct;
    end

    always@(*)
    begin
        if(rst)
            ct = 4'b0000;
        if(dir)
            nct = (ct == max_val) ? 0 : ct + 1;
        else
            nct = (ct == 0) ? max_val : ct - 1;
    end

    assign upen = (ct == max_val && en && dir) ? 1 : 0;
    assign bken = (ct == 0 && en && ~dir) ? 1 : 0;

endmodule