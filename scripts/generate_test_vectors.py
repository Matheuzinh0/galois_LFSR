#!/usr/bin/env python3
# Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

def step_galois(q, n, taps_mask):
    fb = q & 1
    d = q >> 1
    if fb:
        d ^= (1 << (n - 1))
        for i in range(n - 1):
            if (taps_mask >> i) & 1:
                d ^= (1 << i)
    return d

def print_table(n, taps_mask, name, max_rows=16):
    print(f"\n--- Tabela de Estados: LFSR {n} bits ({name}) ---")
    print(f"| Ciclo | Estado Hex | Estado Binário | Saída Serial (q[0]) |")
    print(f"|:-----:|:----------:|:--------------:|:-------------------:|")
    q = 1
    for c in range(1, max_rows + 1):
        print(f"| {c:5d} | 0x{q:0{n//4 + (1 if n%4 else 0)}X} | {q:0{n}b} | {q & 1} |")
        q = step_galois(q, n, taps_mask)

if __name__ == "__main__":
    print_table(2, 0b1, "P(x) = x^2 + x + 1", 3)
    print_table(4, 0b001, "P(x) = x^4 + x + 1", 15)
    print_table(8, 0x0E, "P(x) = x^8 + x^4 + x^3 + x^2 + 1", 16)
