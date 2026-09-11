`timescale 1ns/1ps

module mac_tb;
    reg clk, rst;
    reg  [7:0]  weight, act_in;
    reg  [16:0] sum_in;
    wire [7:0]  act_out;
    wire [16:0] sum_out;

    // DUT (device under test)
    mac_unit dut (
        .clk(clk), .rst(rst),
        .weight(weight), .act_in(act_in), .sum_in(sum_in),
        .act_out(act_out), .sum_out(sum_out)
    );

    // clock generator
    initial clk = 0;
    always #5 clk = ~clk;


    initial begin
        $dumpfile("mac.vcd");        // for waveform viewing
        $dumpvars(0, mac_tb);

        rst = 1; weight = 0; act_in = 0; sum_in = 0;
        #10 rst = 0;                 // release reset after one clock

        // test: 3 * 4 + 5 should give 17
        weight = 3; act_in = 4; sum_in = 5;
        #10;                         // wait one clock
        $display("sum_out = %d (expected 17)", sum_out);

        #20 $finish;
    end
endmodule