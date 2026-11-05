#!/usr/bin/env python3
# Autor: Matheus Sousa, Labotatório de Comunicação e Segurança da Informação, DES-CTG, UFPE.

import sys

POLYNOMIALS = {
    2: {
        "poly_str": "x^2 + x + 1",
        "taps": [1],
        "mask": 0b1,
        "period": (1 << 2) - 1,
        "factors": [3]
    },
    4: {
        "poly_str": "x^4 + x + 1",
        "taps": [1],
        "mask": 0b001,
        "period": (1 << 4) - 1,
        "factors": [3, 5]
    },
    8: {
        "poly_str": "x^8 + x^4 + x^3 + x^2 + 1",
        "taps": [4, 3, 2],
        "mask": (1 << 3) | (1 << 2) | (1 << 1),
        "period": (1 << 8) - 1,
        "factors": [3, 5, 17]
    },
    16: {
        "poly_str": "x^16 + x^12 + x^3 + x + 1",
        "taps": [12, 3, 1],
        "mask": (1 << 11) | (1 << 2) | (1 << 0),
        "period": (1 << 16) - 1,
        "factors": [3, 5, 17, 257]
    },
    32: {
        "poly_str": "x^32 + x^22 + x^2 + x + 1",
        "taps": [22, 2, 1],
        "mask": (1 << 21) | (1 << 1) | (1 << 0),
        "period": (1 << 32) - 1,
        "factors": [3, 5, 17, 257, 65537]
    },
    64: {
        "poly_str": "x^64 + x^4 + x^3 + x + 1",
        "taps": [4, 3, 1],
        "mask": (1 << 3) | (1 << 2) | (1 << 0),
        "period": (1 << 64) - 1,
        "factors": [3, 5, 17, 257, 641, 65537, 6700417]
    }
}

def poly_mul(a, b):
    res = 0
    while b > 0:
        if b & 1:
            res ^= a
        a <<= 1
        b >>= 1
    return res

def poly_mod(a, mod):
    deg = mod.bit_length() - 1
    while a.bit_length() > deg:
        shift = a.bit_length() - 1 - deg
        a ^= (mod << shift)
    return a

def poly_pow_mod(base, exp, mod):
    res = 1
    b = base
    while exp > 0:
        if exp & 1:
            res = poly_mod(poly_mul(res, b), mod)
        b = poly_mod(poly_mul(b, b), mod)
        exp >>= 1
    return res

def verify_all():
    print("=" * 72)
    print("VERIFICAÇÃO FORMAL DE POLINÔMIOS PRIMITIVOS E PERÍODO MÁXIMO (GALOIS LFSR)")
    print("=" * 72)
    for n, data in POLYNOMIALS.items():
        print(f"\n[+] LFSR {n} bits (2^{n.bit_length()-1}):")
        print(f"    Polinômio primitivo: P(x) = {data['poly_str']}")
        print(f"    Taps intermediários: {data['taps']}")
        print(f"    Máscara de Taps (Verilog): 0x{data['mask']:X}")
        print(f"    Período máximo esperado (2^{n} - 1): {data['period']:,}")

        poly_int = (1 << n) | 1
        for t in data['taps']:
            poly_int |= (1 << t)

        order = data['period']
        rem = poly_pow_mod(2, order, poly_int)
        cond1 = (rem == 1)

        cond2 = True
        for p in data['factors']:
            if poly_pow_mod(2, order // p, poly_int) == 1:
                cond2 = False
                print(f"    [FALHA] Divisível na subordem (ordem / {p})!")
                break

        is_prim = cond1 and cond2
        print(f"    Teste de Primitividade GF(2): {'APROVADO (Primitivo)' if is_prim else 'REPROVADO'}")

        if n <= 16:
            state = 1
            cycle = 0
            mask_val = data['mask']
            while True:
                fb = state & 1
                next_state = state >> 1
                if fb:
                    next_state ^= (1 << (n - 1))
                    for idx in range(n - 1):
                        if (mask_val >> idx) & 1:
                            next_state ^= (1 << idx)
                state = next_state
                cycle += 1
                if state == 1:
                    break
            print(f"    Simulação exaustiva ciclo a ciclo: {cycle:,} ciclos (Exato: {cycle == order})")

if __name__ == "__main__":
    verify_all()
