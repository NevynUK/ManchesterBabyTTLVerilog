//
//  Test the implementation of the 74LS245 octal bus transceiver.
//
`timescale 1 ns / 10 ps

module ttl245_tb();
    reg [7:0] A_drive;
    reg [7:0] B_drive;
    reg DIR;                // Direction control: 1 = A to B, 0 = B to A.
    reg OE_n;               // Output Enable (active low).
    wire [7:0] A;
    wire [7:0] B;
    
    reg A_enable;
    reg B_enable;

    //
    // Drive A and B buses conditionally.
    //
    assign A = A_enable ? A_drive : 8'bz;
    assign B = B_enable ? B_drive : 8'bz;
    
    //
    // Instantiate the ttl245_transceiver module using the default propagation delay.
    //
    ttl245_transceiver uut (
        .A(A),
        .B(B),
        .DIR(DIR),
        .OE_n(OE_n)
    );

    localparam PROPAGATION_DELAY = 50;     // Delay to allow for propagation with some overhead.

    initial begin
        $dumpvars(0, ttl245_tb);
    end

    initial begin
        //
        //  Setup the initial conditions.
        //
        A_drive = 8'b00000000;
        B_drive = 8'b00000000;
        DIR = 1'b0;                 // Initial direction B to A.
        OE_n = 1'b1;                // Outputs disabled.
        A_enable = 1'b0;
        B_enable = 1'b0;

        //
        //  Test 1: A to B direction (DIR = 1).
        //
        DIR = 1'b1;              // Set direction A to B.
        OE_n = 1'b0;             // Enable output.
        A_enable = 1'b1;         // Drive A bus.
        B_enable = 1'b0;         // Release B bus (will be driven by chip).
        A_drive = 8'b10101010;   // Drive A with test pattern.
        #PROPAGATION_DELAY
        if (B != A_drive) begin
            $error("Error: Test 1a, B bus did not match expected value.");
        end
        
        A_drive = 8'b11110000;   // Change A bus data.
        #PROPAGATION_DELAY;
        if (B != A_drive) begin
            $error("Error: Test 1b, B bus did not match expected value.");
        end
        //
        //  Test 2: B to A direction (DIR = 0).
        //
        DIR = 1'b0;              // Set direction B to A.
        A_enable = 1'b0;         // Release A bus (will be driven by chip).
        B_enable = 1'b1;         // Drive B bus.
        B_drive = 8'b00111100;   // Drive B with test pattern.
        #PROPAGATION_DELAY
        if (A != B_drive) begin
            $error("Error: Test 2a, A bus did not match expected value.");
        end
        
        B_drive = 8'b01010101;   // Change B bus data.
        #PROPAGATION_DELAY
        if (A != B_drive) begin
            $error("Error: Test 2b, A bus did not match expected value.");
        end
        //
        //  Test 3: Output disabled (OE_n = 1).
        //
        OE_n = 1'b1;             // Disable output.
        #PROPAGATION_DELAY
        if ((A !== 8'bz) && (B !== 8'bz)) begin
            $error("Error: Test 3, Outputs should be high-impedance.");
        end
        //
        //  Test 4: Re-enable with A to B direction.
        //
        DIR = 1'b1;              // Set direction A to B.
        OE_n = 1'b0;             // Enable output.
        A_enable = 1'b1;         // Drive A bus.
        B_enable = 1'b0;         // Release B bus.
        A_drive = 8'b11001100;   // Drive A with test pattern.
        #PROPAGATION_DELAY
        if (B != A_drive) begin
            $error("Error: Test 4, B bus did not match expected value.");
        end

        $display("74LS254 - End of Simulation");
        $finish;
    end

endmodule
