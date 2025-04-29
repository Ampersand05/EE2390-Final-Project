// Multifunctional multiplexer for the stopwatch
module displayDriver(
    input [3:0] A, B, C, D, // Inputs for the current counter state ie. the running time
    input [3:0] E, F, G, H, // Inputs for the captured lap time
    input clk, rst, start_press, run, lap_press, // Inputs for the clock, reset, lap button press, and the start press
    output reg [3:0] an, // This is the value of the display to be turned on
    output reg [6:0] seg
);
    reg [3:0] segmentNum;
    reg [15:0] divider;
    reg [1:0] digit_select;
    reg lap_active; 

    wire start_repress = run && start_press;

    // Clock divider to control the refresh rate
    always @ (posedge clk or posedge rst)
    begin
        if(rst)
        begin
            divider <= 16'b0;
            digit_select <= 2'b00;
        end
        else
        begin
            divider <= divider + 1;
            if(divider == 0)
                digit_select <= digit_select + 1;
        end
    end

    // Lap control logic
    always @ (posedge clk or posedge rst)
    begin
        if (rst)
            lap_active <= 1'b0;
        else if (lap_press)
            lap_active <= 1'b1;
        else if (start_repress)
            lap_active <= 1'b0;
    end

    // Anode and digit select controller
    always @ (posedge clk)
    begin
        if(lap_active && !start_repress)
            begin
                case(digit_select)
                    2'b00: begin an <= 4'b1110; segmentNum <= H; end
                    2'b01: begin an <= 4'b1101; segmentNum <= G; end
                    2'b10: begin an <= 4'b1011; segmentNum <= F; end
                    2'b11: begin an <= 4'b0111; segmentNum <= E; end
                endcase
            end
        else
            begin
                case(digit_select)
                    2'b00: begin an <= 4'b1110; segmentNum <= D; end
                    2'b01: begin an <= 4'b1101; segmentNum <= C; end
                    2'b10: begin an <= 4'b1011; segmentNum <= B; end
                    2'b11: begin an <= 4'b0111; segmentNum <= A; end
                endcase
            end
    end

    // Decoder merged with the multiplexer to help with synchronization issues
    always @(segmentNum)
    begin
        case(segmentNum)
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

