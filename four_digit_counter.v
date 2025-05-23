module stopwatch_top(
    input rst, clk, dir, clr, start, stop, lap, TimeSet, // Similar inputs to the other modules
    output run_catch, start_catch, lap_press_ms_out,
    output [3:0] minutes, // Current minutes
    output [3:0] seconds_msd, // Current seconds most significant digits
    output [3:0] seconds_lsd, // Current seconds least significant digit
    output [3:0] ms_msd, // Current milliseconds
    output [3:0] lap_ct_ms, lap_ctsecondslsd, lap_ct_secondsmsd, lap_ctminutes // Static timer values
);
    
    wire tick_1ms;
    wire bken1, bken2, bken3, bken4; 
    wire upen1, upen2, upen3, upen4; 
    wire msden1_reg, msden2_reg, msden3_reg;
    wire active_en = run && !kill;

    // input synchronization
    reg [1:0] start_sync, stop_sync, lap_sync_ms;
    wire start_press = start_sync[0] & ~start_sync[1];
    wire stop_press = stop_sync[0] & ~stop_sync[1];
    wire lap_press_ms = lap_sync_ms[0] & ~lap_sync_ms[1];

    // New flashing display control
    reg flash;
    always @(posedge clk or posedge rst or posedge clr)
    begin
        if (rst || clr || start_press || stop_press)
        begin
            flash <= 1'b0;
        end
        // Will only flash if !timeset_active, since otherwise it should wrap around
        else if (run && at_min && !dir && !timeset_active)
        begin
            flash <= 1'b1;
        end
    end

    // Run control
    reg run, kill;
    // Register to control the speed of counting for TimeSet mode
    reg [23:0] count_rate;
    always@(posedge clk or posedge rst or posedge clr)
    begin
        if(rst || clr)
        begin
            run <= 1'b0;
            kill <= 1'b0;
        end
        else
        begin
            // Makes the counting happen quicker when setting time and regular when not setting time
            if(timeset_active)
                count_rate <= 24'd99999
            else
                count_rate <= 24'd9999999

            if (start_press)
            begin
                run <= 1'b1;
                kill <= 1'b0;
            end
            else if(stop_press)
            begin
                run <= 1'b0;
            end
        end
    end

    // Kill logic
    wire at_max = dir && ms_msd == 4'd9 && seconds_lsd == 4'd9 && seconds_msd == 4'd5 && minutes == 4'd9;
    wire at_min = !dir && ms_msd == 4'd0 && seconds_lsd == 4'd0 && seconds_msd == 4'd0 && minutes == 4'd0;
    always@(posedge clk or posedge rst or posedge clr)
    begin
        if(rst || clr || start_press || dir != dir_prev)
        begin
            kill <= 1'b0;
        end
        else if(run && (at_max || at_min))
        begin
            kill <= 1'b1;
        end
    end
    
    // Only switch direction when stopped
    // Also only changes to TimeSet mode when stopped
    reg dir_active;
    reg timeset_active;
    always @ (posedge clk)
        // run is 0 when stopped, so this will only allow dir_active to be assigned the value of dir when stopped
        // We can pass dir_active into the counter modules below instead of dir
        if(!run)
            dir_active <= dir;
            timeset_active <= TimeSet;

    // Turns TimeSet mode off anytime the TimeSet switch is turned off
    // If this happens simultaneously while setting the time, the stopwatch will continue counting, but slowed down to regular time
    // If this happens while stopped, the stopwatch will return to the stopped state
    always @ (negedge TimeSet)
        timeset_active <= TimeSet;

    // Previous direction logic
    reg dir_prev;
    always @ (posedge clk or posedge rst)
    begin
        if(rst)
            dir_prev <= dir;
        else if(!run)
            dir_prev <= dir;
    end

    // Start/Stop press synchro
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

    // Lap Synchro
    always @ (posedge clk or posedge rst)
    begin
        if (rst) 
            lap_sync_ms <= 2'b00;
        else
            lap_sync_ms <= {lap_sync_ms[0], lap && dir};
    end

    // Clock Divider instantiation
    clock_divider_1ms div1(
        .clk(clk),
        .reset(rst),
        .tick_1ms(tick_1ms),
        .count_rate(count_rate)
    );
    // Millisecond Counter
    time_counter_1dig ms_counter(
        .en(active_en),
        .rst(rst),
        .clk(tick_1ms),
        .clk100MHz(clk),
        .dir(dir_active),
        .clr(clr),
        .ct(ms_msd),
        .bken(bken1),
        .upen(upen1),
        .max_val(4'd9),
        .lap_ct(lap_ct_ms),
        .lap_press(lap_press_ms)
    );
    // Second Counter
    time_counter_1dig seconds_lsd_counter(
        .en(msden1_reg),
        .rst(rst),
        .clk(tick_1ms),
        .clk100MHz(clk),
        .dir(dir_active),
        .clr(clr),
        .ct(seconds_lsd),
        .bken(bken2),
        .upen(upen2),
        .max_val(4'd9),
        .lap_ct(lap_ctsecondslsd),
        .lap_press(lap_press_ms)
    );
    // 10s Counter
    time_counter_1dig seconds_msd_counter(
        .en(msden2_reg),
        .rst(rst),
        .clk(tick_1ms),
        .clk100MHz(clk),
        .dir(dir_active),
        .clr(clr),
        .ct(seconds_msd),
        .bken(bken3),
        .upen(upen3),
        .max_val(4'd5),
        .lap_ct(lap_ct_secondsmsd),
        .lap_press(lap_press_ms)
    );
    // Minute Counter
    time_counter_1dig minutes_counter(
        .en(msden3_reg),
        .rst(rst),
        .clk(tick_1ms),
        .clk100MHz(clk),
        .dir(dir_active),
        .clr(clr),
        .ct(minutes),
        .bken(bken4),
        .upen(upen4),
        .max_val(4'd9),
        .lap_ct(lap_ctminutes),
        .lap_press(lap_press_ms)
    );

    // Overflow logic
    assign msden1_reg = run && (bken1 || upen1);
    assign msden2_reg = run && (bken2 || upen2);
    assign msden3_reg = run && (bken3 || upen3);
    
    // Outputs to commmunicate with the Display Driver
    assign run_catch = run;
    assign start_catch = start_press;
    // By adding & dir_active, the current values will still be saved every time lap is pressed, but the display
    // will not recognize that lap has been pressed unless the direction is going up
    assign lap_press_ms_out = lap_press_ms & dir_active;

endmodule
