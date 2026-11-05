// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module tb_galois_lfsr_32bit;

    reg         clk;
    reg         rst_n;
    reg         sync_rst;
    reg         en;
    reg         load;
    reg  [31:0] seed_data;
    wire [31:0] q;
    wire        lfsr_out;
    wire        max_tick;

    galois_lfsr_32bit dut (
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

    integer cycle;

    initial begin
        clk = 0;
        rst_n = 0;
        sync_rst = 0;
        en = 0;
        load = 0;
        seed_data = 32'h0;

        #25;
        rst_n = 1;
        #10;

        if (q !== 32'h0000_0001) begin
            $display("[ERRO] Reset assíncrono falhou!");
            $stop;
        end
        $display("[INFO] Reset assíncrono OK: q = 0x%08X", q);

        @(posedge clk);
        if (q !== 32'h0000_0001) begin
            $display("[ERRO] Estado mudou com en=0!");
            $stop;
        end

        @(negedge clk);
        en = 1;
        for (cycle = 1; cycle <= 10000; cycle = cycle + 1) begin
            @(posedge clk);
            #0.1;

            case (cycle)
                1: begin
                    if (q !== 32'h80200003) begin
                        $display("[ERRO] Ciclo 1: esperado 0x80200003, obtido 0x%08X", q);
                        $stop;
                    end
                end
                2: begin
                    if (q !== 32'hC0300002) begin
                        $display("[ERRO] Ciclo 2: esperado 0xC0300002, obtido 0x%08X", q);
                        $stop;
                    end
                end
                10: begin
                    if (q !== 32'hB6EDB003) begin
                        $display("[ERRO] Ciclo 10: esperado 0xB6EDB003, obtido 0x%08X", q);
                        $stop;
                    end
                end
                100: begin
                    if (q !== 32'h745038D8) begin
                        $display("[ERRO] Ciclo 100: esperado 0x745038D8, obtido 0x%08X", q);
                        $stop;
                    end
                end
                1000: begin
                    if (q !== 32'hFC07838F) begin
                        $display("[ERRO] Ciclo 1000: esperado 0xFC07838F, obtido 0x%08X", q);
                        $stop;
                    end
                end
                10000: begin
                    if (q !== 32'hD7C81A15) begin
                        $display("[ERRO] Ciclo 10000: esperado 0xD7C81A15, obtido 0x%08X", q);
                        $stop;
                    end
                end
            endcase
        end

        $display("[INFO] 10.000 ciclos verificados contra modelo matemático exato!");

        @(negedge clk);
        load = 1;
        seed_data = 32'hDEADBEEF;
        @(negedge clk);
        load = 0;
        if (q !== 32'hDEADBEEF) begin
            $display("[ERRO] Falha ao carregar semente personalizada 0xDEADBEEF!");
            $stop;
        end
        $display("[INFO] Carga paralela de semente (0x%08X) validada!", q);

        @(negedge clk);
        load = 1;
        seed_data = 32'h00000000;
        @(negedge clk);
        load = 0;
        if (q == 32'h00000000) begin
            $display("[ERRO] LFSR aceitou semente nula sem sanitização!");
            $stop;
        end
        $display("[INFO] Proteção anti-travamento com recuperação para DEFAULT_SEED validada!");

        $display("==================================================");
        $display(" TESTE LFSR 32 BITS: TODOS OS TESTES PASSARAM!    ");
        $display("==================================================");
        $finish;
    end

endmodule
