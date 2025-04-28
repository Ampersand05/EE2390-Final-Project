// Multifunctional multiplexer for the stopwatch
module mux(
    input [3:0] A, B, C, D, // Inputs for the current counter state ie. the running time
    input [3:0] E, F, G, H, // Inputs for the captured lap time
    input clk, rst, start_press, run, lap_press, // Inputs for the clock, reset, lap button press, and the start press
    output reg [3:0] segmentNum, // This output is for the binary value to go into the hex decoder
    output reg [3:0] an // This is the value of the display to be turned on
);
    // This register is designed to hold 16 bits, we need this to slow down
    // the refresh rate of the seven segment display so that the numbers are
    // visible
    reg [15:0] divider;

    reg [1:0] digit_select; // This will be incremented synchronously with the refresh 
                            // rate to decide which digit to display

    wire start_repress = run && start_press; // This just checks if the start button is 
                                            // pressed again while the clock is running

    always @ (posedge clk or posedge rst)
    begin
        // Asynchronous reset
        if(rst)
        begin
            divider <= 16'b0;
            digit_select <= 2'b00;
        end
        else
        // This essentially increments the clock pulses into 1KHz clock
        // pulses
        begin
            divider <= divider + 1;
            if(divider == 0)
                digit_select <= digit_select + 1;
        end
    end

    reg lap_active;
    always @ (posedge clk or posedge rst)
    begin
        if (rst)
            lap_active <= 1'b0;
        else if (lap_press)
            lap_active <= 1'b1;
        else if (start_repress)
            lap_active <= 1'b0;
    end

    always @ (posedge clk)
    begin
        // Check if lap_press is high, and the start has not been repressed
        if(lap_active && !start_repress)
            // Display and hold the current time
            begin
                case(digit_select)
                    2'b00: begin an <= 4'b1110; segmentNum <= H; end
                    2'b01: begin an <= 4'b1101; segmentNum <= G; end
                    2'b10: begin an <= 4'b1011; segmentNum <= F; end
                    2'b11: begin an <= 4'b0111; segmentNum <= E; end
                endcase
            end
        else
        // If lap has not been pressed or start has been repressed, display
        // the running time.
            begin
                case(digit_select)
                    2'b00: begin an <= 4'b1110; segmentNum <= D; end
                    2'b01: begin an <= 4'b1101; segmentNum <= C; end
                    2'b10: begin an <= 4'b1011; segmentNum <= B; end
                    2'b11: begin an <= 4'b0111; segmentNum <= A; end
                endcase
            end
    end
endmodule
