// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module tb_galois_lfsr_8bit;

    reg        clk;
    reg        rst_n;
    reg        sync_rst;
    reg        en;
    reg        load;
    reg  [7:0] seed_data;
    wire [7:0] q;
    wire       lfsr_out;
    wire       max_tick;

    galois_lfsr_8bit dut (
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

    always #5 clk = ~clk;

    integer cycle_count;
    integer visited [0:255];
    integer i;

    initial begin
        clk = 0;
        rst_n = 0;
        sync_rst = 0;
        en = 0;
        load = 0;
        seed_data = 8'h00;
        cycle_count = 0;
        for (i = 0; i < 256; i = i + 1) visited[i] = 0;

        #25;
        rst_n = 1;
        #10;

        en = 1;
        @(posedge clk);

        while (cycle_count < 255) begin
            cycle_count = cycle_count + 1;
            visited[q] = visited[q] + 1;
            if (visited[q] > 1) begin
                $display("[ERRO] Estado %h repetido prematuramente no ciclo %0d!", q, cycle_count);
                $stop;
            end
            @(posedge clk);
        end

        if (visited[0] !== 0) begin
            $display("[ERRO] Estado 0 foi visitado!");
            $stop;
        end
        for (i = 1; i <= 255; i = i + 1) begin
            if (visited[i] !== 1) begin
                $display("[ERRO] Estado %0d visitado %0d vezes!", i, visited[i]);
                $stop;
            end
        end

        if (q !== 8'h01) begin
            $display("[ERRO] Não retornou ao estado inicial no ciclo 256!");
            $stop;
        end

        $display("[SUCESSO] Todos os 255 estados não-nulos visitados com período 255!");
        $display("==================================================");
        $display(" TESTE LFSR 8 BITS: TODOS OS TESTES PASSARAM!     ");
        $display("==================================================");
        $finish;
    end

endmodule
