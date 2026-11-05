// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module tb_galois_lfsr_4bit;

    reg        clk;
    reg        rst_n;
    reg        sync_rst;
    reg        en;
    reg        load;
    reg  [3:0] seed_data;
    wire [3:0] q;
    wire       lfsr_out;
    wire       max_tick;

    galois_lfsr_4bit dut (
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

    always #10 clk = ~clk;

    integer cycle_count;
    integer visited [0:15];
    integer i;

    initial begin
        clk = 0;
        rst_n = 0;
        sync_rst = 0;
        en = 0;
        load = 0;
        seed_data = 4'h0;
        cycle_count = 0;
        for (i = 0; i < 16; i = i + 1) visited[i] = 0;

        #35;
        rst_n = 1;
        #20;

        en = 1;
        @(posedge clk);

        while (cycle_count < 15) begin
            cycle_count = cycle_count + 1;
            visited[q] = visited[q] + 1;
            $display("Ciclo %2d: q = %4b (dec %2d), out = %b, max_tick = %b", cycle_count, q, q, lfsr_out, max_tick);
            if (visited[q] > 1) begin
                $display("[ERRO] Estado %d repetido prematuramente no ciclo %0d!", q, cycle_count);
                $stop;
            end
            @(posedge clk);
        end

        if (visited[0] !== 0) begin
            $display("[ERRO] Estado 0 foi visitado!");
            $stop;
        end
        for (i = 1; i <= 15; i = i + 1) begin
            if (visited[i] !== 1) begin
                $display("[ERRO] Estado %0d visitado %0d vezes!", i, visited[i]);
                $stop;
            end
        end

        if (q !== 4'h1) begin
            $display("[ERRO] Falha ao retornar ao estado inicial após 15 ciclos!");
            $stop;
        end

        $display("[SUCESSO] Todos os 15 estados não-nulos visitados (Período Máximo = 15)!");
        $display("==================================================");
        $display(" TESTE LFSR 4 BITS: TODOS OS TESTES PASSARAM!     ");
        $display("==================================================");
        $finish;
    end

endmodule
