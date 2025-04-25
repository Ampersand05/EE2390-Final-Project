// Multifunctional multiplexer for the stopwatch
module mux(
    input [3:0] A, B, C, D, // Inputs for the current counter state ie. the running time
    input [3:0] E, F, G, H, // Inputs for the captured lap time
    input clk, rst, lap, start_press, run, // Inputs for the clock, reset, lap button press, and the start press
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

    reg [1:0] lap_sync; // This is a register to store if the lap button is pressed
    always @ (posedge clk or posedge rst)
    begin
        if (rst) // Asynchronous master reset
            lap_sync <= 2'b00;
        else
            lap_sync <= {lap_sync[0], lap}; // This is a shift register to store
                                            // if lap is pressed
    end

    wire lap_press = lap_sync[0] & ~lap_sync[1]; // This just holds the value if lap_sync is one or zero

    always @ (posedge clk or posedge rst)
    begin
        // Asynchronous reset
        if(rst)
        begin
            divider <= 16'b0;
            dig_select <= 2'b00;
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

    always @ (posedge clk)
    begin
        // Check if lap_press is high, and the start has not been repressed
        if(lap_press && !start_repress)
            // Display and hold the current time
            begin
                case(digit_select)
                    2'b00: an <= 4'b1110; segmentNum <= H;
                    2'b01: an <= 4'b1101; segmentNum <= G;
                    2'b10: an <= 4'b1011; segmentNum <= F;
                    2'b11: an <= 4'b0111; segmentNum <= E;
                endcase
            end
        else
        // If lap has not been pressed or start has been repressed, display
        // the running time.
            begin
                case(digit_select)
                    2'b00: an <= 4'b1110; segmentNum <= D;
                    2'b01: an <= 4'b1101; segmentNum <= C;
                    2'b10: an <= 4'b1011; segmentNum <= B;
                    2'b11: an <= 4'b0111; segmentNum <= A;
                endcase
            end
    end
endmodule
