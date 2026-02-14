module delay #(
    parameter WIDTH = 1,
    parameter DEPTH = 16
)(
    input  wire clk,
    input  wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] dout
);

reg [WIDTH-1:0] shift [0:DEPTH-1];
integer i;

always @(posedge clk) begin
    shift[0] <= din;
    for (i = 1; i < DEPTH; i = i + 1)
        shift[i] <= shift[i-1];
end

assign dout = shift[DEPTH-1];

endmodule
