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
        LE = 1'b1;                  // Latch the data, Output is disabled and should be High-Z.
        #PROPAGATION_DELAY;
        if (Q !== 8'bzzzzzzz)
        begin
            $error("Error: Test 1a, Output Q did not go High-Z after LE enabled!");
        end
        if (uut.internal_latch !== 8'b10101010)
        begin
            $error("Error: Test 1b, internal latch did not match expected value after LE enabled!");
        end

        LE = 1'b0;                  // Latch the data, should hold value in the latch and Q should be High-Z.
        #PROPAGATION_DELAY;
        if (Q !== 8'bzzzzzzzz)
        begin
            $error("Error: Test 2a, Output Q did not go High-Z after LE disabled!");
        end
        if (uut.internal_latch !== 8'b10101010)
        begin
            $error("Error: Test 2b, internal latch did not hold expected value after LE disabled!");
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
        if (Q !== 8'bzzzzzzzz)
        begin
            $error("Error: Test 4, Q not in high-impedance state after OE_n enabled!");
        end
        if (uut.internal_latch !== 8'b10101010)
        begin
            $error("Error: Test 4b, internal latch did not hold expected value after OE_n enabled!");
        end

        LE = 1'b1;                  // Output is disabled, latching disabled.
        #PROPAGATION_DELAY;
        if (Q !== 8'bzzzzzzzz)
        begin
            $error("Error: Test 5a, Output Q did not go High-Z after LE re-enabled!");
        end
        if (uut.internal_latch !== 8'b11110000)
        begin
            $error("Error: Test 5b, internal latch did not match expected value after LE re-enabled!");
        end

        $display("74LS373 - End of Simulation");
        $finish;
    end

endmodule