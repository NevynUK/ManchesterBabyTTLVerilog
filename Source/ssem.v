//
//  SSEM - Small-Scale Experimental Machine
//
//  This file implements the SSEM CPU core in Verilog.
//
//  Features:
//  - 32-bit bus connecting the components
//  - Two registers A and B connected to the bus
//  - Simple control logic for loading registers and performing operations
//  - ALU capable of basic arithmetic operations connected to the A and B registers
//  - Inputs to the SSEM are:
//    - clk: Clock signal
//    - reset_n: Active low reset signal
//    - load_A: Load enable for register A
//    - load_B: Load enable for register B
//    - a_to_bus: Output register A to the bus
//    - b_to_bus: Output register B to the bus
//    - alu_sub: ALU subtract control (0=add, 1=subtract)
//    - alu_to_bus: ALU output to the bus
// - The bus is an inout bus
//
module ssem
(
    input wire clk,                 //  Clock signal
    input wire reset_n,             //  Active low reset signal
    input wire load_A,              //  Load enable for register A
    input wire load_B,              //  Load enable for register B
    input wire a_to_bus,            //  Output register A to the bus
    input wire b_to_bus,            //  Output register B to the bus
    input wire alu_sub,             //  ALU subtract control (0=add, 1=subtract)
    input wire alu_to_bus,          //  ALU output to the bus
    inout wire [31:0] bus           //  32-bit bidirectional bus
);
    //
    //  Internal signals
    //
    wire [31:0] A_to_alu;           //  Output from register A to ALU
    wire [31:0] B_to_alu;           //  Output from register B to ALU
    wire [31:0] A_Q;                //  Output from register A to bus
    wire [31:0] B_Q;                //  Output from register B to bus
    wire [31:0] alu_result;         //  Result from ALU
    //
    //  Register A
    //
    register reg_A (
        .A(bus),
        .LE(load_A),
        .OE_n(~a_to_bus),           //  Output to bus when a_to_bus is high (active low OE_n)
        .Q(A_Q),                    //  Output to bus
        .to_alu(A_to_alu)
    );

    //
    //  Register B
    //
    register reg_B (
        .A(bus),
        .LE(load_B),
        .OE_n(~b_to_bus),           //  Output to bus when b_to_bus is high (active low OE_n)
        .Q(B_Q),                    //  Output to bus
        .to_alu(B_to_alu)
    );

    //
    //  ALU
    //
    alu simple_alu (
        .A(A_to_alu),
        .B(B_to_alu),
        .SUB(alu_sub),
        .OE_n(~alu_to_bus),        //  Output to bus when alu_to_bus is high (active low OE_n)
        .RESULT(alu_result)
    );

    //
    //  Bus connections
    //  Use tristate logic to drive the bus based on control signals
    //  Control signals should be mutually exclusive to avoid bus contention
    //
    assign bus = a_to_bus ? A_Q : 32'bz;
    assign bus = b_to_bus ? B_Q : 32'bz;
    assign bus = alu_to_bus ? alu_result : 32'bz;

endmodule
