module stopwatch_top(
    input rst, clk, dir, clr, start, stop, lap, TimeSet,
    output run_catch, start_catch, lap_press_ms_out, flash,
    output [3:0] minutes,
    output [3:0] seconds_msd,
    output [3:0] seconds_lsd,
    output [3:0] ms_msd,
    output [3:0] lap_ct_ms, lap_ctsecondslsd, lap_ct_secondsmsd, lap_ctminutes
);
    wire tick_1ms;
    wire bken1, bken2, bken3, bken4;
    wire upen1, upen2, upen3, upen4;
    wire msden1_reg, msden2_reg, msden3_reg;

    // TimeSet mode control
    reg time_set_mode;
    reg [1:0] time_sync;
    wire time_press = time_sync[0] & ~time_sync[1];

    // Input synchronization
    reg [1:0] start_sync, stop_sync, lap_sync_ms;
    wire start_press = start_sync[0] & ~start_sync[1];
    wire stop_press = stop_sync[0] & ~stop_sync[1];
    wire lap_press_ms = lap_sync_ms[0] & ~lap_sync[1];

    // Active enable for counters
    wire active_en = (run || (time_set_mode && start_press)) && !kill;

    // Flashing display control
    reg flash;
    always @(posedge clk or posedge rst or posedge clr)
    begin
        if (rst || clr || start_press || stop_press)
        begin
            flash <= 1'b0;
        end
        else if (run && at_min && !dir)
        begin
            flash <= 1'b1;
        end
        else
            flash <= 1'b0;
    end

    // Run control
    reg run, kill;
    always @(posedge clk or posedge rst or posedge clr)
    begin
        if (rst || clr)
        begin
            run <= 1'b0;
            kill <= 1'b0;
            time_set_mode <= 1'b0;
        end
        else
        begin
            // TimeSet mode toggle
            if (time_press && !time_set_mode)
                time_set_mode <= 1'b1;
            else if (time_press && time_set_mode)
                time_set_mode <= 1'b0;

            // Run logic
            if (time_set_mode)
            begin
                run <= 1'b0; // Normal run disabled in TimeSet mode
            end
            else if (start_press)
            begin
                run <= 1'b1;
                kill <= 1'b0;
            end
            else if (stop_press)
            begin
                run <= 1'b0;
            end
        end
    end

    // Kill logic
    wire at_max = dir && ms_msd == 4'd9 && seconds_lsd == 4'd9 && seconds_msd == 4'd5 && minutes == 4'd9;
    wire at_min = !dir && ms_msd == 4'd0 && seconds_lsd == 4'd0 && seconds_msd == 4'd0 && minutes == 4'd0;
    always @(posedge clk or posedge rst or posedge clr)
    begin
        if (rst || clr || start_press || stop_press || dir != dir_prev)
        begin
            kill <= 1'b0;
        end
        else if ((run || time_set_mode) && (at_max || at_min))
        begin
            kill <= 1'b1;
        end
    end

    // Previous direction logic
    reg dir_prev;
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            dir_prev <= dir;
        else if (!run && !time_set_mode)
            dir_prev <= dir;
    end

    // Start/Stop press synchronization
    always @(posedge clk or posedge rst)
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

    // TimeSet synchronization
    always @(posedge clk or posedge rst or posedge clr)
    begin
        if (rst || clr)
        begin
            time_sync <= 2'b00;
        end
        else
        begin
            time_sync <= {time_sync[0], TimeSet};
        end
    end

    // Lap synchronization
    always @(posedge clk or posedge rst)
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
        .TimeSet(time_set_mode)
    );

    // Millisecond Counter
    time_counter_1dig ms_counter(
        .en(active_en),
        .rst(rst),
        .clk(tick_1ms),
        .clk100MHz(clk),
        .dir(dir),
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
        .dir(dir),
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
        .dir(dir),
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
        .dir(dir),
        .clr(clr),
        .ct(minutes),
        .bken(bken4),
        .upen(upen4),
        .max_val(4'd9),
        .lap_ct(lap_ctminutes),
        .lap_press(lap_press_ms)
    );

    // Overflow logic
    assign msden1_reg = (run || (time_set_mode && start_press)) && (bken1 || upen1);
    assign msden2_reg = (run || (time_set_mode && start_press)) && (bken2 || upen2);
    assign msden3_reg = (run || (time_set_mode && start_press)) && (bken3 || upen3);

    // Outputs to communicate with the Display Driver
    assign run_catch = run;
    assign start_catch = start_press;
    assign lap_press_ms_out = lap_press_ms;

endmodule


        
            

    
