module stopwatch_top_tb;

    // Inputs
    reg rst, start, stop, clk, dir, clr;

    // Outputs
    wire [3:0] minutes;
    wire [3:0] seconds_msd;
    wire [3:0] seconds_lsd;
    wire [3:0] ms_msd;

    // Instantiate the Unit Under Test (UUT)
    stopwatch_top uut (
        .rst(rst),
        .start(start),
        .stop(stop),
        .clk(clk),
        .dir(dir),
        .clr(clr),
        .minutes(minutes),
        .seconds_msd(seconds_msd),
        .seconds_lsd(seconds_lsd),
        .ms_msd(ms_msd)
    );

    // Clock generation (100 MHz, 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, stopwatch_top_tb);
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 0;
        start = 0;
        stop = 0;
        dir = 1; // Count up
        clr = 0;

        // Reset the stopwatch
        #10;
        rst = 1;
        #10;
        rst = 0;

        // Test case 1: Press start to begin counting up
        start = 1;
        #10;
        start = 0;
        #500000; // Count for 1 second (1,000,000 ns = 1s)

        // Test case 2: Press stop to pause
        stop = 1;
        #10;
        stop = 0;
        #1000000; // Wait 1s to ensure no counting

        // Test case 3: Press start again to resume
        start = 1;
        #10;
        start = 0;
        #1000000; // Count for 1s

        // Test case 4: Count up to max (9:59.9)
        #5989000; // +598.9s to reach 9:59.9 (total 599.9s)
        #1000000; // Wait to ensure it freezes at 9:59.9

        // Test case 5: Clear and test counting down
        clr = 1;
        #10;
        clr = 0;
        dir = 0; // Count down
        start = 1;
        #10;
        start = 0;
        #1000000; // Count down for 1s

        // Test case 6: Stop and resume
        stop = 1;
        #10;
        stop = 0;
        #1000000; // Wait to ensure no counting
        start = 1;
        #10;
        start = 0;
        #1000000; // Count down for 1s

        // Test case 7: Reset during counting
        start = 1;
        #10;
        start = 0;
        #500000;
        rst = 1;
        #10;
        rst = 0;

        // End simulation
        #100;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t rst=%b clr=%b start=%b stop=%b dir=%b minutes=%d seconds_msd=%d seconds_lsd=%d ms_msd=%d",
                 $time, rst, clr, start, stop, dir, minutes, seconds_msd, seconds_lsd, ms_msd);
    end

endmodule
