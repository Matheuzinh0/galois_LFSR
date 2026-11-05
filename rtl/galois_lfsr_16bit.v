// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module galois_lfsr_16bit (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         sync_rst,
    input  wire         en,
    input  wire         load,
    input  wire [15:0]  seed_data,
    output reg  [15:0]  q,
    output wire         lfsr_out,
    output wire         max_tick
);

    localparam [15:0] DEFAULT_SEED = 16'h0001;

    wire fb = q[0];
    wire [15:0] next_q;

    assign next_q[15]    = fb;
    assign next_q[14:12] = q[15:13];
    assign next_q[11]    = q[12] ^ fb;
    assign next_q[10:3]  = q[11:4];
    assign next_q[2]     = q[3] ^ fb;
    assign next_q[1]     = q[2];
    assign next_q[0]     = q[1] ^ fb;

    assign lfsr_out = q[0];
    assign max_tick = (q == DEFAULT_SEED) & en;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= DEFAULT_SEED;
        end else if (sync_rst) begin
            q <= DEFAULT_SEED;
        end else if (load) begin
            q <= (seed_data == 16'h0000) ? DEFAULT_SEED : seed_data;
        end else if (en) begin
            if (q == 16'h0000) begin
                q <= DEFAULT_SEED;
            end else begin
                q <= next_q;
            end
        end
    end

endmodule
