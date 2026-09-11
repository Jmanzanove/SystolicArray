module systolic_2x2 #(
    parameter WIDTH = 8,
    parameter N = 2,
    parameter SUM_WIDTH = (WIDTH*2) + $clog2(N) + 1   // same formula
)(
    input  clk, rst,
    input  [WIDTH-1:0] weights [0:1][0:1],
    input  [WIDTH-1:0] act_in_cols[0:1],
    output [SUM_WIDTH-1:0] sum_out_row_top, sum_out_row_bot
);

    // internal wires
    wire [WIDTH-1:0]     act_BL_to_TL, act_BR_to_TR;
    wire [SUM_WIDTH-1:0] sum_TL_to_TR, sum_BL_to_BR;
    wire [WIDTH-1:0]     act_top_out_L, act_top_out_R;  // unused, exits top

    // AUTOMATE LATER
    //(0,0)
    mac_unit mac_TL (
        .clk(clk), .rst(rst),
        .weight(weights[0][0]),
        .act_in(act_BL_to_TL),            // gets activation from below
        .sum_in({SUM_WIDTH{1'b0}}),       // leftmost: no sum coming in
        .act_out(act_top_out_L),          // top activation unused
        .sum_out(sum_TL_to_TR)            // sends sum right
    );
    //(1,0)
    mac_unit mac_BL (
        .clk(clk), .rst(rst),
        .weight(weights[1][0]),
        .act_in(act_in_cols[0]),             // activation vector
        .sum_in({SUM_WIDTH{1'b0}}),          // leftmost: no sum in
        .act_out(act_BL_to_TL),              // sends activation up
        .sum_out(sum_BL_to_BR)               // sends sum right
    );
    //(0,1)
    mac_unit mac_TR (
        .clk(clk), .rst(rst),
        .weight(weights[0][1]),
        .act_in(act_BR_to_TR),               // activation from below
        .sum_in(sum_TL_to_TR),               // sum in from left (0,0)
        .act_out(act_top_out_R),             // sends activation up
        .sum_out(sum_out_row_top)            // sends sum out of grid
    );
    //(1,1)
    mac_unit mac_BR (
        .clk(clk), .rst(rst),
        .weight(weights[1][1]),
        .act_in(act_in_cols[1]),             // activation vector
        .sum_in(sum_BL_to_BR),               // sum from left (1,0)
        .act_out(act_BR_to_TR),              // sends activation up
        .sum_out(sum_out_row_bot)            // Sends sum out of grid
    );
    
endmodule