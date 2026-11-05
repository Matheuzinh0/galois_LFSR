// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module tb_galois_lfsr_2bit;

    reg        clk;
    reg        rst_n;
    reg        sync_rst;
    reg        en;
    reg        load;
    reg  [1:0] seed_data;
    wire [1:0] q;
    wire       lfsr_out;
    wire       max_tick;

    galois_lfsr_2bit dut (
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
    reg [1:0] initial_state;
    reg done;

    initial begin
        clk = 0;
        rst_n = 0;
        sync_rst = 0;
        en = 0;
        load = 0;
        seed_data = 2'b00;
        cycle_count = 0;
        done = 0;

        #35;
        rst_n = 1;
        #20;

        if (q !== 2'b01) begin
            $display("[ERRO] Estado após reset esperado 2'b01, obtido %b", q);
            $stop;
        end
        $display("[INFO] Reset assíncrono verificado: q = %b", q);

        en = 1;
        initial_state = q;

        @(posedge clk);
        cycle_count = 1;
        $display("Ciclo %0d: q = %b (decimal %0d)", cycle_count, q, q);

        while (!done) begin
            @(posedge clk);
            if (q == initial_state) begin
                $display("[INFO] Retornou ao estado inicial %b após %0d ciclos!", initial_state, cycle_count);
                done = 1;
            end else begin
                cycle_count = cycle_count + 1;
                $display("Ciclo %0d: q = %b (decimal %0d)", cycle_count, q, q);
                if (cycle_count > 10) begin
                    $display("[ERRO] Período excedeu o limite!");
                    $stop;
                end
            end
        end

        if (cycle_count !== 3) begin
            $display("[ERRO] Período esperado 3, obtido %0d", cycle_count);
            $stop;
        end
        $display("[SUCESSO] Período exaustivo de 2 bits (2^2 - 1 = 3) verificado com perfeição!");

        @(negedge clk);
        load = 1;
        seed_data = 2'b10;
        @(negedge clk);
        load = 0;
        if (q !== 2'b10) begin
            $display("[ERRO] Falha no load!");
            $stop;
        end
        $display("[INFO] Carga síncrona verificada: q = %b", q);

        @(negedge clk);
        load = 1;
        seed_data = 2'b00;
        @(negedge clk);
        load = 0;
        if (q == 2'b00) begin
            $display("[ERRO] LFSR aceitou estado nulo sem proteção!");
            $stop;
        end
        $display("[INFO] Proteção anti-travamento validada com sucesso!");

        $display("==================================================");
        $display(" TESTE LFSR 2 BITS: TODOS OS TESTES PASSARAM!     ");
        $display("==================================================");
        $finish;
    end

endmodule
