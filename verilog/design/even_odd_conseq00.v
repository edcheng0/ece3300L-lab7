`timescale 1ns / 1ps
// Lab 7 Part 1: Moore FSM, y = 1 when the input has had an odd number of 1s
// AND has contained two consecutive 0s (00)
module even_odd_conseq00(
    input  clk,
    input  reset_n,   // asynchronous, active-low
    input  x,
    output y
);
    // state encoding
    localparam S0 = 3'd0,   // reset, even 1s, no 00
               S1 = 3'd1,   // odd 1s,  no 00
               S2 = 3'd2,   // even 1s, last bit 0
               S3 = 3'd3,   // even 1s, 00 seen
               S4 = 3'd4,   // odd 1s,  00 seen -> y = 1
               S5 = 3'd5;   // odd 1s,  last bit 0

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
            S0:      state_next = x ? S1 : S2;
            S1:      state_next = x ? S0 : S5;
            S2:      state_next = x ? S1 : S3;
            S3:      state_next = x ? S4 : S3;
            S4:      state_next = x ? S3 : S4;
            S5:      state_next = x ? S0 : S4;
            default: state_next = S0;
        endcase
    end

    // Moore output logic
    assign y = (state_reg == S4);

endmodule
