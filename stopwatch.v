module stopwatch(
    input rst, clk, dir, clr, start, stop, lap, // Our basic outputs from the design specs
    output [3:0] an, // This is the anode signal driver from the multiplexer
    output[0:6] seg // This is our output segment that is in sync with the anode select
);
    // These are our wires to connect the outputs from the counters
    wire [3:0] mins, secs_lsd, secs_msd, ms;
    wire [3:0] lap_ct_minutes, lap_ct_seconds_lsd, lap_ct_seconds_msd, lap_ct_ms;
    wire [0:6] seg_out;

    wire start_press, lap_press_ms; // This is a wire used to connect the stopwatch and the mux

    wire run;

    wire flash;
    
    // Initializing the stopwatch top module
    stopwatch_top uut (
        .rst(rst),
        .clk(clk),
        .dir(dir),
        .clr(clr),
        .start(start),
        .stop(stop),
        .minutes(mins),
        .seconds_msd(secs_msd),
        .seconds_lsd(secs_lsd),
        .ms_msd(ms),
        .lap_ctminutes(lap_ct_minutes),
        .lap_ctsecondslsd(lap_ct_seconds_lsd),
        .lap_ct_secondsmsd(lap_ct_seconds_msd),
        .lap_ct_ms(lap_ct_ms),
        .lap(lap),
        .start_catch(start_press),
        .run_catch(run),
        .lap_press_ms_out(lap_press_ms),
        .flash(flash)
    );

    // Initializng the multiplexer
    displayDriver driver(
        .A(mins),
        .B(secs_msd),
        .C(secs_lsd),
        .D(ms),
        .E(lap_ct_minutes),
        .F(lap_ct_seconds_msd),
        .G(lap_ct_seconds_lsd),
        .H(lap_ct_ms),
        .clk(clk),
        .an(an),
        .lap_press(lap_press_ms),
        .start_press(start_press),
        .rst(rst),
        .run(run),
        .seg(seg_out),
        .flash(flash),
        .dir(dir)
    );

    // Turning our segment output into a raw output
    assign seg = seg_out;
   
endmodule
