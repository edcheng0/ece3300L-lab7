`timescale 1ns / 1ps
module conseq_sequence_tb;
    reg  clk, reset_n, x;
    wire y;
    integer errors = 0;

    conseq_sequence uut (.clk(clk), .reset_n(reset_n), .x(x), .y(y));

    // 10 ns clock
    localparam T = 10;
    always
    begin
        clk = 1'b0; #(T/2);
        clk = 1'b1; #(T/2);
    end

    // apply one input bit, clock it in, then check y
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

    initial
    begin
        x = 1'b0; reset_n = 1'b0;
        #2 reset_n = 1'b1;

        // 1111: detects 111, stays high on the 4th 1 (overlap)
        check(1,0); check(1,0); check(1,1); check(1,1);
        // 00000: detects 000, stays high on the 4th and 5th 0 (overlap)
        check(0,0); check(0,0); check(0,1); check(0,1); check(0,1);
        // 1011 0: broken runs, never detects
        check(1,0); check(0,0); check(1,0); check(1,0); check(0,0);
        // 111: detects after a broken run
        check(1,0); check(1,0); check(1,1);

        // reset clears the output
        @(negedge clk) reset_n = 1'b0;
        #1 if (y !== 1'b0) begin $display("FAIL: reset did not clear y"); errors = errors + 1; end

        if (errors == 0) $display("PASS: all checks passed");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
