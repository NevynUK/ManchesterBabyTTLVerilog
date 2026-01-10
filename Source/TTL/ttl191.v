//
//  74LS191 - Synchronous 4-bit up/down binary counter with mode control.
//
module ttl191_counter 
#(PROPAGATION_DELAY = 22, RISE_TIME = 1, FALL_TIME = 1)
(
    input wire [3:0] D,     //  4-bit parallel data input.
    input wire CLK,         //  Clock input (active rising edge).
    input wire LOAD_n,      //  Load input (active low).
    input wire CTEN_n,      //  Count enable (active low).
    input wire DOWN_UP_n,   //  Direction: 0 = count up, 1 = count down.
    output reg [3:0] Q,     //  4-bit counter output.
    output reg RCO_n        //  Ripple clock output (active low).
);
    //
    //  Internal counter register.
    //
    reg [3:0] count;
    wire max_min;           //  Internal terminal count signal.

    //
    //  LOAD  CTEN  Function
    //  ----------------------
    //   0     X    Load data from D into counter
    //   1     0    Count up or down based on DOWN_UP_n
    //   1     1    Hold current count
    //
    //  DOWN_UP_n: 0 = count up, 1 = count down.
    //  RCO_n: LOW when at terminal count (15 for up, 0 for down) and CTEN_n is LOW.
    //
    // initial
    // begin
    //     count = 4'b0000;
    //     Q = 4'b0000;
    //     RCO_n = 1'b1;
    // end

    //
    //  Data sheet states that the load operation does not need a clock edge and it overrides the counting operation.
    //
    always @(negedge LOAD_n)
    begin
        count <= D;
    end

    always @(posedge CLK) begin
        if (LOAD_n != 1'b0)                 //  Only count if not loading.
        begin
            if (CTEN_n == 1'b0)
            begin
                if (DOWN_UP_n == 1'b0) 
                begin
                    count <= count + 1;
                end else 
                begin
                     count <= count - 1;
                end
            end
        end
    end
    //
    //  Output assignment
    //
    always @(count)
    begin
        #PROPAGATION_DELAY Q <= count;
    end
    //
    //  Terminal count detection (internal).
    //
    assign max_min = (DOWN_UP_n == 1'b0) ? (count == 4'b1111) : (count == 4'b0000);
    //
    //  RCO_n (ripple clock output) is active low when at terminal count and counting.
    //
    always @(max_min or CTEN_n)
    begin
        RCO_n <= ((max_min == 1'b1) && (CTEN_n == 1'b0)) ? 1'b0 : 1'b1;
    end

endmodule
