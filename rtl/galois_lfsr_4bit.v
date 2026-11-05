// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module galois_lfsr_4bit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sync_rst,
    input  wire        en,
    input  wire        load,
    input  wire [3:0]  seed_data,
    output reg  [3:0]  q,
    output wire        lfsr_out,
    output wire        max_tick
);

    localparam [3:0] DEFAULT_SEED = 4'h1;

    wire fb = q[0];
    wire [3:0] next_q;

    assign next_q[3] = fb;
    assign next_q[2] = q[3];
    assign next_q[1] = q[2];
    assign next_q[0] = q[1] ^ fb;

    assign lfsr_out = q[0];
    assign max_tick = (q == DEFAULT_SEED) & en;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= DEFAULT_SEED;
        end else if (sync_rst) begin
            q <= DEFAULT_SEED;
        end else if (load) begin
            q <= (seed_data == 4'h0) ? DEFAULT_SEED : seed_data;
        end else if (en) begin
            if (q == 4'h0) begin
                q <= DEFAULT_SEED;
            end else begin
                q <= next_q;
            end
        end
    end

endmodule
