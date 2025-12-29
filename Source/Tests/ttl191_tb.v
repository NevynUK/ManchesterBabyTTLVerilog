//
//  Test the implementation of the 74LS191 synchronous up/down counter.
//
`timescale 1 ns / 10 ps

module ttl191_tb();
    reg [3:0] D;            //  Parallel data input.
    reg CLK;                //  Clock signal.
    reg LOAD_n;             //  Load control (active low).
    reg CTEN_n;             //  Count enable (active low).
    reg DOWN_UP_n;          //  Direction: 0=up, 1=down.
    wire [3:0] Q;           //  Counter output.
    wire RCO_n;             //  Ripple clock output (active low).
    
    //  Derive terminal count locally for testing
    wire max_min = (DOWN_UP_n == 1'b0) ? (Q == 4'b1111) : (Q == 4'b0000);

    //
    //  Instantiate the ttl191_counter module using the default propagation delay.
    //
    ttl191_counter uut (
        .D(D),
        .CLK(CLK),
        .LOAD_n(LOAD_n),
        .CTEN_n(CTEN_n),
        .DOWN_UP_n(DOWN_UP_n),
        .Q(Q),
        .RCO_n(RCO_n)
    );

    localparam PROPAGATION_DELAY = 50;      //  Delay to allow for propagation with some overhead.
    localparam CLOCK_PERIOD = 100;          //  Clock period for testing.

    //
    //  Clock generator.
    //
    initial
    begin
        CLK = 1'b0;
        forever #(CLOCK_PERIOD / 2) CLK = ~CLK;
    end

    initial
    begin
        $dumpvars(0, ttl191_tb);
    end

    initial
    begin
        //
        //  Setup the initial conditions.
        //
        D = 4'b0000;
        LOAD_n = 1'b1;              //  Load disabled.
        CTEN_n = 1'b1;              //  Count disabled.
        DOWN_UP_n = 1'b0;           //  Direction: count up.
        #PROPAGATION_DELAY;

        //
        //  Test 1: Parallel load operation.
        //
        D = 4'b0101;                //  Load value 5.
        LOAD_n = 1'b0;              //  Enable load.
        @(posedge CLK);
        LOAD_n = 1'b1;              //  Disable load.
        #PROPAGATION_DELAY;
        if (Q !== 4'b0101)
        begin
            $display("ERROR: Test 1 - Parallel load failed. Expected Q=0101, got Q=%b", Q);
        end

        //
        //  Test 2: Count up from loaded value (5 -> 6 -> 7 -> 8 -> 9 -> 10).
        //
        CTEN_n = 1'b0;              //  Enable counting.
        DOWN_UP_n = 1'b0;           //  Count up.
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0110)
        begin
            $display("ERROR: Test 2 - Count up step 1 failed. Expected Q=0110, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0111)
        begin
            $display("ERROR: Test 2 - Count up step 2 failed. Expected Q=0111, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1000)
        begin
            $display("ERROR: Test 2 - Count up step 3 failed. Expected Q=1000, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1001)
        begin
            $display("ERROR: Test 2 - Count up step 4 failed. Expected Q=1001, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1010)
        begin
            $display("ERROR: Test 2 - Count up step 5 failed. Expected Q=1010, got Q=%b", Q);
        end

        //
        //  Test 3: Count up to terminal count (15).
        //
        D = 4'b1101;                //  Load value 13.
        LOAD_n = 1'b0;              //  Enable load.
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1101)
        begin
            $display("ERROR: Test 3 - Load failed. Expected Q=1101, got Q=%b", Q);
        end
        LOAD_n = 1'b1;              //  Disable load.
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1110 || max_min !== 1'b0 || RCO_n !== 1'b1)
        begin
            $display("ERROR: Test 3 - Count to 14 failed. Expected Q=1110, max_min=0, RCO_n=1, got Q=%b, max_min=%b, RCO_n=%b", Q, max_min, RCO_n);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1111 || max_min !== 1'b1 || RCO_n !== 1'b0)
        begin
            $display("ERROR: Test 3 - Terminal count 15 failed. Expected Q=1111, max_min=1, RCO_n=0, got Q=%b, max_min=%b, RCO_n=%b", Q, max_min, RCO_n);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0000)
        begin
            $display("ERROR: Test 3 - Rollover failed. Expected Q=0000, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0001)
        begin
            $display("ERROR: Test 3 - Count after rollover failed. Expected Q=0001, got Q=%b", Q);
        end

        //
        //  Test 4: Count down from loaded value (5 -> 4 -> 3 -> 2 -> 1 -> 0).
        //
        D = 4'b0101;                //  Load value 5.
        LOAD_n = 1'b0;              //  Enable load.
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0101)
        begin
            $display("ERROR: Test 4 - Load failed. Expected Q=0101, got Q=%b", Q);
        end
        LOAD_n = 1'b1;              //  Disable load.
        DOWN_UP_n = 1'b1;           //  Count down.
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0100)
        begin
            $display("ERROR: Test 4 - Count down step 1 failed. Expected Q=0100, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0011)
        begin
            $display("ERROR: Test 4 - Count down step 2 failed. Expected Q=0011, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0010)
        begin
            $display("ERROR: Test 4 - Count down step 3 failed. Expected Q=0010, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0001)
        begin
            $display("ERROR: Test 4 - Count down step 4 failed. Expected Q=0001, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0000)
        begin
            $display("ERROR: Test 4 - Count down step 5 failed. Expected Q=0000, got Q=%b", Q);
        end

        //
        //  Test 5: Count down to terminal count (0).
        //
        D = 4'b0010;                //  Load value 2.
        LOAD_n = 1'b0;              //  Enable load.
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0010)
        begin
            $display("ERROR: Test 5 - Load failed. Expected Q=0010, got Q=%b", Q);
        end
        LOAD_n = 1'b1;              //  Disable load.
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0001 || max_min !== 1'b0 || RCO_n !== 1'b1)
        begin
            $display("ERROR: Test 5 - Count to 1 failed. Expected Q=0001, max_min=0, RCO_n=1, got Q=%b, max_min=%b, RCO_n=%b", Q, max_min, RCO_n);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b0000 || max_min !== 1'b1 || RCO_n !== 1'b0)
        begin
            $display("ERROR: Test 5 - Terminal count 0 failed. Expected Q=0000, max_min=1, RCO_n=0, got Q=%b, max_min=%b, RCO_n=%b", Q, max_min, RCO_n);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1111)
        begin
            $display("ERROR: Test 5 - Underflow failed. Expected Q=1111, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1110)
        begin
            $display("ERROR: Test 5 - Count after underflow failed. Expected Q=1110, got Q=%b", Q);
        end

        //
        //  Test 6: Hold count (CTEN_n = 1).
        //
        D = 4'b1000;                //  Load value 8.
        LOAD_n = 1'b0;              //  Enable load.
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1000)
        begin
            $display("ERROR: Test 6 - Load failed. Expected Q=1000, got Q=%b", Q);
        end
        LOAD_n = 1'b1;              //  Disable load.
        CTEN_n = 1'b1;              //  Disable counting.
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1000)
        begin
            $display("ERROR: Test 6 - Hold step 1 failed. Expected Q=1000, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1000)
        begin
            $display("ERROR: Test 6 - Hold step 2 failed. Expected Q=1000, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1000)
        begin
            $display("ERROR: Test 6 - Hold step 3 failed. Expected Q=1000, got Q=%b", Q);
        end

        //
        //  Test 7: Resume counting.
        //
        CTEN_n = 1'b0;              //  Enable counting.
        DOWN_UP_n = 1'b0;           //  Count up.
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1001)
        begin
            $display("ERROR: Test 7 - Resume count step 1 failed. Expected Q=1001, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1010)
        begin
            $display("ERROR: Test 7 - Resume count step 2 failed. Expected Q=1010, got Q=%b", Q);
        end
        
        @(posedge CLK);
        #PROPAGATION_DELAY;
        if (Q !== 4'b1011)
        begin
            $display("ERROR: Test 7 - Resume count step 3 failed. Expected Q=1011, got Q=%b", Q);
        end

        #(CLOCK_PERIOD * 2);
        $display("74LS191 - End of Simulation.");
        $finish;
    end

endmodule
