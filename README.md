# Galois LFSR em Verilog — Máximo Período ($2^N - 1$)

Este repositório contém uma biblioteca completa, altamente detalhada e sintetizável de **Registradores de Deslocamento com Realimentação Linear do tipo Galois** (*Galois Linear Feedback Shift Registers* — LFSR) em Verilog, cobrindo todos os tamanhos em potências de 2 ($2^n$) até 64 bits: **2, 4, 8, 16, 32 e 64 bits**.

O projeto inclui esquemáticos de arquitetura RTL desenhados em LaTeX/TikZ seguindo rigorosamente a identidade visual e convenção de níveis de abstração do modelo de referência (`estilo_rtl.tex`), além de testbenches exaustivos com verificação formal em $\mathrm{GF}(2)$.

---

## 1. Visão Geral: Topologia de Galois vs. Fibonacci

Em circuitos digitais e aplicações criptográficas/PRNG, existem duas topologias clássicas de LFSR:

1. **LFSR de Fibonacci (XORs Externos):**
   - Múltiplos taps são lidos do registrador e somados recursivamente por uma cascata ou árvore de portas XOR externa.
   - O resultado escalar é inserido na entrada do primeiro flip-flop ($D_{N-1}$).
   - **Gargalo:** O atraso de propagação combinacional cresce proporcionalmente ao número de taps e à profundidade da árvore XOR ($O(\log K)$ ou $O(K)$), degradando severamente a frequência máxima de clock ($F_{\max}$) em registradores largos.

2. **LFSR de Galois (XORs Internos / Modular):**
   - O bit expelido na extremidade de saída ($Q_0$ no deslocamento para a direita) atua como bit global de *feedback* ($fb$).
   - Esse bit é distribuído em paralelo e aplicado a portas XOR situadas **internamente entre os flip-flops adjacentes** nos índices definidos pelo polinômio primitivo.
   - **Vantagem Crítica de Temporização:** O atraso combinacional entre quaisquer dois flip-flops consecutivos é de **no máximo UMA porta XOR**, independentemente da largura do registrador ($N = 2, 4, 8, 16, 32$ ou $64$ bits):
     $$T_{\text{caminho crítico}} = t_{\text{cq}} + t_{\text{xor}} + t_{\text{setup}} = O(1)$$
   - Permite frequências de operação na ordem de gigahertz em nós tecnológicos modernos ou FPGAs de alta performance.

---

## 2. Polinômios Primitivos e Período Máximo ($2^N - 1$)

Para que um LFSR atinja o período cíclico máximo de $2^N - 1$ estados não-nulos distintos, o polinômio gerador sobre o corpo de Galois $\mathrm{GF}(2)$:
$$P(x) = x^N + \sum_{k=1}^{N-1} c_k x^k + 1$$
deve ser **primitivo**, o que garante que a raiz $x$ possui ordem estritamente igual a $2^N - 1$ no grupo multiplicativo $\mathrm{GF}(2^N)^*$.

### Tabela de Configuração dos LFSRs ($2^n$ até 64 bits)

| Tamanho ($N$) | Potência ($2^n$) | Polinômio Primitivo $P(x)$ | Taps Intermediários ($x^k$) | Máscara de Taps (`TAPS` em Verilog) | Período Máximo ($2^N - 1$) | Portas XOR Internas |
|:---:|:---:|:---|:---:|:---:|:---:|:---:|
| **2 bits** | $2^1$ | $x^2 + x + 1$ | $1$ | `1'b1` (`0x1`) | **3** | 1 |
| **4 bits** | $2^2$ | $x^4 + x + 1$ | $1$ | `3'b001` (`0x1`) | **15** | 1 |
| **8 bits** | $2^3$ | $x^8 + x^4 + x^3 + x^2 + 1$ | $4, 3, 2$ | `7'h0E` (`0b0001110`) | **255** | 3 |
| **16 bits** | $2^4$ | $x^{16} + x^{12} + x^3 + x + 1$ | $12, 3, 1$ | `15'h0805` | **65.535** | 3 |
| **32 bits** | $2^5$ | $x^{32} + x^{22} + x^2 + x + 1$ | $22, 2, 1$ | `31'h0020_0003` | **4.294.967.295** | 3 |
| **64 bits** | $2^6$ | $x^{64} + x^4 + x^3 + x + 1$ | $4, 3, 1$ | `63'h0000_0000_0000_000D` | **18.446.744.073.709.551.615** | 3 |

