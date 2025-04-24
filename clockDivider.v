module clock_divider_1ms(
    input clk,
    input reset,
    output reg tick_1ms
);
    reg [23:0] count;

    parameter CLK_FREQ = 100_000_000;
    localparam COUNT_MAX = CLK_FREQ / 1000 - 1;

    always@(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            count <= 0;
            tick_1ms <= 0;
        end
        else
        begin
            if(count == 24'd99999)
            begin
                count <= 0;
                tick_1ms <= 1;
            end
            else
            begin
                count <= count + 1;
                tick_1ms <= 0;
            end
        end
    end
endmodule
