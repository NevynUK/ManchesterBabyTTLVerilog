//
//  Clock module for the SSEM.
//
//  Parameters:
//      - INPUT_CLOCK_FREQUENCY_MHZ: Frequency of the input clock in MHz (default: 50 MHz).
//      - OUTPUT_CLOCK_FREQUENCY_KHZ: Frequency of the output clock in kHz (default: 1 kHz).
//
//  Inputs:
//      - clk_in: Input clock signal.
//      - stop: Stop signal to halt the clock output.
//      - single_step: Single step signal to advance the clock by one cycle when stopped.
//      - single_stepping: Indicates if the clock is in single stepping mode (1) or free running (0).
//
//  Outputs:
//      - clk_out: Output clock signal.
//      - microcode_clock: Microcode clock signal (10 * clk_out).
//
module clock
#(
    parameter INPUT_CLOCK_FREQUENCY_MHZ = 50,       // Input clock frequency in MHz
    parameter OUTPUT_CLOCK_FREQUENCY_KHZ = 1        // Output clock frequency in kHz
)
(
    input wire clk_in,              // Input clock signal
    input wire stop,                // Stop signal to halt the clock output
    input wire single_step,         // Single step signal (pulse to advance one cycle)
    input wire single_stepping,     // Single stepping mode (1=single step, 0=free running)
    output reg clk_out,             // Output clock signal
    output reg microcode_clock      // Microcode clock signal (10x clk_out)
);
    //
    //  Calculate the divider value for the output clock
    //  Divider = (INPUT_FREQ_MHZ * 1000) / OUTPUT_FREQ_KHZ
    //
    localparam integer DIVIDER = (INPUT_CLOCK_FREQUENCY_MHZ * 1000) / OUTPUT_CLOCK_FREQUENCY_KHZ;
    localparam integer HALF_DIVIDER = DIVIDER / 2;
    
    //
    //  Calculate the divider for microcode clock (10x faster than clk_out)
    //
    localparam integer MICRO_DIVIDER = DIVIDER / 10;
    localparam integer HALF_MICRO_DIVIDER = MICRO_DIVIDER / 2;
    
    //
    //  Counter for clock division
    //
    reg [31:0] counter;
    reg [31:0] micro_counter;
    
    //
    //  Single step edge detection
    //
    reg single_step_prev;
    wire single_step_edge;
    assign single_step_edge = single_step && !single_step_prev;
    
    //
    //  Initialize outputs
    //
    initial
    begin
        clk_out = 1'b0;
        microcode_clock = 1'b0;
        counter = 0;
        micro_counter = 0;
        single_step_prev = 1'b0;
    end
    
    //
    //  Main clock generation logic
    //
    always @(posedge clk_in)
    begin
        //
        //  Edge detection for single step
        //
        single_step_prev <= single_step;
        
        //
        //  Generate microcode clock (always running, 10x faster than clk_out)
        //
        if (micro_counter >= HALF_MICRO_DIVIDER - 1)
        begin
            micro_counter <= 0;
            microcode_clock <= ~microcode_clock;
        end
        else
        begin
            micro_counter <= micro_counter + 1;
        end
        
        //
        //  Generate main clock output based on mode
        //
        if (stop)
        begin
            //
            //  Stopped - always hold clock low when stop signal is high
            //
            clk_out <= 1'b0;
            counter <= 0;
        end
        else if (!stop && single_stepping && single_step_edge)
        begin
            //
            //  Single step mode - generate one clock pulse
            //
            clk_out <= 1'b1;
            counter <= 0;
            //  The pulse will be cleared on next clock when single_step_edge is low
        end
        else if (!stop && single_stepping && !single_step_edge && clk_out)
        begin
            //
            //  Clear the single step pulse after one cycle
            //
            clk_out <= 1'b0;
            counter <= 0;
        end
        else if (!stop && !single_stepping)
        begin
            //
            //  Free running mode - generate divided clock
            //
            if (counter >= HALF_DIVIDER - 1)
            begin
                counter <= 0;
                clk_out <= ~clk_out;
            end
            else
            begin
                counter <= counter + 1;
            end
        end
    end

endmodule