> [!NOTE]
> Todos os polinômios foram formalmente verificados pelo script `scripts/verify_polynomials.py` testando a ordem multiplicativa sobre $\mathrm{GF}(2)$ para cada fator primo de $2^N - 1$.

---

## 3. Equações Lógicas de Próximo Estado (Deslocamento à Direita)

Definindo o estado atual como $Q = [Q_{N-1}, Q_{N-2}, \dots, Q_1, Q_0]$ e o bit de feedback $fb = Q_0$:
- **MSB:** $D_{N-1} = fb$
- **Estágios Intermediários ($i = 0, \dots, N-2$):**
  $$D_i = \begin{cases} Q_{i+1} \oplus fb, & \text{se } c_{i+1} = 1 \text{ (tap ativo)} \\ Q_{i+1}, & \text{se } c_{i+1} = 0 \text{ (deslocamento puro)} \end{cases}$$

### Exemplos Diretos de Implementação:
- **2 bits:** $D_1 = Q_0$, $D_0 = Q_1 \oplus Q_0$
- **4 bits:** $D_3 = Q_0$, $D_2 = Q_3$, $D_1 = Q_2$, $D_0 = Q_1 \oplus Q_0$
- **8 bits:** $D_7 = Q_0$, $D_6 = Q_7$, $D_5 = Q_6$, $D_4 = Q_5$, $D_3 = Q_4 \oplus Q_0$, $D_2 = Q_3 \oplus Q_0$, $D_1 = Q_2 \oplus Q_0$, $D_0 = Q_1$

---

## 4. Recursos dos Módulos em Verilog

Cada módulo Verilog implementa uma interface completa para integração em SoCs:
- `clk`: Relógio de sistema (borda de subida).
- `rst_n`: Reset assíncrono ativo em nível baixo (restaura `DEFAULT_SEED`).
- `sync_rst`: Reset síncrono ativo em nível alto.
- `en`: Clock enable (quando em nível baixo, congela o estado sem consumir potência dinâmica).
- `load`: Carga síncrona paralela de semente.
- `seed_data`: Vetor de semente personalizado $[N-1:0]$.
- `q`: Vetor de estado completo $[N-1:0]$.
- `lfsr_out`: Bit serial pseudoaleatório ($Q_0$).
- `max_tick`: Pulso ativo em nível alto quando o LFSR retorna ao estado inicial (sinalizador de período completo).
- **Proteção Anti-Travamento (Lockup Protection):** Em caso de perturbação externa (ruído SEU) que force o estado para todos os bits em zero ($00\dots0$, único estado absorvente do LFSR), a lógica detecta e restaura automaticamente a semente padrão.

---

## 5. Esquemáticos RTL em LaTeX / TikZ

Os esquemáticos foram gerados com base rigorosa no modelo `@rtl` (`estilo_rtl.tex`), dividindo os circuitos em níveis funcionais verticais delimitados por traços tracejados e números circulados:

- **Nível 1:** Barramento de controle (`clk`, `rst_n`, `en`, `load`) e realimentação.
- **Nível 2:** Lógica combinacional de tap com portas XOR internas ($D_i = Q_{i+1} \oplus Q_0$).
- **Nível 3:** Multiplexadores de carga de semente síncrona.
- **Nível 4:** Banco de Flip-Flops tipo D ($Q[N-1..0]$).
- **Nível 5:** Saída paralela $q[N-1..0]$ e serial $lfsr\_out$.

O arquivo mestre `diagramas_rtl/diagramas_galois.tex` compila via `pdflatex` gerando `diagramas_galois.pdf`. Versões renderizadas em alta definição (150 DPI) estão disponíveis em `diagramas_rtl/img/`:
- `diagramas_rtl/img/page-1.png`: Arquitetura geral do LFSR de Galois e célula elementar bit-slice.
- `diagramas_rtl/img/page-2.png`: Esquemáticos RTL detalhados dos LFSRs de 2 bits e 4 bits.
- `diagramas_rtl/img/page-3.png`: Esquemático RTL do LFSR de 8 bits e arquitetura modular de alta largura (16, 32 e 64 bits).

