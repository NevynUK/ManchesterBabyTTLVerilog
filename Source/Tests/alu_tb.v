//
//  Test the implementation of the ALU (Arithmetic Logic Unit).
//
`timescale 1 ns / 10 ps

module alu_tb();
    reg [31:0] A;
    reg [31:0] B;
    reg SUB;
    reg OE_n;
    wire [31:0] RESULT;

    //
    //  Instantiate the ALU module.
    //
    alu uut (
        .A(A),
        .B(B),
        .SUB(SUB),
        .OE_n(OE_n),
        .RESULT(RESULT)
    );

    localparam PROPAGATION_DELAY = 200;     //  Delay to allow for propagation with some overhead.

    initial
    begin
        $dumpvars(0, alu_tb);
    end

    initial
    begin
        //
        //  Setup the initial conditions.
        //
        A = 32'h00000000;
        B = 32'h00000000;
        SUB = 1'b0;
        OE_n = 1'b1;                        //  Output disabled initially.
        #PROPAGATION_DELAY;

        //
        //  Test 1: Simple addition (5 + 3 = 8).
        //
        A = 32'h00000005;
        B = 32'h00000003;
        SUB = 1'b0;
        OE_n = 1'b0;                        //  Enable output.
        #PROPAGATION_DELAY;
        if (RESULT !== 32'h00000008)
        begin
            $error("ERROR: Test 1 - Addition 5 + 3 failed. Expected 0x00000008, got 0x%08h", RESULT);
        end

        //
        //  Test 2: Subtraction (10 - 4 = 6).
        //
        A = 32'h0000000A;
        B = 32'h00000004;
        SUB = 1'b1;                         //  Subtraction, SUB = 1.
        #PROPAGATION_DELAY;
        if (RESULT !== 32'h00000006)
        begin
            $error("ERROR: Test 2 - Subtraction 10 - 4 failed. Expected 0x00000006, got 0x%08h", RESULT);
        end

        //
        //  Test 3: Addition with larger numbers (1000 + 2000 = 3000).
        //
        A = 32'h000003E8;                   //  1000 decimal
        B = 32'h000007D0;                   //  2000 decimal
        SUB = 1'b0;                         //  Addition, SUB = 0.
        #PROPAGATION_DELAY;
        if (RESULT !== 32'h00000BB8)        //  3000 decimal
        begin
            $error("ERROR: Test 3 - Addition 1000 + 2000 failed. Expected 0x00000BB8, got 0x%08h", RESULT);
        end

        //
        //  Test 4: Subtraction resulting in zero (100 - 100 = 0).
        //
        A = 32'h00000064;                   //  100 decimal
        B = 32'h00000064;                   //  100 decimal
        SUB = 1'b1;                         //  Subtraction, SUB = 1.
        #PROPAGATION_DELAY;
        if (RESULT !== 32'h00000000)
        begin
            $error("ERROR: Test 4 - Subtraction 100 - 100 failed. Expected 0x00000000, got 0x%08h", RESULT);
        end

        //
        //  Test 5: Addition with carry propagation (0xFFFFFFFF + 1 = 0x00000000 with overflow).
        //
        A = 32'hFFFFFFFF;
        B = 32'h00000001;
        SUB = 1'b0;
        #PROPAGATION_DELAY;
        if (RESULT !== 32'h00000000)
        begin
            $error("ERROR: Test 5 - Addition with overflow failed. Expected 0x00000000, got 0x%08h", RESULT);
        end

        //
        //  Test 6: Subtraction with borrow (5 - 10 = -5, 0xFFFFFFFB in two's complement).
        //
        A = 32'h00000005;
        B = 32'h0000000A;
        SUB = 1'b1;
        #PROPAGATION_DELAY;
        if (RESULT !== 32'hFFFFFFFB)
        begin
            $error("ERROR: Test 6 - Subtraction with negative result failed. Expected 0xFFFFFFFB, got 0x%08h", RESULT);
        end

        //
        //  Test 7: Output enable control (High-Z state).
        //
        A = 32'h12345678;
        B = 32'h87654321;
        SUB = 1'b0;
        OE_n = 1'b1;                        //  Disable output (should be High-Z).
        #PROPAGATION_DELAY;
        if (RESULT !== 32'hzzzzzzzz)
        begin
            $error("ERROR: Test 7 - Output disable failed. Expected High-Z, got 0x%08h", RESULT);
        end

        //
        //  Test 8: Re-enable output.
        //
        OE_n = 1'b0;                        //  Re-enable output.
        #PROPAGATION_DELAY;
        if (RESULT !== 32'h99999999)        //  0x12345678 + 0x87654321 = 0x99999999
        begin
            $error("ERROR: Test 8 - Output re-enable failed. Expected 0x99999999, got 0x%08h", RESULT);
        end

        //
        //  Test 9: Large subtraction (0xFFFFFFFF - 1 = 0xFFFFFFFE).
        //
        A = 32'hFFFFFFFF;
        B = 32'h00000001;
        SUB = 1'b1;                         //  Subtraction, SUB = 1.
        #PROPAGATION_DELAY;
        if (RESULT !== 32'hFFFFFFFE)
        begin
            $error("ERROR: Test 9 - Large subtraction failed. Expected 0xFFFFFFFE, got 0x%08h", RESULT);
        end

        //
        //  Test 10: Zero addition (0 + 0 = 0).
        //
        A = 32'h00000000;
        B = 32'h00000000;
        SUB = 1'b0;                         //  Addition, SUB = 0.
        #PROPAGATION_DELAY;
        if (RESULT !== 32'h00000000)
        begin
            $error("ERROR: Test 10 - Zero addition failed. Expected 0x00000000, got 0x%08h", RESULT);
        end

        //
        //  Test 11: Maximum positive addition (0x7FFFFFFF + 1 = 0x80000000).
        //
        A = 32'h7FFFFFFF;
        B = 32'h00000001;
        SUB = 1'b0;                         //  Addition, SUB = 0.
        #PROPAGATION_DELAY;
        if (RESULT !== 32'h80000000)
        begin
            $error("ERROR: Test 11 - Maximum positive addition failed. Expected 0x80000000, got 0x%08h", RESULT);
        end

        //
        //  Test 12: Continuous computation (change inputs, result updates immediately).
        //
        A = 32'h00000100;
        B = 32'h00000200;
        SUB = 1'b0;                         //  Addition, SUB = 0.
        #PROPAGATION_DELAY;
        if (RESULT !== 32'h00000300)
        begin
            $error("ERROR: Test 12a - Initial computation failed. Expected 0x00000300, got 0x%08h", RESULT);
        end
        
        //  Change inputs, result should update immediately.
        A = 32'h00001000;
        B = 32'h00000500;
        #PROPAGATION_DELAY;
        if (RESULT !== 32'h00001500)
        begin
            $error("ERROR: Test 12b - Continuous computation failed. Expected 0x00001500, got 0x%08h", RESULT);
        end

        $display("ALU - End of Tests / Simulation");
        $finish;
    end

endmodule
