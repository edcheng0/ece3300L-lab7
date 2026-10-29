`timescale 1ns / 1ps
// Lab 7 Part 2: detects 111 or 000 (overlapping allowed)
// Moore FSM: y = 1 while the last three (or more) inputs were all the same
module conseq_sequence(
    input  clk,
    input  reset_n,   // asynchronous, active-low
    input  x,
    output y
);
    // state encoding
    localparam S_RESET = 3'd0,   // no bits seen yet
               S_1     = 3'd1,   // last bit 1   (one 1)
               S_11    = 3'd2,   // last bits 11 (two 1s)
               S_111   = 3'd3,   // three or more 1s -> y = 1
               S_0     = 3'd4,   // last bit 0   (one 0)
               S_00    = 3'd5,   // last bits 00 (two 0s)
               S_000   = 3'd6;   // three or more 0s -> y = 1

    reg [2:0] state_reg, state_next;

    // state register
    always @(posedge clk, negedge reset_n)
    begin
        if (~reset_n)
            state_reg <= S_RESET;
        else
            state_reg <= state_next;
    end

    // next-state logic
    always @(*)
    begin
        case (state_reg)
            S_RESET: state_next = x ? S_1   : S_0;
            S_1:     state_next = x ? S_11  : S_0;
            S_11:    state_next = x ? S_111 : S_0;
            S_111:   state_next = x ? S_111 : S_0;
            S_0:     state_next = x ? S_1   : S_00;
            S_00:    state_next = x ? S_1   : S_000;
            S_000:   state_next = x ? S_1   : S_000;
            default: state_next = S_RESET;
        endcase
    end

    // Moore output logic
    assign y = (state_reg == S_111) | (state_reg == S_000);

endmodule
