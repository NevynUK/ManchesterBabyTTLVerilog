//
//  Test the implementation of the register.
//
`timescale 1 ns / 10 ps
`include "Components/macros.v"

module register_tb();
    reg [31:0] A;
    reg LE;
    reg OE_n;
    wire [31:0] Q;

    //
    //  Instantiate the register module.
    //
    register uut (
        .A(A),
        .LE(LE),
        .OE_n(OE_n),
        .Q(Q)
    );

    localparam PROPAGATION_DELAY = 50;      // Delay to allow for propagation with some overhead.

    initial
    begin
        $dumpvars(0, register_tb);
    end

    initial
    begin
        //
        //  Setup the initial conditions.
        //
        A = 32'h00000000;
        LE = 1'b0;
        OE_n = 1'b1;                        // Output disabled initially.
        #PROPAGATION_DELAY;

        //
        //  Test 1: Load a value with LE high and output enabled.
        //
        A = 32'h12345678;
        LE = 1'b1;                          // Enable latch.
        OE_n = 1'b0;                        // Enable output.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h12345678, $sformatf("Test 1: Load value failed. Expected 0x12345678, got 0x%08h", Q))

        //
        //  Test 2: Hold the latched value when LE goes low.
        //
        LE = 1'b0;                          // Disable latch, should hold previous value.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h12345678, $sformatf("Test 2: Hold value failed. Expected 0x12345678, got 0x%08h", Q))

        //
        //  Test 3: Change input while LE is low (should not affect output).
        //
        A = 32'hAAAAAAAA;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h12345678, $sformatf("Test 3: Latch persistence failed. Expected 0x12345678, got 0x%08h", Q))

        //
        //  Test 4: Load new value when LE goes high again.
        //
        LE = 1'b1;                          // Enable latch again.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hAAAAAAAA, $sformatf("Test 4: Load new value failed. Expected 0xAAAAAAAA, got 0x%08h", Q))

        //
        //  Test 5: Output disable (High-Z state).
        //
        OE_n = 1'b1;                        // Disable output.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hzzzzzzzz, $sformatf("Test 5: Output disable failed. Expected High-Z, got 0x%08h", Q))

        //
        //  Test 6: Output enable (should still have the latched value).
        //
        OE_n = 1'b0;    // Re-enable output.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hAAAAAAAA, $sformatf("Test 6: Output re-enable failed. Expected 0xAAAAAAAA, got 0x%08h", Q))

        //
        //  Test 7: Transparent mode (LE high, output follows input continuously).
        //
        LE = 1'b1;                          // Keep latch enabled.
        A = 32'h11111111;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h11111111, $sformatf("Test 7a: Transparent mode failed. Expected 0x11111111, got 0x%08h", Q))

        A = 32'h22222222;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h22222222, $sformatf("Test 7b: Transparent mode failed. Expected 0x22222222, got 0x%08h", Q))

        //
        //  Test 8: Load zero value.
        //
        A = 32'h00000000;
        LE = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h00000000, $sformatf("Test 8: Load zero failed. Expected 0x00000000, got 0x%08h", Q))

        //
        //  Test 9: Load maximum value.
        //
        A = 32'hFFFFFFFF;
        LE = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hFFFFFFFF, $sformatf("Test 9: Load maximum value failed. Expected 0xFFFFFFFF, got 0x%08h", Q))

        //
        //  Test 10: Output disable while loading.
        //
        A = 32'h87654321;
        LE = 1'b1;
        OE_n = 1'b1;                        // Disable output while loading.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hzzzzzzzz, $sformatf("Test 10: Output disabled during load failed. Expected High-Z, got 0x%08h", Q))

        //
        //  Test 11: Enable output to see the loaded value.
        //
        OE_n = 1'b0;                        // Enable output.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h87654321, $sformatf("Test 11: Output after load failed. Expected 0x87654321, got 0x%08h", Q))

        //
        //  Test 12: Multiple latch and hold cycles.
        //
        A = 32'h55555555;
        LE = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h55555555, $sformatf("Test 12a: First load failed. Expected 0x55555555, got 0x%08h", Q))

        LE = 1'b0;
        A = 32'h99999999;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h55555555, $sformatf("Test 12b: Hold after LE low failed. Expected 0x55555555, got 0x%08h", Q))

        LE = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h99999999, $sformatf("Test 12c: Second load failed. Expected 0x99999999, got 0x%08h", Q))

        $display("Register - End of Simulation");
        $finish;
    end

endmodule
