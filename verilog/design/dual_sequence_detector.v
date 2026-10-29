`timescale 1ns / 1ps
// Lab 7 Part 1: Mealy FSM that detects 010 or 1001 (overlapping allowed)
module dual_sequence_detector(
    input  clk,
    input  reset_n,   // asynchronous, active-low
    input  x,
    output y
);
    // state encoding (what each state remembers)
    localparam S0 = 3'd0,   // reset
               S1 = 3'd1,   // "0"
               S2 = 3'd2,   // "01"
               S3 = 3'd3,   // "10" (or "010")
               S4 = 3'd4,   // "1"
               S5 = 3'd5;   // "100"

    reg [2:0] state_reg, state_next;

    // state register
    always @(posedge clk, negedge reset_n)
    begin
        if (~reset_n)
            state_reg <= S0;
        else
            state_reg <= state_next;
    end

    // next-state logic
    always @(*)
    begin
        case (state_reg)
            S0:      state_next = x ? S4 : S1;
            S1:      state_next = x ? S2 : S1;
            S2:      state_next = x ? S4 : S3;
            S3:      state_next = x ? S2 : S5;
            S4:      state_next = x ? S4 : S3;
            S5:      state_next = x ? S2 : S1;
            default: state_next = S0;
        endcase
    end

    // Mealy output logic: 010 found (S2, x=0) or 1001 found (S5, x=1)
    assign y = ((state_reg == S2) & ~x) | ((state_reg == S5) & x);

endmodule
