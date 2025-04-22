module stopwatch_top(
    input rst, clk, dir, clr, start, stop,
    output [3:0] minutes, 
    output [3:0] seconds_msd, 
    output [3:0] seconds_lsd, 
    output [3:0] ms_msd 
);
    wire tick_1ms;
    wire bken1, bken2, bken3, bken4;
    wire upen1, upen2, upen3, upen4;
    wire msden1_reg, msden2_reg, msden3_reg;

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

    wire start_press = start_sync[0] & ~start_sync[1];
    wire stop_press = stop_sync[0] & ~stop_sync[1];

    reg run;
    always @ (posedge clk or posedge rst or posedge clr)
    begin
        if(rst || clr)
        begin
            run <= 1'b0;
        end
        else if(start_press)
        begin
            run <= 1'b1;
        end
        else if(stop_press)
        begin
            run <= 1'b0;
        end
    end

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
        .max_val(4'd9)
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
        .max_val(4'd9)
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
        .max_val(4'd5)
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
        .max_val(4'd9)
    );

    assign msden1_reg = run && (bken1 || upen1);
    assign msden2_reg = run && (bken2 || upen2);
    assign msden3_reg = run && (bken3 || upen3);

    wire at_max = dir && ms_msd == 4'd9 && seconds_lsd == 4'd9 && seconds_msd == 4'd5 && minutes == 4'd9;
    wire at_min = !dir && ms_msd == 4'd0 && seconds_lsd == 4'd0 && seconds_msd == 4'd0 && minutes == 4'd0;

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
    end
    
    assign active_en = run && !(kill || at_max || at_min);
endmodule


        
            

    
