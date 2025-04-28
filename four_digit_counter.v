module stopwatch_top(
    input rst, clk, dir, clr, start, stop, lap, // Similar inputs to the other modules
    output run_catch, start_catch, lap_press_ms_out,
    output [3:0] minutes, // Current minutes
    output [3:0] seconds_msd, // Current seconds most significant digits
    output [3:0] seconds_lsd, // Current seconds least significant digit
    output [3:0] ms_msd, // Current milliseconds
    output [3:0] lap_ct_ms, lap_ctsecondslsd, lap_ct_secondsmsd, lap_ctminutes // Static timer values
);
    // Giant block of wires
    wire tick_1ms; // Wire to connect the clock divider
    wire bken1, bken2, bken3, bken4; // Wire to connect the backwards overflow
    wire upen1, upen2, upen3, upen4; // Wire to connect the upwards overflow
    wire msden1_reg, msden2_reg, msden3_reg; // Wire to connect the back/up overflow logic

    // This is a synchronizer to store the stop/start button presses
    // Reference the synchronizer in the mux to see how it works
    reg [1:0] start_sync, stop_sync;
    always @ (posedge clk or posedge rst)
    begin
        if (rst)
        begin
            start_sync <= 2'b00;
            stop_sync <= 2'b00;
        end
        else
        begin
            start_sync <= {start_sync[0], start};
            stop_sync <= {stop_sync[0], stop};
        end
    end

    // Stores the start/stop button press
    wire start_press = start_sync[0] & ~start_sync[1];
    wire stop_press = stop_sync[0] & ~stop_sync[1];

    // This always block determines whether to run the counters or not
    reg run;
    always @ (posedge clk or posedge rst or posedge clr)
    begin
        // If rst or clr is pressed it stops the counters
        if(rst || clr)
        begin
            run <= 1'b0;
        end
        // If the start is pressed it begins the counters
        else if(start_press)
        begin
            run <= 1'b1;
        end
        // If stop is pressed it stops the counters
        else if(stop_press)
        begin
            run <= 1'b0;
        end
    end

    assign run_catch = run;
    assign start_catch = start_press;

    // This is the same synchronizer from the mux
    reg [1:0] lap_sync_ms;
    wire lap_press_ms;
    always @ (posedge clk or posedge rst)
    begin
        if (rst) 
            lap_sync_ms <= 2'b00;
        else
            lap_sync_ms <= {lap_sync_ms[0], lap};
    end

    // Same logic from the mux
    assign lap_press_ms = lap_sync_ms[0] & ~lap_sync_ms[1];
    assign lap_press_ms_out = lap_press_ms;

    wire start_repress = run & start_press;

    // This is extremely long declaration of all our counters and
    // the clock divider
    clock_divider_1ms div1(
        .clk(clk),
        .reset(rst),
        .tick_1ms(tick_1ms)
    );

    time_counter_1dig ms_counter(
        .en(active_en),
        .rst(rst),
        .clk(tick_1ms),
        .dir(dir),
        .clr(clr),
        .ct(ms_msd),
        .bken(bken1),
        .upen(upen1),
        .max_val(4'd9),
        .lap_ct(lap_ct_ms),
        .lap_press(lap_press_ms)
    );
    time_counter_1dig seconds_lsd_counter(
        .en(msden1_reg),
        .rst(rst),
        .clk(tick_1ms),
        .dir(dir),
        .clr(clr),
        .ct(seconds_lsd),
        .bken(bken2),
        .upen(upen2),
        .max_val(4'd9),
        .lap_ct(lap_ctsecondslsd),
        .lap_press(lap_press_ms)
    );
    time_counter_1dig seconds_msd_counter(
        .en(msden2_reg),
        .rst(rst),
        .clk(tick_1ms),
        .dir(dir),
        .clr(clr),
        .ct(seconds_msd),
        .bken(bken3),
        .upen(upen3),
        .max_val(4'd5),
        .lap_ct(lap_ct_secondsmsd),
        .lap_press(lap_press_ms)
    );
    time_counter_1dig minutes_counter(
        .en(msden3_reg),
        .rst(rst),
        .clk(tick_1ms),
        .dir(dir),
        .clr(clr),
        .ct(minutes),
        .bken(bken4),
        .upen(upen4),
        .max_val(4'd9),
        .lap_ct(lap_ctminutes),
        .lap_press(lap_press_ms)
    );

    // This is our overflow logic
    // It just checks if the counters are running and whether there is an overflow
    assign msden1_reg = run && (bken1 || upen1);
    assign msden2_reg = run && (bken2 || upen2);
    assign msden3_reg = run && (bken3 || upen3);

    // This is logic to determine whether or not the counters are at their minimum or maximum values
    wire at_max = dir && ms_msd == 4'd9 && seconds_lsd == 4'd9 && seconds_msd == 4'd5 && minutes == 4'd9;
    wire at_min = !dir && ms_msd == 4'd0 && seconds_lsd == 4'd0 && seconds_msd == 4'd0 && minutes == 4'd0;

    // This block determines whether or not to kill the counters
    // basically activates when all the counters reach their max/min values
    wire active_en;
    reg kill;
    always@(posedge tick_1ms or posedge rst or posedge clr)
    begin
        if(rst || clr)
        begin
            kill <= 1'b0;
        end
        else if(run && (at_max || at_min))
        begin
            kill <= 1'b1;
        end
        else if(start_press)
        begin
            kill <= 1'b0;
        end
    end
    
    // This is our active enable signal, it trickles down starting at the
    // first counter, deactivates immediately when it hits the max or min or the kill activates
    // and if it is running
    assign active_en = run && !kill;
endmodule



        
            

    
