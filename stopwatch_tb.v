`timescale 1ns / 1ps

module stopwatch_tb;
    // Inputs
    reg rst, clk, dir, clr, start, stop, lap;
    
    // Outputs
    wire [3:0] an;
    wire [6:0] seg;
    
    // Internal signals from stopwatch_top for monitoring
    wire [3:0] minutes, seconds_msd, seconds_lsd, ms_msd;
    wire [3:0] lap_ct_minutes, lap_ct_seconds_msd, lap_ct_seconds_lsd, lap_ct_ms;
    wire start_press, lap_press_ms, run;
    
    // Instantiate the stopwatch module
    stopwatch dut (
        .rst(rst),
        .clk(clk),
        .dir(dir),
        .clr(clr),
        .start(start),
        .stop(stop),
        .lap(lap),
        .an(an),
        .seg(seg)
    );
    
    // Access internal signals from stopwatch_top
    assign minutes = dut.uut.minutes;
    assign seconds_msd = dut.uut.seconds_msd;
    assign seconds_lsd = dut.uut.seconds_lsd;
    assign ms_msd = dut.uut.ms_msd;
    assign lap_ct_minutes = dut.uut.lap_ctminutes;
    assign lap_ct_seconds_msd = dut.uut.lap_ct_secondsmsd;
    assign lap_ct_seconds_lsd = dut.uut.lap_ctsecondslsd;
    assign lap_ct_ms = dut.uut.lap_ct_ms;
    assign start_press = dut.uut.start_catch;
    assign lap_press_ms = dut.uut.lap_press_ms_out;
    assign run = dut.uut.run_catch;
    
    // Clock generation: 100MHz (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Function to decode seg to a digit
    function [3:0] decode_seg;
        input [6:0] seg;
        begin
            case (seg)
                7'b000_0001: decode_seg = 4'd0;
                7'b100_1111: decode_seg = 4'd1;
                7'b001_0010: decode_seg = 4'd2;
                7'b000_0110: decode_seg = 4'd3;
                7'b100_1100: decode_seg = 4'd4;
                7'b010_0100: decode_seg = 4'd5;
                7'b010_0000: decode_seg = 4'd6;
                7'b000_1111: decode_seg = 4'd7;
                7'b000_0000: decode_seg = 4'd8;
                7'b000_0100: decode_seg = 4'd9;
                default: decode_seg = 4'd15; // Invalid
            endcase
        end
    endfunction
    
    // Function to decode an to display position
    function [1:0] decode_an;
        input [3:0] an;
        begin
            case (an)
                4'b1110: decode_an = 2'd0; // Rightmost (ms_msd)
                4'b1101: decode_an = 2'd1; // Seconds LSD
                4'b1011: decode_an = 2'd2; // Seconds MSD
                4'b0111: decode_an = 2'd3; // Minutes
                default: decode_an = 2'd0;
            endcase
        end
    endfunction
    
    // Intermediate wires for decoded values
    wire [3:0] decoded_digit;
    wire [1:0] decoded_position;
    assign decoded_digit = decode_seg(seg);
    assign decoded_position = decode_an(an);
    
    // Stimulus and monitoring
    initial begin
        // Initialize inputs
        rst = 0;
        dir = 1; // Count up
        clr = 0;
        start = 0;
        stop = 0;
        lap = 0;
        
        // Reset the stopwatch
        #10 rst = 1;
        #20 rst = 0;
        
        // Monitor current count and display
        $monitor("Time: %0t ns | Count: %d:%d%d.%d | Lap: %d:%d%d.%d | Run: %b | An: %b (Pos: %0d) | Seg: %b (Digit: %0d)",
                 $time,
                 minutes, seconds_msd, seconds_lsd, ms_msd,
                 lap_ct_minutes, lap_ct_seconds_msd, lap_ct_seconds_lsd, lap_ct_ms,
                 run,
                 an, decoded_position,
                 seg, decoded_digit);
        
        // Start the stopwatch
        #100 start = 1;
        #20 start = 0;
        
        // Let it run for ~50ms (should count ~50ms, e.g., 00:00.5)
        #50_000_000;
        
        // Capture lap time
        #100 lap = 1;
        #20 lap = 0;
        
        // Let it run for another ~50ms
        #50_000_000;
        
        // Stop the stopwatch
        #100 stop = 1;
        #20 stop = 0;
        
        // Wait for 20ms
        #20_000_000;
        
        // Change direction to count down
        #100 dir = 0;
        
        // Start again
        #100 start = 1;
        #20 start = 0;
        
        // Run for ~50ms (should count down)
        #50_000_000;
        
        // Clear the stopwatch
        #100 clr = 1;
        #20 clr = 0;
        
        // Wait for 20ms
        #20_000_000;
        
        // Reset the stopwatch
        #100 rst = 1;
        #20 rst = 0;
        
        // Run for another 20ms
        #20_000_000;
        
        // End simulation
        #100 $finish;
    end
    
    // Dump variables for waveform viewing
    initial begin
        $dumpfile("stopwatch_tb.vcd");
        $dumpvars(0, stopwatch_tb);
    end
endmodule
