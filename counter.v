module time_counter_1dig(
    input en, clk, clk100MHz, rst, clr, dir, lap_press, // Input ports for the direction
                                            // enable, clock, reset and the lap functionality
    input [3:0] max_val, // Maximum value to control the value the count can reach
    output reg[3:0] ct, lap_ct, // Variables for the running count and the lap-static count
    output bken, upen // Variables to store the overflow
);
    // Register for the next count value
    reg [3:0] nct;

    // Basic always block to reset the values or assign the current state
   always @(posedge clk or posedge clr or posedge rst) 
    begin
        if (rst || clr)
            ct <= 4'b0000;
        else if (en)
            ct <= nct;
    end

    // Always block to control the functionality of the lap
    reg lap_press_prev;
    always @ (posedge clk100MHz or posedge rst)
    begin
        if(rst)
        begin
            lap_ct <= 4'b0000;
            lap_press_prev <= 1'b0;
        end
        else
        begin
            lap_press_prev <= lap_press;
            if (lap_press && !lap_press_prev && dir)
                lap_ct <= ct;
        end
    end
    
    // Combinational logic to assign the next state
    always@(*)
    begin
        if(dir)
            nct = (ct == max_val) ? 0 : ct + 1;
        else
            nct = (ct == 0) ? max_val : ct - 1;
    end

    // This is the overflow output value logic
    assign upen = (ct == max_val && en && dir) ? 1 : 0;
    assign bken = (ct == 0 && en && ~dir) ? 1 : 0;

endmodule
