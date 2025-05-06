module clock_divider_1ms(
    input clk,
    input reset,
    input TimeSet,
    output reg tick_1ms
);
    reg [16:0] count;

    parameter CLK_FREQ = 100_000_000;
    localparam COUNT_MAX_NORMAL = CLK_FREQ / 1000 - 1; // Normal 1ms tick
    localparam COUNT_MAX_TIMESET = 999; // Faster tick for TimeSet (e.g., ~10us at 100MHz)

    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            count <= 0;
            tick_1ms <= 0;
        end
        else
        begin
            if (TimeSet)
            begin
                if (count >= COUNT_MAX_TIMESET)
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
            else
            begin
                if (count >= COUNT_MAX_NORMAL)
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
    end
endmodule
