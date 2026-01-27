//
//  Test the implementation of the sram_2114 1024x4-bit Static RAM.
//
`timescale 1 ns / 10 ps
`include "Components/macros.v"

module sram_2114_tb();
    reg [9:0] addr;
    reg CS_n;
    reg WE_n;
    reg [3:0] data_in;
    wire [3:0] dq;

    //
    //  Bidirectional I/O control: drive dq during write, read during read.
    //
    assign dq = (~CS_n & ~WE_n) ? data_in : 4'bz;

    //
    //  Instantiate the sram_2114 module.
    //
    sram_2114 uut (
        .addr(addr),
        .dq(dq),
        .CS_n(CS_n),
        .WE_n(WE_n)
    );

    localparam PROPAGATION_DELAY = 600;     // Delay to allow for propagation with some overhead.

    initial
    begin
        $dumpvars(0, sram_2114_tb);
    end

    //
    //  Set the SRAM contents to 0 at the start of the test.
    //
    initial
    begin
        integer i;
        for (i = 0; i < 1024; i = i + 1)
        begin
            uut.mem[i] = 4'b0000;
        end
    end

    initial
    begin
        //
        //  Setup the initial conditions.
        //
        addr = 10'h000;
        CS_n = 1'b1;            // Chip not selected.
        WE_n = 1'b1;            // Write disabled.
        data_in = 4'b0000;
        #PROPAGATION_DELAY;

        //
        //  Test 1: Write data to address 0x000.
        //
        addr = 10'h000;
        data_in = 4'hA;
        CS_n = 1'b0;            // Enable chip.
        WE_n = 1'b0;            // Enable write.
        #PROPAGATION_DELAY;
        WE_n = 1'b1;            // Disable write (enables read).
        data_in = 4'bz;         // Release data bus.
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'hA, $sformatf("Test 1: Write/Read to address 0x000 failed. Expected 0xA, got 0x%h", dq))

        //
        //  Test 2: Write data to address 0x001 (assumes CS_n enabled).
        //
        addr = 10'h001;
        data_in = 4'h5;
        WE_n = 1'b0;            // Enable write.
        #PROPAGATION_DELAY;
        WE_n = 1'b1;            // Disable write (enables read).
        data_in = 4'bz;         // Release data bus.
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'h5, $sformatf("Test 2: Write/Read from address 0x001 failed. Expected 0x5, got 0x%h", dq))

        //
        //  Test 3: Verify address 0x000 still holds original data (assumes CS_n enabled).
        //
        addr = 10'h000;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'hA, $sformatf("Test 3: Address 0x000 data corrupted. Expected 0xA, got 0x%h", dq))

        //
        //  Test 4: Write to maximum address 0x3FF (assumes CS_n enabled).
        //
        addr = 10'h3FF;
        data_in = 4'hF;
        WE_n = 1'b0;            // Enable write.
        #PROPAGATION_DELAY;
        WE_n = 1'b1;            // Disable write (enables read).
        data_in = 4'bz;         // Release data bus.
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'hF, $sformatf("Test 4: Write/Read from address 0x3FF failed. Expected 0xF, got 0x%h", dq))

        //
        //  Test 5: Chip Select disabled - output should be high-impedance.
        //
        CS_n = 1'b1;            // Disable chip.
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'bz, $sformatf("Test 5: CS_n disabled, expected high-impedance, got 0x%h", dq))

        //
        //  Test 6: Re-enable chip and verify data still present (assumes WE_n is disabled and addr is unchanged).
        //
        CS_n = 1'b0;            // Enable chip.
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'hF, $sformatf("Test 6: Re-enable chip, expected 0xF, got 0x%h", dq))

        //
        //  Test 7: Write multiple locations (assumes CS_n enabled).
        //
        addr = 10'h100;
        data_in = 4'h1;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;

        addr = 10'h101;
        data_in = 4'h2;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;

        addr = 10'h102;
        data_in = 4'h3;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;

        //
        //  Verify multiple locations (assumes chip is still selected and WE_n is disabled).
        //
        addr = 10'h100;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'h1, $sformatf("Test 7a: Address 0x100 failed. Expected 0x1, got 0x%h", dq))

        addr = 10'h101;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'h2, $sformatf("Test 7b: Address 0x101 failed. Expected 0x2, got 0x%h", dq))

        addr = 10'h102;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'h3, $sformatf("Test 7c: Address 0x102 failed. Expected 0x3, got 0x%h", dq))

        //
        //  Test 8: Overwrite existing data.
        //
        addr = 10'h000;
        data_in = 4'h7;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'h7, $sformatf("Test 8: Overwrite address 0x000 failed. Expected 0x7, got 0x%h", dq))

        //
        //  Test 9: Write all bit patterns to a single location.
        //
        addr = 10'h200;
        data_in = 4'b0000;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'b0000, $sformatf("Test 9a: Pattern 0000 failed. Expected 0x0, got 0x%h", dq))

        data_in = 4'b1111;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'b1111, $sformatf("Test 9b: Pattern 1111 failed. Expected 0xF, got 0x%h", dq))

        data_in = 4'b1010;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'b1010, $sformatf("Test 9c: Pattern 1010 failed. Expected 0xA, got 0x%h", dq))

        data_in = 4'b0101;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'b0101, $sformatf("Test 9d: Pattern 0101 failed. Expected 0x5, got 0x%h", dq))

        //
        //  Test 10: Write with CS_n high should not write.
        //
        addr = 10'h300;
        data_in = 4'h0;
        CS_n = 1'b0;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'h0, $sformatf("Test 10a: Setting address 0x300. Expected 0x0, got 0x%h", dq))

        CS_n = 1'b1;            // Disable chip.
        addr = 10'h300;
        data_in = 4'hE;
        WE_n = 1'b0;            // Try to write with CS disabled.
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;

        CS_n = 1'b0;            // Re-enable chip, WE_n disabled.
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'h0, $sformatf("Test 10b: Write with CS_n high should not have written. Expected 0x0, got 0x%h", dq))

        //
        //  Test 11: Sequential write and read of multiple addresses.
        //
        addr = 10'h3FD;
        data_in = 4'hD;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;

        addr = 10'h3FE;
        data_in = 4'hE;
        WE_n = 1'b0;
        #PROPAGATION_DELAY;
        WE_n = 1'b1;
        data_in = 4'bz;
        #PROPAGATION_DELAY;

        addr = 10'h3FD;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'hD, $sformatf("Test 11a: Address 0x3FD failed. Expected 0xD, got 0x%h", dq))

        addr = 10'h3FE;
        #PROPAGATION_DELAY;
        `ABORT_IF(dq !== 4'hE, $sformatf("Test 11b: Address 0x3FE failed. Expected 0xE, got 0x%h", dq))

        $display("sram_2114 - End of Simulation");
        $finish;
    end

endmodule
