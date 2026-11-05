// Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

`timescale 1ns / 1ps

module tb_galois_lfsr_64bit;

    reg         clk;
    reg         rst_n;
    reg         sync_rst;
    reg         en;
    reg         load;
    reg  [63:0] seed_data;
    wire [63:0] q;
    wire        lfsr_out;
    wire        max_tick;

    galois_lfsr_64bit dut (
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
        seed_data = 64'h0;

        #25;
        rst_n = 1;
        #10;

        if (q !== 64'h0000_0000_0000_0001) begin
            $display("[ERRO] Reset assíncrono falhou!");
            $stop;
        end
        $display("[INFO] Reset assíncrono OK: q = 0x%016X", q);

        @(posedge clk);
        if (q !== 64'h0000_0000_0000_0001) begin
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
                    if (q !== 64'h800000000000000D) begin
                        $display("[ERRO] Ciclo 1: esperado 0x800000000000000D, obtido 0x%016X", q);
                        $stop;
                    end
                end
                2: begin
                    if (q !== 64'hC00000000000000B) begin
                        $display("[ERRO] Ciclo 2: esperado 0xC00000000000000B, obtido 0x%016X", q);
                        $stop;
                    end
                end
                10: begin
                    if (q !== 64'h71C0000000000004) begin
                        $display("[ERRO] Ciclo 10: esperado 0x71C0000000000004, obtido 0x%016X", q);
                        $stop;
                    end
                end
                100: begin
                    if (q !== 64'h70970970971C71C3) begin
                        $display("[ERRO] Ciclo 100: esperado 0x70970970971C71C3, obtido 0x%016X", q);
                        $stop;
                    end
                end
                1000: begin
                    if (q !== 64'h0B7456288EE6AC27) begin
                        $display("[ERRO] Ciclo 1000: esperado 0x0B7456288EE6AC27, obtido 0x%016X", q);
                        $stop;
                    end
                end
                10000: begin
                    if (q !== 64'h408FAFB08F8F4071) begin
                        $display("[ERRO] Ciclo 10000: esperado 0x408FAFB08F8F4071, obtido 0x%016X", q);
                        $stop;
                    end
                end
            endcase
        end

        $display("[INFO] 10.000 ciclos de 64 bits validados com precisão exata!");

        @(negedge clk);
        load = 1;
        seed_data = 64'hFEEDFACECAFEF00D;
        @(negedge clk);
        load = 0;
        if (q !== 64'hFEEDFACECAFEF00D) begin
            $display("[ERRO] Falha ao carregar semente de 64 bits!");
            $stop;
        end
        $display("[INFO] Carga de semente 64 bits (0x%016X) OK!", q);

        $display("==================================================");
        $display(" TESTE LFSR 64 BITS: TODOS OS TESTES PASSARAM!    ");
        $display("==================================================");
        $finish;
    end

endmodule
