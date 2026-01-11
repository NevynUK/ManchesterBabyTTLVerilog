//
//  Test the implementation of the Program Counter (PC).
//
`timescale 1 ns / 10 ps

module pc_tb();
    reg [31:0] A;
    reg CLK;
    reg LOAD_n;
    reg OE_n;
    wire [31:0] Q;

    //
    //  Instantiate the PC module.
    //
    pc uut (
        .A(A),
        .CLK(CLK),
        .LOAD_n(LOAD_n),
        .OE_n(OE_n),
        .Q(Q)
    );

    localparam PROPAGATION_DELAY = 100;     // Delay to allow for propagation with some overhead.
    localparam CLK_PERIOD = 20;             // Clock period (50 MHz clock).

    initial
    begin
        $dumpvars(0, pc_tb);
    end

    initial
    begin
        //
        //  Setup the initial conditions.
        //
        CLK = 1'b0;
        A = 32'h00000000;
        LOAD_n = 1'b1;      // Not loading initially.
        OE_n = 1'b1;        // Output disabled initially.
        #PROPAGATION_DELAY;

        //
        //  Test 1: Load initial value.
        //
        A = 32'h00000000;
        LOAD_n = 1'b0;      // Enable load.
        OE_n = 1'b0;        // Enable output.
        #PROPAGATION_DELAY;
        if (Q !== 32'h00000000)
        begin
            $error("ERROR: Test 1 - Load initial value failed. Expected 0x00000000, got 0x%08h", Q);
        end

        //
        //  Test 2: Count up from 0.
        //
        LOAD_n = 1'b1;      // Disable load, enable counting.
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h00000001)
        begin
            $error("ERROR: Test 2 - First increment failed. Expected 0x00000001, got 0x%08h", Q);
        end

        //
        //  Test 3: Continue counting.
        //
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h00000002)
        begin
            $error("ERROR: Test 3 - Second increment failed. Expected 0x00000002, got 0x%08h", Q);
        end

        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h00000003)
        begin
            $error("ERROR: Test 3b - Third increment failed. Expected 0x00000003, got 0x%08h", Q);
        end

        //
        //  Test 4: Load a new value while counting.
        //
        A = 32'h00000010;
        LOAD_n = 1'b0;      // Enable load.
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h00000010)
        begin
            $error("ERROR: Test 4 - Load new value failed. Expected 0x00000010, got 0x%08h", Q);
        end

        //
        //  Test 5: Resume counting from loaded value.
        //
        LOAD_n = 1'b1;      // Disable load.
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h00000011)
        begin
            $error("ERROR: Test 5 - Count from loaded value failed. Expected 0x00000011, got 0x%08h", Q);
        end

        //
        //  Test 6: Output disable (High-Z).
        //
        OE_n = 1'b1;        // Disable output.
        #PROPAGATION_DELAY;
        if (Q !== 32'hzzzzzzzz)
        begin
            $error("ERROR: Test 6 - Output disable failed. Expected High-Z, got 0x%08h", Q);
        end

        //
        //  Test 7: Counter continues even with output disabled.
        //
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        OE_n = 1'b0;        // Re-enable output.
        #PROPAGATION_DELAY;
        if (Q !== 32'h00000012)
        begin
            $error("ERROR: Test 7 - Counter continued during output disable failed. Expected 0x00000012, got 0x%08h", Q);
        end

        //
        //  Test 8: Test 4-bit boundary crossing (0x0F to 0x10).
        //
        A = 32'h0000000E;
        LOAD_n = 1'b0;
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h0000000E)
        begin
            $error("ERROR: Test 8a - Load 0x0E failed. Expected 0x0000000E, got 0x%08h", Q);
        end

        LOAD_n = 1'b1;
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h0000000F)
        begin
            $error("ERROR: Test 8b - Increment to 0x0F failed. Expected 0x0000000F, got 0x%08h", Q);
        end

        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h00000010)
        begin
            $error("ERROR: Test 8c - 4-bit boundary crossing failed. Expected 0x00000010, got 0x%08h", Q);
        end

        //
        //  Test 9: Test 8-bit boundary crossing (0xFF to 0x100).
        //
        A = 32'h000000FE;
        LOAD_n = 1'b0;
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        LOAD_n = 1'b1;

        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h000000FF)
        begin
            $error("ERROR: Test 9a - Increment to 0xFF failed. Expected 0x000000FF, got 0x%08h", Q);
        end

        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h00000100)
        begin
            $error("ERROR: Test 9b - 8-bit boundary crossing failed. Expected 0x00000100, got 0x%08h", Q);
        end

        //
        //  Test 10: Test 16-bit boundary crossing (0xFFFF to 0x10000).
        //
        A = 32'h0000FFFE;
        LOAD_n = 1'b0;
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        LOAD_n = 1'b1;

        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h0000FFFF)
        begin
            $error("ERROR: Test 10a - Increment to 0xFFFF failed. Expected 0x0000FFFF, got 0x%08h", Q);
        end

        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h00010000)
        begin
            $error("ERROR: Test 10b - 16-bit boundary crossing failed. Expected 0x00010000, got 0x%08h", Q);
        end

        //
        //  Test 11: Test 32-bit overflow (0xFFFFFFFF to 0x00000000).
        //
        A = 32'hFFFFFFFE;
        LOAD_n = 1'b0;
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        LOAD_n = 1'b1;

        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'hFFFFFFFF)
        begin
            $error("ERROR: Test 11a - Increment to 0xFFFFFFFF failed. Expected 0xFFFFFFFF, got 0x%08h", Q);
        end

        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        if (Q !== 32'h00000000)
        begin
            $error("ERROR: Test 11b - 32-bit overflow failed. Expected 0x00000000, got 0x%08h", Q);
        end

        //
        //  Test 12: Multiple rapid increments.
        //
        A = 32'h00000100;
        LOAD_n = 1'b0;
        CLK = 1'b1;         // Rising edge.
        #CLK_PERIOD;
        CLK = 1'b0;
        #PROPAGATION_DELAY;
        LOAD_n = 1'b1;

        repeat (10)
        begin
            CLK = 1'b1;     // Rising edge.
            #CLK_PERIOD;
            CLK = 1'b0;
            #CLK_PERIOD;
        end
        #PROPAGATION_DELAY;
        if (Q !== 32'h0000010A)
        begin
            $error("ERROR: Test 12 - Multiple increments failed. Expected 0x0000010A, got 0x%08h", Q);
        end

        $display("PC - End of Simulation");
        #100;
        $finish;
    end

endmodule
