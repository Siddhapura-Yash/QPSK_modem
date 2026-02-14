module bpsk_tx (
    input  wire clk,
    input  wire rst,
    input  wire [1:0]bit_in,
    input  wire [31:0] phase_step,
    output wire signed [15:0] bpsk_out,
    output wire signed [15:0] bpsk_out_2,
    output wire signed [15:0] qpsk_out
);

wire [31:0] phase;
wire signed [15:0] sine, cosine;

// CORDIC input scaling
localparam signed [15:0] An = 16'sd16384;

// Phase accumulator
phase_accumulator PA (
    .clk(clk),
    .rst(rst),
    .phase_step(phase_step),
    .phase(phase)
);

// CORDIC NCO
CORDIC cordic_inst (
    .clock(clk),
    .x_start(An),
    .y_start(16'b0),
    .angle(phase),
    .cosine(cosine),
    .sine(sine)
);

// BPSK modulation
bpsk_mod mod_inst (
    .carrier(cosine),
    .bit_in(bit_in[1]),
    .bpsk_out(bpsk_out)
);

bpsk_mod mod_inst2 (
    .carrier(sine),
    .bit_in(bit_in[0]),
    .bpsk_out(bpsk_out_2)
);

//assign qpsk_out = bpsk_out_2 - bpsk_out;
// assign qpsk_out = bpsk_out + bpsk_out_2;

wire signed [20:0] sum;

assign sum = bpsk_out + bpsk_out_2;
assign qpsk_out = sum >>> 1;

endmodule
