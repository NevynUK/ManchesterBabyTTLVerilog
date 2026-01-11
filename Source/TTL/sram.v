module sram_2114
#(READ_PROPAGATION_DELAY = 450, WRITE_PROPAGATION_DELAY = 450, RISE_TIME = 1, FALL_TIME = 1)
(
    input wire [9:0] addr,    // 10 address lines (A0-A9)
    inout wire [3:0] dq,      // 4-bit bi-directional data bus (DQ1-DQ4)
    input wire CS_n,          // Chip Select (active low)
    input wire WE_n           // Write Enable (active low)
);
    //
    //  Memory array declaration: 1024 words (addresses 0 to 1023), each 4 bits wide.
    //
    reg [3:0] mem [0:1023];

    //
    //  Internal variable to hold data for output
    //
    reg [3:0] data_out;

    //
    //  Data output is enabled only when CS_n is low and WE_n is high (read mode)
    //
    assign dq = ((CS_n == 1'b0) && (WE_n == 1'b1)) ? data_out : 4'bz;

    //
    //  Write operation: triggered on falling edge of WE_n when chip is selected
    //
    always @(negedge WE_n)
    begin
        if (CS_n == 1'b0)
        begin
            //
            //  Write data from dq bus to memory
            //
            #WRITE_PROPAGATION_DELAY mem[addr] <= dq;
        end
    end

    //
    //  Read operation: combinatorial, responds to address and control signal changes
    //
    always @(CS_n or WE_n or addr)
    begin
        if (CS_n == 1'b0 && WE_n == 1'b1)
        begin
            //
            //  Read operation: drive data_out with memory contents
            //
            #READ_PROPAGATION_DELAY data_out = mem[addr];
        end
        else
        begin
            //
            //  Chip deselected or in write mode: output goes to high impedance
            //
            data_out = 4'bz;
        end
    end

endmodule