---

## 6. Estrutura do Repositório

```text
galois_LFSR/
├── .gitignore
├── README.md
├── rtl/
│   ├── galois_lfsr_param.v        # Módulo genérico parametrizado (WIDTH e TAPS arbitrários)
│   ├── galois_lfsr_2bit.v         # LFSR 2 bits (2^1): P(x) = x^2 + x + 1
│   ├── galois_lfsr_4bit.v         # LFSR 4 bits (2^2): P(x) = x^4 + x + 1
│   ├── galois_lfsr_8bit.v         # LFSR 8 bits (2^3): P(x) = x^8 + x^4 + x^3 + x^2 + 1
│   ├── galois_lfsr_16bit.v        # LFSR 16 bits (2^4): P(x) = x^16 + x^12 + x^3 + x + 1
│   ├── galois_lfsr_32bit.v        # LFSR 32 bits (2^5): P(x) = x^32 + x^22 + x^2 + x + 1
│   └── galois_lfsr_64bit.v        # LFSR 64 bits (2^6): P(x) = x^64 + x^4 + x^3 + x + 1
├── tb/
│   ├── tb_galois_lfsr_2bit.v      # Testbench com verificação exaustiva dos 3 estados
│   ├── tb_galois_lfsr_4bit.v      # Testbench com verificação exaustiva dos 15 estados
│   ├── tb_galois_lfsr_8bit.v      # Testbench com verificação exaustiva dos 255 estados
│   ├── tb_galois_lfsr_16bit.v     # Testbench com ciclo exaustivo de 65.535 estados
│   ├── tb_galois_lfsr_32bit.v     # Testbench de 10.000 ciclos comparado com vetores padrão
│   ├── tb_galois_lfsr_64bit.v     # Testbench de 10.000 ciclos comparado com vetores padrão
│   └── tb_galois_lfsr_all.v       # Co-simulação cruzada (módulos dedicados vs parametrizados)
├── sim/
│   ├── Makefile                   # Regras de compilação com Icarus Verilog
│   └── run_all.sh                 # Script bash para rodar toda a suíte de simulações
├── diagramas_rtl/
│   ├── estilo_rtl.tex             # Estilo TikZ e símbolos gráficos
│   ├── rtl_galois_geral.tex       # TikZ: Arquitetura Geral
│   ├── rtl_galois_estagio.tex     # TikZ: Célula Bit-Slice
│   ├── rtl_galois_2bit.tex        # TikZ: RTL LFSR 2 bits
│   ├── rtl_galois_4bit.tex        # TikZ: RTL LFSR 4 bits
│   ├── rtl_galois_8bit.tex        # TikZ: RTL LFSR 8 bits
│   ├── rtl_galois_largos.tex      # TikZ: Arquitetura 16, 32 e 64 bits
│   ├── diagramas_galois.tex       # Documento mestre LaTeX
│   ├── diagramas_galois.pdf       # Documento PDF compilado
│   └── img/                       # Imagens PNG em alta resolução
└── scripts/
    ├── verify_polynomials.py      # Verificação formal algébrica em GF(2)
    └── generate_test_vectors.py   # Gerador de vetores e tabelas de ciclo
```

---

## 7. Como Executar as Simulações e Verificações

### Pré-requisitos
- **Icarus Verilog** (`iverilog`) e `vvp`
- **pdfTeX / TeX Live** (com TikZ)
- **Python 3**

### Execução da Suíte Completa de Testes Verilog
```bash
cd sim
./run_all.sh
```
Ou com `make`:
```bash
cd sim
make all
```

### Verificação Algébrica dos Polinômios Primitivos
```bash
python3 scripts/verify_polynomials.py
```

### Recompilação dos Diagramas RTL em PDF
```bash
cd diagramas_rtl
pdflatex -interaction=nonstopmode diagramas_galois.tex
```
