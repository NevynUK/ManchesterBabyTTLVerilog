//
//  Verilog macros for the SSEM project.
//

//
//  ABORT_IF(condition, message)
//
//  If condition is true, display the message and terminate the simulation.
//  If condition is false, do nothing.
//  Message should be a pre-formatted string.
//
`define ABORT_IF(condition, message) \
    if (condition) \
    begin \
        $display("ERROR: ", message); \
        $finish; \
    end
