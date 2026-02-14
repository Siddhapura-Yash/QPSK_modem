module bpsk_mod (
    input  wire signed [15:0] carrier,
    input  wire bit_in,
    output wire signed [15:0] bpsk_out
);

assign bpsk_out = bit_in ? carrier : -carrier;

endmodule
