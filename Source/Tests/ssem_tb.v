//
//  Test the implementation of the SSEM (Small-Scale Experimental Machine).
//
`timescale 1 ns / 10 ps

module ssem_tb();
    reg clk;
    reg reset_n;
    reg load_A;
    reg load_B;
    reg a_to_bus;
    reg b_to_bus;
    reg alu_sub;
    reg alu_to_bus;
    wire [31:0] bus;
    
    //
    //  Bus driver for writing data to the bus
    //
    reg [31:0] bus_data;
    reg bus_drive;
    assign bus = bus_drive ? bus_data : 32'bz;

    //
    //  Instantiate the SSEM module.
    //
    ssem uut (
        .clk(clk),
        .reset_n(reset_n),
        .load_A(load_A),
        .load_B(load_B),
        .a_to_bus(a_to_bus),
        .b_to_bus(b_to_bus),
        .alu_sub(alu_sub),
        .alu_to_bus(alu_to_bus),
        .bus(bus)
    );

    localparam PROPAGATION_DELAY = 300;     //  Delay to allow for propagation with some overhead.
    localparam CLK_PERIOD = 20;             //  Clock period (50 MHz)

    //
    //  Clock generation
    //
    initial
    begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial
    begin
        $dumpvars(0, ssem_tb);
    end

    initial
    begin
        //
        //  Setup the initial conditions.
        //
        reset_n = 1'b0;
        load_A = 1'b0;
        load_B = 1'b0;
        a_to_bus = 1'b0;
        b_to_bus = 1'b0;
        alu_sub = 1'b0;
        alu_to_bus = 1'b0;
        bus_data = 32'h00000000;
        bus_drive = 1'b0;
        #PROPAGATION_DELAY;

        //
        //  Release reset
        //
        reset_n = 1'b1;
        #PROPAGATION_DELAY;

        //
        //  Test 1: Load value into register A
        //
        bus_data = 32'h12345678;
        bus_drive = 1'b1;
        load_A = 1'b1;
        #PROPAGATION_DELAY;
        load_A = 1'b0;
        bus_drive = 1'b0;
        #PROPAGATION_DELAY;
        
        //  Read back from register A
        a_to_bus = 1'b1;
        #PROPAGATION_DELAY;
        if (bus !== 32'h12345678)
        begin
            $error("ERROR: Test 1 - Load register A failed. Expected 0x12345678, got 0x%08h", bus);
        end
        a_to_bus = 1'b0;
        #PROPAGATION_DELAY;

        //
        //  Test 2: Load value into register B
        //
        bus_data = 32'hABCDEF00;
        bus_drive = 1'b1;
        load_B = 1'b1;
        #PROPAGATION_DELAY;
        load_B = 1'b0;
        bus_drive = 1'b0;
        #PROPAGATION_DELAY;
        
        //  Read back from register B
        b_to_bus = 1'b1;
        #PROPAGATION_DELAY;
        if (bus !== 32'hABCDEF00)
        begin
            $error("ERROR: Test 2 - Load register B failed. Expected 0xABCDEF00, got 0x%08h", bus);
        end
        b_to_bus = 1'b0;
        #PROPAGATION_DELAY;

        //
        //  Test 3: ALU Addition (5 + 3 = 8)
        //
        bus_data = 32'h00000005;
        bus_drive = 1'b1;
        load_A = 1'b1;
        #PROPAGATION_DELAY;
        load_A = 1'b0;
        bus_data = 32'h00000003;
        load_B = 1'b1;
        #PROPAGATION_DELAY;
        load_B = 1'b0;
        bus_drive = 1'b0;
        #PROPAGATION_DELAY;
        
        //  Perform addition
        alu_sub = 1'b0;                     //  Addition
        alu_to_bus = 1'b1;                  //  Output to bus
        #PROPAGATION_DELAY;
        if (bus !== 32'h00000008)
        begin
            $error("ERROR: Test 3 - ALU addition failed. Expected 0x00000008, got 0x%08h", bus);
        end
        alu_to_bus = 1'b0;
        #PROPAGATION_DELAY;

        //
        //  Test 4: ALU Subtraction (10 - 4 = 6)
        //
        bus_data = 32'h0000000A;
        bus_drive = 1'b1;
        load_A = 1'b1;
        #PROPAGATION_DELAY;
        load_A = 1'b0;
        bus_data = 32'h00000004;
        load_B = 1'b1;
        #PROPAGATION_DELAY;
        load_B = 1'b0;
        bus_drive = 1'b0;
        #PROPAGATION_DELAY;
        
        //  Perform subtraction
        alu_sub = 1'b1;                     //  Subtraction
        alu_to_bus = 1'b1;                  //  Output to bus
        #PROPAGATION_DELAY;
        if (bus !== 32'h00000006)
        begin
            $error("ERROR: Test 4 - ALU subtraction failed. Expected 0x00000006, got 0x%08h", bus);
        end
        alu_to_bus = 1'b0;
        #PROPAGATION_DELAY;

        //
        //  Test 5: Compute 100 + 50 and verify the result on the bus
        //
        bus_data = 32'h00000064;            //  100
        bus_drive = 1'b1;
        load_A = 1'b1;
        #PROPAGATION_DELAY;
        load_A = 1'b0;
        bus_data = 32'h00000032;            //  50
        load_B = 1'b1;
        #PROPAGATION_DELAY;
        load_B = 1'b0;
        bus_drive = 1'b0;
        #PROPAGATION_DELAY;
        
        //  Compute 100 + 50 = 150 and verify on bus
        alu_sub = 1'b0;
        alu_to_bus = 1'b1;                  //  Output to bus
        #PROPAGATION_DELAY;
        if (bus !== 32'h00000096)           //  150 decimal = 0x96
        begin
            $error("ERROR: Test 5 - ALU computation failed. Expected 0x00000096, got 0x%08h", bus);
        end
        alu_to_bus = 1'b0;
        #PROPAGATION_DELAY;

        //
        //  Test 6: Bus tristate behavior (no drivers active)
        //
        a_to_bus = 1'b0;
        b_to_bus = 1'b0;
        alu_to_bus = 1'b0;
        #PROPAGATION_DELAY;
        if (bus !== 32'hzzzzzzzz)
        begin
            $error("ERROR: Test 6 - Bus should be high-Z, got 0x%08h", bus);
        end

        //
        //  Test 7: Large numbers addition (1000 + 2000 = 3000)
        //
        bus_data = 32'h000003E8;            //  1000
        bus_drive = 1'b1;
        load_A = 1'b1;
        #PROPAGATION_DELAY;
        load_A = 1'b0;
        bus_data = 32'h000007D0;            //  2000
        load_B = 1'b1;
        #PROPAGATION_DELAY;
        load_B = 1'b0;
        bus_drive = 1'b0;
        #PROPAGATION_DELAY;
        
        alu_sub = 1'b0;
        alu_to_bus = 1'b1;                  //  Output to bus
        #PROPAGATION_DELAY;
        if (bus !== 32'h00000BB8)           //  3000
        begin
            $error("ERROR: Test 7 - Large addition failed. Expected 0x00000BB8, got 0x%08h", bus);
        end
        alu_to_bus = 1'b0;
        #PROPAGATION_DELAY;

        //
        //  Test 8: Subtraction with negative result (5 - 10 = -5)
        //
        bus_data = 32'h00000005;
        bus_drive = 1'b1;
        load_A = 1'b1;
        #PROPAGATION_DELAY;
        load_A = 1'b0;
        bus_data = 32'h0000000A;
        load_B = 1'b1;
        #PROPAGATION_DELAY;
        load_B = 1'b0;
        bus_drive = 1'b0;
        #PROPAGATION_DELAY;
        
        alu_sub = 1'b1;
        alu_to_bus = 1'b1;                  //  Output to bus
        #PROPAGATION_DELAY;
        if (bus !== 32'hFFFFFFFB)           //  -5 in two's complement
        begin
            $error("ERROR: Test 8 - Negative result failed. Expected 0xFFFFFFFB, got 0x%08h", bus);
        end
        alu_to_bus = 1'b0;
        #PROPAGATION_DELAY;

        //
        //  All tests completed
        //
        $display("SSEM - End of Tests / Simulation");
        #100;
        $finish;
    end

endmodule
