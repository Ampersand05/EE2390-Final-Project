module stopwatch(
    input rst, clk, dir, clr, start, stop,
    output min_seg, sec_lsd_seg, sec_msd_seg, ms_seg
);

    wire mins, secs_lsd, secs_msd, ms;
    wire seg1, seg2, seg3, seg4;

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
        .ms_msd(ms)
    );

    mux m(
        .A(mins),
        .B(secs_msd),
        .C(secs_lsd),
        .D(ms),
        .clk(clk),
        .segmentNum(segNum),
        .an(an)
    );

    sevenseghexdecoder segOut(
        .BinVal(segNum),
        .seg(seg_out)
    );
endmodule
