// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module tb_galois_lfsr_all;

    reg clk;
    reg rst_n;
    reg sync_rst;
    reg en;
    reg load;

    wire [1:0] q2_ded, q2_par;
    wire out2_ded, out2_par;
    wire tick2_ded, tick2_par;

    wire [3:0] q4_ded, q4_par;
    wire out4_ded, out4_par;
    wire tick4_ded, tick4_par;

    wire [7:0] q8_ded, q8_par;
    wire out8_ded, out8_par;
    wire tick8_ded, tick8_par;

    wire [15:0] q16_ded, q16_par;
    wire out16_ded, out16_par;
    wire tick16_ded, tick16_par;

    wire [31:0] q32_ded, q32_par;
    wire out32_ded, out32_par;
    wire tick32_ded, tick32_par;

    wire [63:0] q64_ded, q64_par;
    wire out64_ded, out64_par;
    wire tick64_ded, tick64_par;

    galois_lfsr_2bit u_ded2 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(2'b01), .q(q2_ded), .lfsr_out(out2_ded), .max_tick(tick2_ded)
    );
    galois_lfsr_param #(.WIDTH(2), .TAPS(1'b1)) u_par2 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(2'b01), .q(q2_par), .lfsr_out(out2_par), .max_tick(tick2_par)
    );

    galois_lfsr_4bit u_ded4 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(4'h1), .q(q4_ded), .lfsr_out(out4_ded), .max_tick(tick4_ded)
    );
    galois_lfsr_param #(.WIDTH(4), .TAPS(3'b001)) u_par4 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(4'h1), .q(q4_par), .lfsr_out(out4_par), .max_tick(tick4_par)
    );

    galois_lfsr_8bit u_ded8 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(8'h01), .q(q8_ded), .lfsr_out(out8_ded), .max_tick(tick8_ded)
    );
    galois_lfsr_param #(.WIDTH(8), .TAPS(7'h0E)) u_par8 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(8'h01), .q(q8_par), .lfsr_out(out8_par), .max_tick(tick8_par)
    );

    galois_lfsr_16bit u_ded16 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(16'h0001), .q(q16_ded), .lfsr_out(out16_ded), .max_tick(tick16_ded)
    );
    galois_lfsr_param #(.WIDTH(16), .TAPS(15'h0805)) u_par16 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(16'h0001), .q(q16_par), .lfsr_out(out16_par), .max_tick(tick16_par)
    );

    galois_lfsr_32bit u_ded32 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(32'h0000_0001), .q(q32_ded), .lfsr_out(out32_ded), .max_tick(tick32_ded)
    );
    galois_lfsr_param #(.WIDTH(32), .TAPS(31'h0020_0003)) u_par32 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(32'h0000_0001), .q(q32_par), .lfsr_out(out32_par), .max_tick(tick32_par)
    );

    galois_lfsr_64bit u_ded64 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(64'h1), .q(q64_ded), .lfsr_out(out64_ded), .max_tick(tick64_ded)
    );
    galois_lfsr_param #(.WIDTH(64), .TAPS(63'h0000_0000_0000_000D)) u_par64 (
        .clk(clk), .rst_n(rst_n), .sync_rst(sync_rst), .en(en),
        .load(load), .seed_data(64'h1), .q(q64_par), .lfsr_out(out64_par), .max_tick(tick64_par)
    );

    always #2 clk = ~clk;

    integer cycle;

    initial begin
        clk = 0;
        rst_n = 0;
        sync_rst = 0;
        en = 0;
        load = 0;

        #25;
        rst_n = 1;
        #10;
        en = 1;

        $display("Iniciando co-simulacao e comparacao cruzada...");
        for (cycle = 1; cycle <= 20000; cycle = cycle + 1) begin
            @(posedge clk);
            #0.1;
            if (q2_ded !== q2_par) begin
                $display("[ERRO] Divergencia 2-bit no ciclo %0d!", cycle);
                $stop;
            end
            if (q4_ded !== q4_par) begin
                $display("[ERRO] Divergencia 4-bit no ciclo %0d!", cycle);
                $stop;
            end
            if (q8_ded !== q8_par) begin
                $display("[ERRO] Divergencia 8-bit no ciclo %0d!", cycle);
                $stop;
            end
            if (q16_ded !== q16_par) begin
                $display("[ERRO] Divergencia 16-bit no ciclo %0d!", cycle);
                $stop;
            end
            if (q32_ded !== q32_par) begin
                $display("[ERRO] Divergencia 32-bit no ciclo %0d!", cycle);
                $stop;
            end
            if (q64_ded !== q64_par) begin
                $display("[ERRO] Divergencia 64-bit no ciclo %0d!", cycle);
                $stop;
            end
        end

        $display("[SUCESSO] 20.000 ciclos de co-simulacao executados sem nenhuma divergencia!");
        $display("==========================================================================");
        $display(" TESTEBENCH MESTRE INTEGRADO: TODOS OS MODELOS EQUIVALENTES E PASSARAM!   ");
        $display("==========================================================================");
        $finish;
    end

endmodule
