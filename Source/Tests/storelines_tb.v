//
//  Test the implementation of the Store Lines for the Manchester Baby.
//
`timescale 1 ns / 10 ps
`include "Components/macros.v"

module storelines_tb();
    reg [4:0] A;
    reg [31:0] D;
    reg CS_n;
    reg WE_n;
    reg OE_n;
    wire [31:0] Q;

    //
    //  Instantiate the storelines module.
    //
    storelines uut (
        .A(A),
        .D(D),
        .CS_n(CS_n),
        .WE_n(WE_n),
        .OE_n(OE_n),
        .Q(Q)
    );

    localparam PROPAGATION_DELAY = 600;     // Delay to allow for propagation with some overhead.

    integer i;                              // Loop variable for tests.

    initial
    begin
        $dumpvars(0, storelines_tb);
    end

    //
    //  Set all Store Lines RAM contents to 0 at the start of the test.
    //
    initial
    begin
        integer i;
        for (i = 0; i < 1024; i = i + 1)
        begin
            uut.ram0.mem[i] = 4'b0000;
            uut.ram1.mem[i] = 4'b0000;
            uut.ram2.mem[i] = 4'b0000;
            uut.ram3.mem[i] = 4'b0000;
            uut.ram4.mem[i] = 4'b0000;
            uut.ram5.mem[i] = 4'b0000;
            uut.ram6.mem[i] = 4'b0000;
            uut.ram7.mem[i] = 4'b0000;
        end
    end

    initial
    begin
        //
        //  Setup the initial conditions.
        //
        A = 5'b00000;
        D = 32'h00000000;
        CS_n = 1'b1;            // Chip not selected.
        WE_n = 1'b1;            // Write disabled.
        OE_n = 1'b1;            // Output disabled.
        #PROPAGATION_DELAY;

        //
        //  Test 1: Write data to address 0.
        //
        A = 5'h00;
        D = 32'hDEADBEEF;
        CS_n = 1'b0;            // Enable chip.
        WE_n = 1'b0;            // Enable write.
        #PROPAGATION_DELAY;
        WE_n = 1'b1;            // Disable write.
        OE_n = 1'b0;            // Enable output.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hDEADBEEF, $sformatf("Test 1: Write to address 0 failed. Expected 0xDEADBEEF, got 0x%08h", Q))

        //
        //  Test 2: Write data to address 1.
        //
        A = 5'h01;
        D = 32'h12345678;
        WE_n = 1'b0;            // Enable write.
        #PROPAGATION_DELAY;
        WE_n = 1'b1;            // Disable write.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h12345678, $sformatf("Test 2: Write to address 1 failed. Expected 0x12345678, got 0x%08h", Q))

        //
        //  Test 3: Verify address 0 still holds original data.
        //
        A = 5'h00;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hDEADBEEF, $sformatf("Test 3: Address 0 data corrupted. Expected 0xDEADBEEF, got 0x%08h", Q))

        //
        //  Test 4: Write to maximum address 31.
        //
        A = 5'h1F;
        D = 32'hFFFFFFFF;
        WE_n = 1'b0;            // Enable write.
        #PROPAGATION_DELAY;
        WE_n = 1'b1;            // Disable write.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hFFFFFFFF, $sformatf("Test 4: Write to address 31 failed. Expected 0xFFFFFFFF, got 0x%08h", Q))

        //
        //  Test 5: Output enable disabled - output should be high-impedance.
        //
        OE_n = 1'b1;            // Disable output.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'bz, $sformatf("Test 5: OE_n disabled, expected high-impedance, got 0x%08h", Q))

        //
        //  Test 6: Re-enable output and verify data still present.
        //
        OE_n = 1'b0;            // Enable output.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hFFFFFFFF, $sformatf("Test 6: Re-enable output, expected 0xFFFFFFFF, got 0x%08h", Q))

        //
        //  Test 7: Chip Select disabled - output should be high-impedance.
        //
        CS_n = 1'b1;            // Disable chip.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'bz, $sformatf("Test 7: CS_n disabled, expected high-impedance, got 0x%08h", Q))

        //
        //  Test 8: Re-enable chip and verify data still present.
        //
        CS_n = 1'b0;            // Enable chip.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hFFFFFFFF, $sformatf("Test 8: Re-enable chip, expected 0xFFFFFFFF, got 0x%08h", Q))

        //
        //  Test 9: Write multiple sequential locations.
        //
        A = 5'h10;
        D = 32'h00000001;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;

        A = 5'h11;
        D = 32'h00000002;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;

        A = 5'h12;
        D = 32'h00000003;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;

        A = 5'h13;
        D = 32'h00000004;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;

        //
        //  Verify multiple locations.
        //
        A = 5'h10;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h00000001, $sformatf("Test 9a: Address 0x10 failed. Expected 0x00000001, got 0x%08h", Q))

        A = 5'h11;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h00000002, $sformatf("Test 9b: Address 0x11 failed. Expected 0x00000002, got 0x%08h", Q))

        A = 5'h12;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h00000003, $sformatf("Test 9c: Address 0x12 failed. Expected 0x00000003, got 0x%08h", Q))

        A = 5'h13;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h00000004, $sformatf("Test 9d: Address 0x13 failed. Expected 0x00000004, got 0x%08h", Q))

        //
        //  Test 10: Overwrite existing data.
        //
        A = 5'h00;
        D = 32'hCAFEBABE;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hCAFEBABE, $sformatf("Test 10: Overwrite address 0 failed. Expected 0xCAFEBABE, got 0x%08h", Q))

        //
        //  Test 11: Test all bit patterns.
        //
        A = 5'h0A;
        D = 32'h00000000;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h00000000, $sformatf("Test 11a: Pattern all zeros failed. Expected 0x00000000, got 0x%08h", Q))

        D = 32'hFFFFFFFF;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hFFFFFFFF, $sformatf("Test 11b: Pattern all ones failed. Expected 0xFFFFFFFF, got 0x%08h", Q))

        D = 32'hAAAAAAAA;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hAAAAAAAA, $sformatf("Test 11c: Pattern 0xAAAAAAAA failed. Expected 0xAAAAAAAA, got 0x%08h", Q))

        D = 32'h55555555;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h55555555, $sformatf("Test 11d: Pattern 0x55555555 failed. Expected 0x55555555, got 0x%08h", Q))

        //
        //  Test 12: Write with CS_n high should not write.
        //
        A = 5'h0B;
        D = 32'h00000000;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;

        CS_n = 1'b1;            // Disable chip.
        D = 32'hBAADF00D;
        WE_n = 1'b0;            // Try to write with CS disabled.
        #PROPAGATION_DELAY;
        WE_n = 1'b1;

        CS_n = 1'b0;            // Re-enable chip.
        OE_n = 1'b0;            // Enable output.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h00000000, $sformatf("Test 12: Write with CS_n high should not have written. Expected 0x00000000, got 0x%08h", Q))

        //
        //  Test 13: Write and read all 32 locations.
        //
        // Write pattern to all 32 locations.
        for (i = 0; i < 32; i = i + 1)
        begin
            A = i[4:0];
            D = {i[4:0], i[4:0], i[4:0], i[4:0], i[4:0], i[4:0], 2'b00};  // Create unique pattern.
            WE_n = 1'b0;
            #PROPAGATION_DELAY;
            WE_n = 1'b1;
            #PROPAGATION_DELAY;
        end

        // Read back and verify all 32 locations.
        for (i = 0; i < 32; i = i + 1)
        begin
            A = i[4:0];
            #PROPAGATION_DELAY;
            `ABORT_IF(Q !== {i[4:0], i[4:0], i[4:0], i[4:0], i[4:0], i[4:0], 2'b00}, 
                     $sformatf("Test 13: Address %d verification failed. Expected 0x%08h, got 0x%08h", 
                              i, {i[4:0], i[4:0], i[4:0], i[4:0], i[4:0], i[4:0], 2'b00}, Q))
        end

        //
        //  Test 14: Alternating read/write pattern.
        //
        A = 5'h0C;
        D = 32'h11111111;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h11111111, $sformatf("Test 14a: First write failed. Expected 0x11111111, got 0x%08h", Q))

        A = 5'h0D;
        D = 32'h22222222;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h22222222, $sformatf("Test 14b: Second write failed. Expected 0x22222222, got 0x%08h", Q))

        A = 5'h0C;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h11111111, $sformatf("Test 14c: First location corrupted. Expected 0x11111111, got 0x%08h", Q))

        //
        //  Test 15: Boundary values.
        //
        A = 5'h00;              // First address.
        D = 32'hF0F0F0F0;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hF0F0F0F0, $sformatf("Test 15a: First address boundary failed. Expected 0xF0F0F0F0, got 0x%08h", Q))

        A = 5'h1F;              // Last address.
        D = 32'h0F0F0F0F;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'h0F0F0F0F, $sformatf("Test 15b: Last address boundary failed. Expected 0x0F0F0F0F, got 0x%08h", Q))

        A = 5'h00;              // Verify first address unchanged.
        #PROPAGATION_DELAY;
        `ABORT_IF(Q !== 32'hF0F0F0F0, $sformatf("Test 15c: First address after last address write corrupted. Expected 0xF0F0F0F0, got 0x%08h", Q))

        $display("Store Lines - End of Simulation");
        #100;
        $finish;
    end

endmodule
