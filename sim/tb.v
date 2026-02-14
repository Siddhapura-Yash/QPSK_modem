`timescale 1ns/1ps

module bpsk_modem_tb;

reg clk;
reg rst;
reg [1:0]bit_in;

wire signed [15:0] tx_signal;
wire [1:0]rx_bit;

// carrier control
parameter PHASE_STEP = 32'd85899346;

// symbol timing
parameter SYMBOL_PERIOD = 100;

reg [7:0] sym_count;
reg symbol_tick;

// bit pattern
reg [31:0] bit_sequence = 32'b01_11_00_01_10_01_00_10_11_00_10_01_01_10_00_11;
//reg [7:0]bit_sequence = 8'b00_10_11_01;
reg [4:0] bit_index;

bpsk_modem dut (
    .clk(clk),
    .rst(rst),
    .bit_in(bit_in),
    .symbol_tick(symbol_tick),
    .phase_step(PHASE_STEP),
    .rx_bit(rx_bit),
    .tx_signal(tx_signal)
);

initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        sym_count <= 0;
        symbol_tick <= 0;
    end
    else begin
        if (sym_count == SYMBOL_PERIOD-1) begin
            sym_count <= 0;
            symbol_tick <= 1;
        end
        else begin
            sym_count <= sym_count + 1;
            symbol_tick <= 0;
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        bit_index <= 0;
        bit_in <= 'b0;
    end
 /*   else if(symbol_tick && bit_index == 14) begin
        bit_in <= bit_sequence[15:16];
        bit_index <= bit_index + 2;
    end             */
    else if (symbol_tick) begin
        bit_in <= bit_sequence[bit_index +: 2];
        bit_index <= bit_index + 2;
    end
end

initial begin
    rst = 1;
    #100;
    rst = 0;

    #100000;
    $finish;
end

initial begin
    $monitor("time=%0t  tx_bit=%b  rx_bit=%b",
              $time, bit_in, rx_bit);
end

initial begin
    $dumpfile("bpsk_modem.vcd");
    $dumpvars(0, bpsk_modem_tb);
end

endmodule
