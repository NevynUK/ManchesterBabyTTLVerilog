//
//  Implement the store lines for the Manchester Baby.
//
//  Features:
//  - 32-bit data width
//  - 32 Store lines (words) in total
//  - 5-bit address (to address 32 words)
//  - Read and Write capability
//  - Output enable for tri-state control
//
//  Implementation:
//  - Use eight 2114 RAM chips (1024x4 bits each)
//  - Each chip stores 4 bits of data across all 32 words
//  - Address lines A[4:0] select one of 32 words (only use 32 out of 1024 locations)
//  - CS_n and WE_n control read/write operations
//  - OE_n controls output tri-state
//
module storelines
(
    input wire [4:0] A,         // 5-bit Address Input (0-31).
    input wire [31:0] D,        // 32-bit Data Input for writing.
    input wire CS_n,            // Chip Select (active low).
    input wire WE_n,            // Write Enable (active low).
    input wire OE_n,            // Output Enable (active low).
    output wire [31:0] Q        // 32-bit Data Output.
);
    //
    //  Extend 5-bit address to 10-bit for 2114 chips (upper bits unused).
    //
    wire [9:0] addr;
    assign addr = {5'b00000, A};

    //
    //  Internal I/O signals for each RAM chip.
    //
    wire [3:0] io_0, io_1, io_2, io_3, io_4, io_5, io_6, io_7;

    //
    //  Wire splitting for data input (write mode).
    //      - When writing, drive the I/O pins with data.
    //      - When reading, I/O pins will be driven by RAM chips.
    //
    assign io_0 = (~CS_n & ~WE_n) ? D[3:0] : 4'bz;
    assign io_1 = (~CS_n & ~WE_n) ? D[7:4] : 4'bz;
    assign io_2 = (~CS_n & ~WE_n) ? D[11:8] : 4'bz;
    assign io_3 = (~CS_n & ~WE_n) ? D[15:12] : 4'bz;
    assign io_4 = (~CS_n & ~WE_n) ? D[19:16] : 4'bz;
    assign io_5 = (~CS_n & ~WE_n) ? D[23:20] : 4'bz;
    assign io_6 = (~CS_n & ~WE_n) ? D[27:24] : 4'bz;
    assign io_7 = (~CS_n & ~WE_n) ? D[31:28] : 4'bz;

    //
    //  Eight 2114 RAM chips, each storing 4 bits of the 32-bit word.
    //  RAM0: bits [3:0] ... RAM7: bits [31:28]
    //
    sram_2114 ram0 (.addr(addr), .CS_n(CS_n), .WE_n(WE_n), .dq(io_0));
    sram_2114 ram1 (.addr(addr), .CS_n(CS_n), .WE_n(WE_n), .dq(io_1));
    sram_2114 ram2 (.addr(addr), .CS_n(CS_n), .WE_n(WE_n), .dq(io_2));
    sram_2114 ram3 (.addr(addr), .CS_n(CS_n), .WE_n(WE_n), .dq(io_3));
    sram_2114 ram4 (.addr(addr), .CS_n(CS_n), .WE_n(WE_n), .dq(io_4));
    sram_2114 ram5 (.addr(addr), .CS_n(CS_n), .WE_n(WE_n), .dq(io_5));
    sram_2114 ram6 (.addr(addr), .CS_n(CS_n), .WE_n(WE_n), .dq(io_6));
    sram_2114 ram7 (.addr(addr), .CS_n(CS_n), .WE_n(WE_n), .dq(io_7));

    //
    //  Output control with tri-state.
    //      - When OE_n is low, drive Q with data from RAM.
    //      - When OE_n is high, Q is high-impedance.
    //
    assign Q = (~OE_n) ? {io_7, io_6, io_5, io_4, io_3, io_2, io_1, io_0} : 32'bz;

endmodule