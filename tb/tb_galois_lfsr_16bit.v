// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module tb_galois_lfsr_16bit;

    reg         clk;
    reg         rst_n;
    reg         sync_rst;
    reg         en;
    reg         load;
    reg  [15:0] seed_data;
    wire [15:0] q;
    wire        lfsr_out;
    wire        max_tick;

    galois_lfsr_16bit dut (
        .clk(clk),
        .rst_n(rst_n),
        .sync_rst(sync_rst),
        .en(en),
        .load(load),
        .seed_data(seed_data),
        .q(q),
        .lfsr_out(lfsr_out),
        .max_tick(max_tick)
    );

    always #2 clk = ~clk;

    integer cycle_count;
    reg [15:0] initial_state;
    reg done;

    initial begin
        clk = 0;
        rst_n = 0;
        sync_rst = 0;
        en = 0;
        load = 0;
        seed_data = 16'h0000;
        cycle_count = 0;
        done = 0;

        #15;
        rst_n = 1;
        #10;

        en = 1;
        @(posedge clk);
        initial_state = q;

        while (!done) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;

            if (q == 16'h0000) begin
                $display("[ERRO] Estado nulo atingido no ciclo %0d!", cycle_count);
                $stop;
            end

            if (q == initial_state) begin
                $display("[INFO] Retornou ao estado inicial %h no ciclo %0d!", initial_state, cycle_count);
                done = 1;
            end else if (cycle_count > 70000) begin
                $display("[ERRO] Período excedeu 70.000 sem retornar ao início!");
                $stop;
            end
        end

        if (cycle_count !== 65535) begin
            $display("[ERRO] Período esperado 65.535, obtido %0d!", cycle_count);
            $stop;
        end

        $display("[SUCESSO] LFSR de 16 bits completou exatamente 65.535 ciclos (Período Máximo)!");
        $display("==================================================");
        $display(" TESTE LFSR 16 BITS: TODOS OS TESTES PASSARAM!    ");
        $display("==================================================");
        $finish;
    end

endmodule
