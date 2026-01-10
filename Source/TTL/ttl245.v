//
//  74LS245 - Octal bus transceiver with 3-state outputs.
//
module ttl245_transceiver 
#(PROPAGATION_DELAY = 32, RISE_TIME = 1, FALL_TIME = 1)
(
    inout wire [7:0] A,    // 8-bit bidirectional bus A.
    inout wire [7:0] B,    // 8-bit bidirectional bus B.
    input wire DIR,        // Direction control: 0 = B to A, 1 = A to B.
    input wire OE_n        // Output Enable (active low, tri-state when high).
);
    //
    //  Internal signals for direction control.
    //
    reg [7:0] A_out;
    reg [7:0] B_out;

    //
    // OE  DIR  Function
    // ----------------------
    //  0   0   B to A
    //  0   1   A to B
    //  1   X   Outputs disabled (high-impedance)
    //
    assign A = ((OE_n == 1'b0) && (DIR == 1'b0)) ? A_out : 8'bz;
    assign B = ((OE_n == 1'b0) && (DIR == 1'b1)) ? B_out : 8'bz;
    
    always @(A or B or DIR or OE_n)
    begin
        if (OE_n == 1'b0)
        begin
            if (DIR == 1'b1)
            begin
                #PROPAGATION_DELAY B_out <= A;
            end else
            begin
                #PROPAGATION_DELAY A_out <= B;
            end
        end else
        begin
            #(PROPAGATION_DELAY)
            A_out <= 8'bz;
            B_out <= 8'bz;
        end
    end

endmodule
