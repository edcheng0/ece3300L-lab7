`timescale 1ns / 1ps
module dual_sequence_detector_tb;
    reg  clk, reset_n, x;
    wire y;
    integer errors = 0;

    dual_sequence_detector uut (.clk(clk), .reset_n(reset_n), .x(x), .y(y));

    // 10 ns clock
    localparam T = 10;
    always
    begin
        clk = 1'b0; #(T/2);
        clk = 1'b1; #(T/2);
    end

    // Mealy: y depends on x, so check y BEFORE the clock edge
    task check(input bit_in, input y_exp);
    begin
        @(negedge clk) x = bit_in;
        #1;
        if (y !== y_exp)
        begin
            $display("FAIL t=%0t x=%b y=%b expected=%b", $time, x, y, y_exp);
            errors = errors + 1;
        end
        @(posedge clk);
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

        // 11001: detects 1001
        check(1,0); check(1,0); check(0,0); check(0,0); check(1,1);
        // 0: 010 overlaps the end of 1001
        check(0,1);
        // 1 1 0 0: 101 and 1100 do not detect
        check(1,0); check(1,0); check(0,0); check(0,0);
        // 0 0 1 0: 000 restarts, then 010 detected
        check(0,0); check(0,0); check(1,0); check(0,1);

        // after reset, a single 0 does not detect
        reset;
        check(0,0);

        if (errors == 0) $display("PASS: all checks passed");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
