module mac_unit#(
    parameter WIDTH = 8, //8-bit integer
    parameter N = 2, // Size of matrix being multiplied
    parameter SUM_WIDTH = (WIDTH*2) + $clog2(N) + 1 // +1 guard bit
)(
    input clk,
    input rst,
    input [WIDTH-1:0] weight,
    input [WIDTH-1:0] act_in,
    input [SUM_WIDTH-1:0] sum_in,
    output reg [WIDTH-1:0] act_out, //goes up
    output reg [SUM_WIDTH-1:0] sum_out //goes right
);

    always @(posedge clk) begin
        if (rst) begin
            act_out <= 0;
            sum_out <= 0;
        end else begin
            act_out <= act_in;
            sum_out <= sum_in + (weight*act_in);
        end
    end

endmodule