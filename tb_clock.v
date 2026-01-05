`timescale 1ns / 1ps

module Clock_tb();

    // 1. Signals for UUT
    reg clk;
    reg rst;
    reg start;
    reg stop;
    reg edit;
    reg [5:0] e_sec, e_minute;
    reg [4:0] e_hour;

    wire [5:0] second, minute;
    wire [4:0] hour;
    wire idle_mode, run_mode, edit_mode;

    // 2. Instantiate the Unit Under Test (UUT)
    // Override CLK_FRQ to 10 for fast simulation
    Clock #(.CLK_FRQ(10)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .stop(stop),
        .edit(edit),
        .e_sec(e_sec),
        .e_minute(e_minute),
        .e_hour(e_hour),
        .second(second),
        .minute(minute),
        .hour(hour),
        .idle_mode(idle_mode),
        .run_mode(run_mode),
        .edit_mode(edit_mode)
    );

    // 3. Clock Generation (100MHz -> 10ns period)
    always #5 clk = ~clk;

    // 4. Stimulus Logic
    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        start = 0;
        stop = 0;
        edit = 0;
        e_sec = 0; e_minute = 0; e_hour = 0;

        // Release Reset
        #20 rst = 0;
        
        // --- Test Case 1: Edit Mode ---
        // Set time to 12:59:55 to test the rollover
        #20;
        edit = 1;
        e_hour = 12;
        e_minute = 59;
        e_sec = 55;
        #20;
        edit = 0; // Exit edit to Idle
        
        // --- Test Case 2: Run Mode ---
        #20;
        start = 1;
        #10;
        start = 0;

        // --- Observe Rollover ---
        // Since CLK_FRQ = 10, 1 sec = 100ns. 
        // To see 10 seconds pass, we wait 1000ns.
        #1200; 

        // --- Test Case 3: Stop/Pause Mode ---
        #20;
        stop = 1;
        #20;
        stop = 0;
        
        #200; // Observe that time is frozen
        
        // --- Resume ---
        #20;
        start = 1;
        #20;
        start = 0;

        #500;
        $display("Simulation Finished");
        $stop;
    end

    // 5. Monitor Output
    initial begin
        $monitor("Time: %t | Mode: %s | Clock: %0d:%02d:%02d", 
                 $time, 
                 (run_mode ? "RUN " : (edit_mode ? "EDIT" : "IDLE")), 
                 hour, minute, second);
    end

endmodule