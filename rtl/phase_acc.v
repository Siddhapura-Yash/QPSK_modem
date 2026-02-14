module phase_accumulator (
    input  wire clk,
    input  wire rst,
    input  wire [31:0] phase_step,
    output reg  [31:0] phase
);

always @(posedge clk or posedge rst) begin
    if (rst)
        phase <= 0;
    else
        phase <= phase + phase_step;
end

endmodule
