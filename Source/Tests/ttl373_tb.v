//
//  Test the implementation of the 74LS373 octal latch with 3-state outputs.
//
`timescale 1 ns / 10 ps

module ttl373_tb();
    reg [7:0] D;
    reg LE;
    reg OE_n;
    wire [7:0] Q;

    //
    //  Instantiate the ttl373_latch module.
    //
    ttl373_latch uut (
        .D(D),
        .LE(LE),
        .OE_n(OE_n),
        .Q(Q)
    );

    localparam PROPAGATION_DELAY = 50;     // Delay to allow for propagation with some overhead.

    initial 
    begin
        $dumpvars(0, ttl373_tb);
    end

    initial 
    begin
        //
        //  Setup the test values.
        //
        D = 8'b00000000;
        LE = 1'b0;
        OE_n = 1'b1;
        #PROPAGATION_DELAY;

        //
        //  Start the tests.
        //
        D = 8'b10101010;
        LE = 1'b1;                  // Enable latch, should follow D.
        #PROPAGATION_DELAY;
        if (Q != D) 
        begin
            $error("Error: Test 1, Q did not match expected value after LE enabled!");
        end

        LE = 1'b0;                  // Disable latch, should hold value.
        #PROPAGATION_DELAY;
        if (Q != 8'b10101010)
        begin
            $error("Error: Test 2, Q did not hold expected value after LE disabled!");
        end

        OE_n = 1'b0;                // Enable output, Q should reflect latched value.

        D = 8'b11110000;            // Change D, should not affect Q.
        #PROPAGATION_DELAY;
        if (Q != 8'b10101010)
        begin
            $error("Error: Test 3, Q changed value when LE was disabled!");
        end

        OE_n = 1'b1;                // Disable output, Q should go high-impedance.
        #PROPAGATION_DELAY;
        if (Q !== 8'bz)
        begin
            $error("Error: Test 4, Q not in high-impedance state after OE_n enabled!");
        end

        LE = 1'b1;                  // Enable latch again, should follow D.
        #PROPAGATION_DELAY;
        if (Q != D)
        begin
            $error("Error: Test 5, Q did not match expected value after LE re-enabled!");
        end

        #PROPAGATION_DELAY;
        OE_n = 1'b0;                // Enable output, Q should reflect new latched value.

        $display("74LS373 - End of Simulation");
        $finish;
    end

endmodule