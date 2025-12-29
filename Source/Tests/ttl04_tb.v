//
//  Test the implementation of the 7404 hex inverter.
//
`timescale 1 ns / 10 ps

module ttl04_tb();
    reg A1, A2, A3, A4, A5, A6;
    wire Y1, Y2, Y3, Y4, Y5, Y6;

    //
    //  Instantiate the ttl04_inverter module using the default propagation delay.
    //
    ttl04_inverter uut (
        .A1(A1), .Y1(Y1),
        .A2(A2), .Y2(Y2),
        .A3(A3), .Y3(Y3),
        .A4(A4), .Y4(Y4),
        .A5(A5), .Y5(Y5),
        .A6(A6), .Y6(Y6)
    );

    localparam PROPAGATION_DELAY = 50;     // Delay to allow for propagation with some overhead.

    initial
    begin
        $dumpvars(0, ttl04_tb);
    end

    initial
    begin
        //
        //  Setup the initial conditions.
        //
        A1 = 1'b0;
        A2 = 1'b0;
        A3 = 1'b0;
        A4 = 1'b0;
        A5 = 1'b0;
        A6 = 1'b0;
        #PROPAGATION_DELAY;

        //
        //  Test Gate 1: Both input values.
        //
        A1 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y1 !== 1'b1)
        begin
            $error("ERROR: Gate 1 - Test NOT 0 failed. Expected Y1=1, got Y1=%b", Y1);
        end

        A1 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y1 !== 1'b0)
        begin
            $error("ERROR: Gate 1 - Test NOT 1 failed. Expected Y1=0, got Y1=%b", Y1);
        end

        //
        //  Test Gate 2: Both input values.
        //
        A2 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y2 !== 1'b1)
        begin
            $error("ERROR: Gate 2 - Test NOT 0 failed. Expected Y2=1, got Y2=%b", Y2);
        end

        A2 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y2 !== 1'b0)
        begin
            $error("ERROR: Gate 2 - Test NOT 1 failed. Expected Y2=0, got Y2=%b", Y2);
        end

        //
        //  Test Gate 3: Both input values.
        //
        A3 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y3 !== 1'b1)
        begin
            $error("ERROR: Gate 3 - Test NOT 0 failed. Expected Y3=1, got Y3=%b", Y3);
        end

        A3 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y3 !== 1'b0)
        begin
            $error("ERROR: Gate 3 - Test NOT 1 failed. Expected Y3=0, got Y3=%b", Y3);
        end

        //
        //  Test Gate 4: Both input values.
        //
        A4 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y4 !== 1'b1)
        begin
            $error("ERROR: Gate 4 - Test NOT 0 failed. Expected Y4=1, got Y4=%b", Y4);
        end

        A4 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y4 !== 1'b0)
        begin
            $error("ERROR: Gate 4 - Test NOT 1 failed. Expected Y4=0, got Y4=%b", Y4);
        end

        //
        //  Test Gate 5: Both input values.
        //
        A5 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y5 !== 1'b1)
        begin
            $error("ERROR: Gate 5 - Test NOT 0 failed. Expected Y5=1, got Y5=%b", Y5);
        end

        A5 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y5 !== 1'b0)
        begin
            $error("ERROR: Gate 5 - Test NOT 1 failed. Expected Y5=0, got Y5=%b", Y5);
        end

        //
        //  Test Gate 6: Both input values.
        //
        A6 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y6 !== 1'b1)
        begin
            $error("ERROR: Gate 6 - Test NOT 0 failed. Expected Y6=1, got Y6=%b", Y6);
        end

        A6 = 1'b1;
        #PROPAGATION_DELAY;
        if (Y6 !== 1'b0)
        begin
            $error("ERROR: Gate 6 - Test NOT 1 failed. Expected Y6=0, got Y6=%b", Y6);
        end

        //
        //  Test all gates simultaneously with different values.
        //
        A1 = 1'b1;
        A2 = 1'b0;
        A3 = 1'b1;
        A4 = 1'b0;
        A5 = 1'b1;
        A6 = 1'b0;
        #PROPAGATION_DELAY;
        if (Y1 !== 1'b0 || Y2 !== 1'b1 || Y3 !== 1'b0 || Y4 !== 1'b1 || Y5 !== 1'b0 || Y6 !== 1'b1)
        begin
            $error("ERROR: Simultaneous test failed. Expected Y1=0, Y2=1, Y3=0, Y4=1, Y5=0, Y6=1, got Y1=%b, Y2=%b, Y3=%b, Y4=%b, Y5=%b, Y6=%b", Y1, Y2, Y3, Y4, Y5, Y6);
        end

        $display("7404 - End of Simulation");
        $finish;
    end

endmodule
