module clock_divider_1ms(
    input clk,
    input reset,
    input [23:0] count_rate,
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
            if(count == count_rate)
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
