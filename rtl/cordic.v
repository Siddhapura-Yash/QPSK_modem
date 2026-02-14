module CORDIC #(
    parameter WIDTH = 16
)(
    input  wire                         clock,
    input  wire signed [WIDTH-1:0]      x_start,
    input  wire signed [WIDTH-1:0]      y_start,
    input  wire signed [31:0]           angle,
    output wire signed [WIDTH-1:0]      cosine,
    output wire signed [WIDTH-1:0]      sine
);

    // atan lookup table
    wire signed [31:0] atan_table [0:WIDTH-1];

    assign atan_table[00] = 32'b00100000000000000000000000000000;
    assign atan_table[01] = 32'b00010010111001000000010100011101;
    assign atan_table[02] = 32'b00001001111110110011100001011011;
    assign atan_table[03] = 32'b00000101000100010001000111010100;
    assign atan_table[04] = 32'b00000010100010110000110101000011;
    assign atan_table[05] = 32'b00000001010001011101011111100001;
    assign atan_table[06] = 32'b00000000101000101111011000011110;
    assign atan_table[07] = 32'b00000000010100010111110001010101;
    assign atan_table[08] = 32'b00000000001010001011111001010011;
    assign atan_table[09] = 32'b00000000000101000101111100101110;
    assign atan_table[10] = 32'b00000000000010100010111110011000;
    assign atan_table[11] = 32'b00000000000001010001011111001100;
    assign atan_table[12] = 32'b00000000000000101000101111100110;
    assign atan_table[13] = 32'b00000000000000010100010111110011;
    assign atan_table[14] = 32'b00000000000000001010001011111001;
    assign atan_table[15] = 32'b00000000000000000101000101111100;

    // pipeline registers
    reg signed [WIDTH:0] x [0:WIDTH-1];
    reg signed [WIDTH:0] y [0:WIDTH-1];
    reg signed [31:0]    z [0:WIDTH-1];

    // quadrant correction
    wire [1:0] quadrant = angle[31:30];

    always @(posedge clock) begin
        case (quadrant)
            2'b00, 2'b11: begin
                x[0] <= x_start;
                y[0] <= y_start;
                z[0] <= angle;
            end

            2'b01: begin
                x[0] <= -y_start;
                y[0] <=  x_start;
                z[0] <= {2'b00, angle[29:0]};
            end

            2'b10: begin
                x[0] <=  y_start;
                y[0] <= -x_start;
                z[0] <= {2'b11, angle[29:0]};
            end
        endcase
    end

    // iterations
    genvar i;
    generate
        for (i = 0; i < WIDTH-1; i = i + 1) begin : cordic_stage
            wire z_sign = z[i][31];
            wire signed [WIDTH:0] x_shr = x[i] >>> i;
            wire signed [WIDTH:0] y_shr = y[i] >>> i;

            always @(posedge clock) begin
                if (z_sign) begin
                    x[i+1] <= x[i] + y_shr;
                    y[i+1] <= y[i] - x_shr;
                    z[i+1] <= z[i] + atan_table[i];
                end
                else begin
                    x[i+1] <= x[i] - y_shr;
                    y[i+1] <= y[i] + x_shr;
                    z[i+1] <= z[i] - atan_table[i];
                end
            end
        end
    endgenerate

    assign cosine = x[WIDTH-1];
    assign sine   = y[WIDTH-1];

endmodule
