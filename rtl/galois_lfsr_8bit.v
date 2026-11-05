// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module galois_lfsr_8bit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sync_rst,
    input  wire        en,
    input  wire        load,
    input  wire [7:0]  seed_data,
    output reg  [7:0]  q,
    output wire        lfsr_out,
    output wire        max_tick
);

    localparam [7:0] DEFAULT_SEED = 8'h01;

    wire fb = q[0];
    wire [7:0] next_q;

    assign next_q[7] = fb;
    assign next_q[6] = q[7];
    assign next_q[5] = q[6];
    assign next_q[4] = q[5];
    assign next_q[3] = q[4] ^ fb;
    assign next_q[2] = q[3] ^ fb;
    assign next_q[1] = q[2] ^ fb;
    assign next_q[0] = q[1];

    assign lfsr_out = q[0];
    assign max_tick = (q == DEFAULT_SEED) & en;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= DEFAULT_SEED;
        end else if (sync_rst) begin
            q <= DEFAULT_SEED;
        end else if (load) begin
            q <= (seed_data == 8'h00) ? DEFAULT_SEED : seed_data;
        end else if (en) begin
            if (q == 8'h00) begin
                q <= DEFAULT_SEED;
            end else begin
                q <= next_q;
            end
        end
    end

endmodule
