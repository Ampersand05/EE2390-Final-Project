module stopwatch(
    input rst, clk, dir, clr, start, stop, lap, // Our basic outputs from the design specs
    output [3:0] an, // This is the anode signal driver from the multiplexer
    output[6:0] seg // This is our output segment that is in sync with the anode select
);
    // These are our wires to connect the outputs from the counters
    wire [3:0] mins, secs_lsd, secs_msd, ms;
    wire [3:0] lap_ct_minutes, lap_ct_seconds_lsd, lap_ct_seconds_msd, lap_ct_ms;
    wire [3:0] segNum; // These are used to transfrom the output from the mux into a 
                                // raw output signal
    wire [6:0] seg_out;

    wire start_press; // This is a wire used to connect the stopwatch and the mux

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
        .run_catch(run)
    );

    // Initializng the multiplexer
    mux m(
        .A(mins),
        .B(secs_msd),
        .C(secs_lsd),
        .D(ms),
        .E(lap_ct_minutes),
        .F(lap_ct_seconds_msd),
        .G(lap_ct_seconds_lsd),
        .H(lap_ct_ms),
        .clk(clk),
        .segmentNum(segNum),
        .an(an),
        .lap(lap),
        .start_press(start_press),
        .rst(rst),
        .run(run)
    );

    // Initializing the decoder connected to the multiplexer
    sevenseghexdecoder segOut(
        .BinVal(segNum),
        .seg(seg_out)
    );
    
    // Turning our segment output into a raw output
    assign seg = seg_out;
   
endmodule
