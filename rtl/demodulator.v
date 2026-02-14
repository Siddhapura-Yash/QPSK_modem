module demodulator (
    input  wire clk,
    input  wire rst,
    input  wire symbol_tick,          // symbol timing pulse
    input  wire [31:0] phase_step,
    input  wire signed [15:0] rx_signal,
    output reg  [1:0] bit_out
);

wire [31:0] phase;
wire signed [15:0] sine, cosine;

localparam signed [15:0] An = 16'sd16384;

wire symbol_tick_d;
delay #(.WIDTH(1), .DEPTH(16)) sym_delay (
    .clk(clk),
    .din(symbol_tick),
    .dout(symbol_tick_d)
);

phase_accumulator PA (
    .clk(clk),
    .rst(rst),
    .phase_step(phase_step),
    .phase(phase)
);

CORDIC cordic_inst (
    .clock(clk),
    .x_start(An),
    .y_start(16'b0),
    .angle(phase),
    .cosine(cosine),
    .sine(sine)
);

wire signed [31:0] i_mixed;
wire signed [31:0] q_mixed;

assign i_mixed = rx_signal * cosine;
assign q_mixed = rx_signal * sine;

reg signed [47:0] acc_i;
reg signed [47:0] acc_q;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        acc_i   <= 'b0;
        acc_q   <= 'b0;
        bit_out <= 'b0;
    end
    else begin
        if (symbol_tick_d) begin
            // decision
            bit_out[0] <= (acc_i >= 0);  // I
            bit_out[1] <= (acc_q >= 0);  // Q

            // reset integrators
            acc_i <= 0;
            acc_q <= 0;
        end
        else begin
            // integrate
            acc_i <= acc_i + i_mixed;
            acc_q <= acc_q + (q_mixed << 2);
        end
    end
end

/*
always @(posedge clk or posedge rst) begin
    if (rst) begin
        acc_i   <= 'b0;
        acc_q   <= 'b0;
        bit_out <= 'b0;
    end
    else begin
        // integrate
        acc_i <= acc_i + i_mixed;
        acc_q <= acc_q + q_mixed;

        // dump at symbol boundary
        if (symbol_tick) begin
            bit_out[0] <= (acc_i >= 0);  // I bit
            bit_out[1] <= (acc_q >= 0);  // Q bit
            
      //      bit_out[1] <= (acc_i < 0);
         //   bit_out[0] <= (acc_q < 0);

            acc_i <= 0;
            acc_q <= 0;
        end
    end
end                     */

endmodule
