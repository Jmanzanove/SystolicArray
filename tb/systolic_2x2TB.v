`timescale 1ns/1ps

module systolic_2x2TB();

    reg clk, rst;
    reg [7:0] weights [0:1][0:1];
    reg [7:0] acts [0:1][0:1];
    reg [7:0] act_in_cols[0:1];
    wire [17:0] sum_out_row_bot, sum_out_row_top;

    systolic_2x2 dut (
        .clk(clk), .rst(rst), 
        .weights(weights), .act_in_cols(act_in_cols),
        .sum_out_row_bot(sum_out_row_bot), .sum_out_row_top(sum_out_row_top)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin 
        $dumpfile("systolic_2x2.vcd");
        $dumpvars(0, systolic_2x2TB);

        // Clear values
        rst = 1; 
        weights[0][0] = 0; weights[0][1] = 0; // AUTOMATE LATER
        weights[1][0] = 0; weights[1][1] = 0;
        act_in_cols[0] = 0; act_in_cols[1] = 0;
        #10 rst = 0;

        //Set weights
        weights[0][0] = 8'd1; weights[0][1] = 8'd2;
        weights[1][0] = 8'd3; weights[1][1] = 8'd4;
        
        /* Transposed and delayed for feeding
            Cycle:    1    2    3
            Col 1:    -    7    8      <- row 1 of B: [7, 8], delayed 1 cycle
            Col 0:    5    6    -      <- row 0 of B: [5, 6]
        */

        //Set activation vector one row at a time
        
        // Cycle 1
        act_in_cols[1] = 8'd0;
        act_in_cols[0] = 8'd5;
            // wait a cycle for the stuff to calculate
            #10;
            // Check output
            $display("sum_out = [%d, %d] ([0,0])", sum_out_row_bot, sum_out_row_top);
        
        // Cycle 2
        act_in_cols[1] = 8'd7;
        act_in_cols[0] = 8'd6;
            #10;
            $display("sum_out = [%d, %d] ([43,0])", sum_out_row_bot, sum_out_row_top);

        // Cycle 3
        act_in_cols[1] = 8'd8;
        act_in_cols[0] = 8'd0;
            #10;
            $display("sum_out = [%d, %d] ([50,19])", sum_out_row_bot, sum_out_row_top);

        // Cycle 4 - DRAIN
            #10;
            $display("sum_out = [%d, %d] ([32,22])", sum_out_row_bot, sum_out_row_top);
        /*THE 32 COMES FROM the activation remaining in the MAC after use since
          there is no output for the activation value at the top ()*/ 
        #20;
        $finish;
    end
endmodule