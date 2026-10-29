`timescale 1ns / 1ps
module even_odd_conseq00_tb;
    reg  clk, reset_n, x;
    wire y;
    integer errors = 0;

    even_odd_conseq00 uut (.clk(clk), .reset_n(reset_n), .x(x), .y(y));

    // 10 ns clock
    localparam T = 10;
    always
    begin
        clk = 1'b0; #(T/2);
        clk = 1'b1; #(T/2);
    end

    // Moore: y depends only on the state, so check y AFTER the clock edge
    task check(input bit_in, input y_exp);
    begin
        @(negedge clk) x = bit_in;
        @(posedge clk) #1;
        if (y !== y_exp)
        begin
            $display("FAIL t=%0t x=%b y=%b expected=%b", $time, x, y, y_exp);
            errors = errors + 1;
        end
    end
    endtask

    task reset;
    begin
        @(negedge clk) reset_n = 1'b0;   // hold reset through a rising edge
        @(posedge clk) #1 reset_n = 1'b1;
    end
    endtask

    initial
    begin
        x = 1'b0; reset_n = 1'b1;
        reset;

        // 1 1 0 1 0 1: parity changes, single 0s only, y stays 0
        check(1,0); check(1,0); check(0,0); check(1,0); check(0,0); check(1,0);
        // 0 0 0: 00 seen but even 1s, y stays 0
        check(0,0); check(0,0); check(0,0);
        // 1 0 1 1: odd -> y=1, 0 keeps it, even -> 0, odd -> 1
        check(1,1); check(0,1); check(1,0); check(1,1);

        // odd 1s first, then 00: y=1
        reset;
        check(1,0); check(0,0); check(0,1);

        if (errors == 0) $display("PASS: all checks passed");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
