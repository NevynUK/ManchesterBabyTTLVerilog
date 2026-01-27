//
//  Testbench for the clock module.
//
`timescale 1 ns / 10 ps

`include "Components/macros.v"

module clock_tb();
    //
    //  Test parameters - using faster clocks for simulation
    //
    localparam INPUT_FREQ = 10;         //  10 MHz input clock for faster simulation
    localparam OUTPUT_FREQ = 100;       //  100 kHz output clock
    localparam INPUT_PERIOD = 100;      //  100 ns period for 10 MHz
    
    //
    //  Testbench signals
    //
    reg clk_in;
    reg stop;
    reg single_step;
    reg single_stepping;
    wire clk_out;
    wire microcode_clock;
    
    //
    //  Instantiate the clock module
    //
    clock #(
        .INPUT_CLOCK_FREQUENCY_MHZ(INPUT_FREQ),
        .OUTPUT_CLOCK_FREQUENCY_KHZ(OUTPUT_FREQ)
    ) uut (
        .clk_in(clk_in),
        .stop(stop),
        .single_step(single_step),
        .single_stepping(single_stepping),
        .clk_out(clk_out),
        .microcode_clock(microcode_clock)
    );
    
    //
    //  Generate input clock (10 MHz)
    //
    initial
    begin
        clk_in = 1'b0;
        forever #(INPUT_PERIOD / 2) clk_in = ~clk_in;
    end
    
    //
    //  VCD dump for waveform viewing
    //
    initial
    begin
        $dumpvars(0, clock_tb);
    end
    
    //
    //  Test stimulus
    //
    initial
    begin
        //
        //  Initialize signals
        //
        stop = 1'b0;
        single_step = 1'b0;
        single_stepping = 1'b0;
        
        $display("Clock Module Test Starting...");
        $display("    Input frequency: %0d MHz", INPUT_FREQ);
        $display("    Output frequency: %0d kHz", OUTPUT_FREQ);
        $display("    Expected divider: %0d", (INPUT_FREQ * 1000) / OUTPUT_FREQ);
        
        //
        //  Test 1: Free running mode
        //
        stop = 1'b0;
        single_stepping = 1'b0;
        #50000;  // Wait for several output clock cycles
        
        //
        //  Test 2: Stop the clock
        //
        stop = 1'b1;
        #10000;
        `ABORT_IF(clk_out !== 1'b0, "Test 2: Clock should be stopped and low")
        
        //
        //  Test 3: Single step mode - one step
        //
        stop = 1'b0;  // Stop must be low for single stepping to work
        single_stepping = 1'b1;
        #1000;
        
        //  Generate single step pulse
        single_step = 1'b1;
        #200;
        single_step = 1'b0;
        #500;
        
        `ABORT_IF(clk_out !== 1'b0, "Test 3: Clock should be stopped and low")
        
        //
        //  Test 4: Verify single step does not work when stop is high
        //
        stop = 1'b1;  // Stop signal high should prevent single stepping
        single_stepping = 1'b1;
        #1000;
        
        //  Try to generate single step pulse (should not work)
        single_step = 1'b1;
        #200;
        single_step = 1'b0;
        #500;
        
        `ABORT_IF(clk_out !== 1'b0, "Test 4: Clock should remain stopped when stop signal is high")
        
        //
        //  Test 5: Multiple single steps
        //
        stop = 1'b0;  // Clear stop for single stepping
        repeat (3)
        begin
            #500;
            single_step = 1'b1;
            #200;
            single_step = 1'b0;
            #500;
        end
        
        //
        //  Test 6: Resume free running
        //
        stop = 1'b0;
        single_stepping = 1'b0;
        #50000;
                
        //
        //  Test 7: Stop and start transitions
        //
        stop = 1'b1;
        #5000;
        stop = 1'b0;
        #10000;
        stop = 1'b1;
        #5000;
        stop = 1'b0;
        #10000;
        
        $display("All tests completed!");
        $display("Check waveforms to verify:");
        $display("  - Output clock frequency is correct");
        $display("  - Microcode clock is 10x faster");
        $display("  - Stop signal halts output clock");
        $display("  - Single step generates one pulse");
        
        #5000;
        $finish;
    end
    
    //
    //  Monitor clock transitions for verification
    //
    integer clk_out_count;
    integer micro_clock_count;
    real start_time;
    real end_time;
    
    initial
    begin
        clk_out_count = 0;
        micro_clock_count = 0;
        start_time = $realtime;
    end
    
    //
    //  Count output clock edges
    //
    always @(posedge clk_out)
    begin
        clk_out_count = clk_out_count + 1;
    end
    
    //
    //  Count microcode clock edges
    //
    always @(posedge microcode_clock)
    begin
        micro_clock_count = micro_clock_count + 1;
    end
    
    //
    //  Periodic statistics
    //
    initial
    begin
        #200000;
        end_time = $realtime;
        $display("Statistics after 200us:");
        $display("  clk_out edges: %0d", clk_out_count);
        $display("  microcode_clock edges: %0d", micro_clock_count);
        $display("  Ratio (should be ~10): %0.2f", real'(micro_clock_count) / real'(clk_out_count));
    end

endmodule
