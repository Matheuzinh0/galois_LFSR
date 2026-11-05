// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module galois_lfsr_param #(
    parameter integer WIDTH = 8,
    parameter [WIDTH-2:0] TAPS = 7'h0E,
    parameter [WIDTH-1:0] DEFAULT_SEED = {{(WIDTH-1){1'b0}}, 1'b1},
    parameter integer EN_LOCKUP_PROTECTION = 1
)(
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 sync_rst,
    input  wire                 en,
    input  wire                 load,
    input  wire [WIDTH-1:0]     seed_data,
    output reg  [WIDTH-1:0]     q,
    output wire                 lfsr_out,
    output wire                 max_tick
);

    wire fb = q[0];
    wire [WIDTH-1:0] next_q;

    assign next_q[WIDTH-1] = fb;

    genvar i;
    generate
        for (i = 0; i < WIDTH - 1; i = i + 1) begin : gen_galois_stages
            if (TAPS[i] == 1'b1) begin : with_xor
                assign next_q[i] = q[i+1] ^ fb;
            end else begin : direct_wire
                assign next_q[i] = q[i+1];
            end
        end
    endgenerate

    assign lfsr_out = q[0];
    assign max_tick = (q == DEFAULT_SEED) & en;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= DEFAULT_SEED;
        end else if (sync_rst) begin
            q <= DEFAULT_SEED;
        end else if (load) begin
            if (EN_LOCKUP_PROTECTION && (seed_data == {WIDTH{1'b0}})) begin
                q <= DEFAULT_SEED;
            end else begin
                q <= seed_data;
            end
        end else if (en) begin
            if (EN_LOCKUP_PROTECTION && (q == {WIDTH{1'b0}})) begin
                q <= DEFAULT_SEED;
            end else begin
                q <= next_q;
            end
        end
    end

endmodule
