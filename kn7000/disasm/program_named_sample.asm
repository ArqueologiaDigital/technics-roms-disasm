; KN7000 program image - named function disassembly
; 105 functions in [0x48414b8d, 0x4841e000); names from kn7000.sym (MILK-toolkit reflection tables, shared w/ KN5000)
;

SleepMainTask:
48414b8d: f8 fe ec           add     -0x14, sp
48414b90: 00                 clr     d0
48414b91: 42 10              mov     d0, (0x10, sp)
48414b93: fc cc 09 00 02 00  mov     0x00020009, d0
48414b99: fc cd 9d 00 06 00  mov     0x0006009d, d1
48414b9f: cd d8 fe 00 14     call    0x48414a77, 0, 0x14
48414ba4: df 00 14           ret     0, 0x14

WakeUpMainTask:
48414ba7: f8 fe ec           add     -0x14, sp
48414baa: 00                 clr     d0
48414bab: 42 10              mov     d0, (0x10, sp)
48414bad: fc cc 09 00 02 00  mov     0x00020009, d0
48414bb3: fc cd 9e 00 06 00  mov     0x0006009e, d1
48414bb9: cd be fe 00 14     call    0x48414a77, 0, 0x14
48414bbe: df 00 14           ret     0, 0x14

SleepApTask:
48414bc1: f8 fe ec           add     -0x14, sp
48414bc4: 00                 clr     d0
48414bc5: 42 10              mov     d0, (0x10, sp)
48414bc7: fc cc 09 00 02 00  mov     0x00020009, d0
48414bcd: fc cd 9f 00 06 00  mov     0x0006009f, d1
48414bd3: cd 2a ff 00 14     call    0x48414afd, 0, 0x14
48414bd8: df 00 14           ret     0, 0x14

WakeUpApTask:
48414bdb: f8 fe ec           add     -0x14, sp
48414bde: 00                 clr     d0
48414bdf: 42 10              mov     d0, (0x10, sp)
48414be1: fc cc 09 00 02 00  mov     0x00020009, d0
48414be7: fc cd a0 00 06 00  mov     0x000600a0, d1
48414bed: cd 10 ff 00 14     call    0x48414afd, 0, 0x14
48414bf2: df 00 14           ret     0, 0x14

RefreshApTask:
48414bf5: f8 fe ec              add     -0x14, sp
48414bf8: 00                    clr     d0
48414bf9: fc 81 d8 1f 02 50     mov     d0, (0x50021fd8)
48414bff: fc 81 dc 1f 02 50     mov     d0, (0x50021fdc)
48414c05: fc 81 e0 1f 02 50     mov     d0, (0x50021fe0)
48414c0b: 80 ff                 mov     -1, d0
48414c0d: fc cd 06 00 05 00     mov     0x00050006, d1
48414c13: dd f3 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414c1a: 80 ff                 mov     -1, d0
48414c1c: fc cd 05 00 05 00     mov     0x00050005, d1
48414c22: dd e4 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414c29: 80 ff                 mov     -1, d0
48414c2b: fc cd 07 00 05 00     mov     0x00050007, d1
48414c31: dd d5 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414c38: 80 ff                 mov     -1, d0
48414c3a: fc cd 17 00 05 00     mov     0x00050017, d1
48414c40: dd c6 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414c47: 80 ff                 mov     -1, d0
48414c49: fc cd 14 00 05 00     mov     0x00050014, d1
48414c4f: dd b7 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414c56: 80 ff                 mov     -1, d0
48414c58: fc cd 0c 00 05 00     mov     0x0005000c, d1
48414c5e: dd a8 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414c65: 80 ff                 mov     -1, d0
48414c67: fc cd 0d 00 05 00     mov     0x0005000d, d1
48414c6d: dd 99 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414c74: 80 ff                 mov     -1, d0
48414c76: fc cd 0e 00 05 00     mov     0x0005000e, d1
48414c7c: dd 8a 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414c83: 00                    clr     d0
48414c84: 42 10                 mov     d0, (0x10, sp)
48414c86: 80 ff                 mov     -1, d0
48414c88: fc cd a1 00 06 00     mov     0x000600a1, d1
48414c8e: dd 12 4c 01 00 80 1c  call    0x484298a0, [d2], 0x1c
48414c95: df 00 14              ret     0, 0x14

RefreshSwEvent:
48414c98: f8 fe ec              add     -0x14, sp
48414c9b: 00                    clr     d0
48414c9c: fc 81 d8 1f 02 50     mov     d0, (0x50021fd8)
48414ca2: fc 81 dc 1f 02 50     mov     d0, (0x50021fdc)
48414ca8: fc 81 e0 1f 02 50     mov     d0, (0x50021fe0)
48414cae: 80 ff                 mov     -1, d0
48414cb0: fc cd 06 00 05 00     mov     0x00050006, d1
48414cb6: dd 50 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414cbd: 80 ff                 mov     -1, d0
48414cbf: fc cd 05 00 05 00     mov     0x00050005, d1
48414cc5: dd 41 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414ccc: 80 ff                 mov     -1, d0
48414cce: fc cd 07 00 05 00     mov     0x00050007, d1
48414cd4: dd 32 4c 01 00 80 18  call    0x48429906, [d2], 0x18
48414cdb: 00                    clr     d0
48414cdc: 42 10                 mov     d0, (0x10, sp)
48414cde: 80 ff                 mov     -1, d0
48414ce0: fc cd a5 00 06 00     mov     0x000600a5, d1
48414ce6: dd ba 4b 01 00 80 1c  call    0x484298a0, [d2], 0x1c
48414ced: df 00 14              ret     0, 0x14
48414cf0: 80 01                 mov     1, d0
48414cf2: fc 81 ec 1f 02 50     mov     d0, (0x50021fec)
48414cf8: de 00 00              retf    0, 0
48414cfb: 00                    clr     d0
48414cfc: fc 81 ec 1f 02 50     mov     d0, (0x50021fec)
48414d02: de 00 00              retf    0, 0
48414d05: cf f0                 movm    [d2,d3,a2,a3], (sp)
48414d07: f8 fe d4              add     -0x2c, sp
48414d0a: fc a4 f4 1f 02 50     mov     (0x50021ff4), d0
48414d10: a0 00                 cmp     0, d0
48414d12: c9 05                 bne     0x48414d17
48414d14: cc 2f 02              jmp     0x48414f43
48414d17: dd 47 d0 00 00 00 00  call    0x48421d5e, 0, 0
48414d1e: 1c                    exthu   d0
48414d1f: a0 02                 cmp     2, d0
48414d21: c9 05                 bne     0x48414d26
48414d23: cc e0 00              jmp     0x48414e03
48414d26: 04                    clr     d1
48414d27: 00                    clr     d0
48414d28: 42 14                 mov     d0, (0x14, sp)
48414d2a: 1d                    exthu   d1
48414d2b: 84                    mov     d1, d0
48414d2c: f8 c0 03              asl     3, d0
48414d2f: fc dc a4 e2 59 48     mov     0x4859e2a4, a0
48414d35: f3 20                 mov     (d0, a0), d2
48414d37: f8 c1 03              asl     3, d1
48414d3a: 4a 10                 mov     d2, (0x10, sp)
48414d3c: f1 e4                 mov     d1, a0
48414d3e: fc d0 a4 e2 59 48     add     0x4859e2a4, a0
48414d44: f8 08 04              mov     (4, a0), d2
48414d47: 5e 10                 mov     (0x10, sp), a2
48414d49: 5d 10                 mov     (0x10, sp), a1
48414d4b: 58 10                 mov     (0x10, sp), d0
48414d4d: 4a 0c                 mov     d2, (0xc, sp)
48414d4f: 2d 7f 02              mov     0x27f, d1
48414d52: f1 01                 sub     d0, d1
48414d54: 2c ef 00              mov     0xef, d0
48414d57: f1 08                 sub     d2, d0
48414d59: 2f 80 02              mov     0x280, d3
48414d5c: cb                    nop
48414d5d: cb                    nop
48414d5e: f2 4c                 mul     d3, d0
48414d60: e1                    add     d0, d1
48414d61: e5                    add     d1, d1
48414d62: f1 e4                 mov     d1, a0
48414d64: fc d0 00 00 e0 9c     add     0x9ce00000, a0
48414d6a: 2d 80 02              mov     0x280, d1
48414d6d: cb                    nop
48414d6e: cb                    nop
48414d6f: f2 49                 mul     d2, d1
48414d71: fc cc 80 40 0d 50     mov     0x500d4080, d0
48414d77: e4                    add     d1, d0
48414d78: f1 62                 add     d0, a2
48414d7a: fc c1 80 98 0f 50     add     0x500f9880, d1
48414d80: f1 65                 add     d1, a1
48414d82: fa ca f0 00           cmp     0xf0, d2
48414d86: c2 6d                 bge     0x48414df3
48414d88: 5f 10                 mov     (0x10, sp), a3
48414d8a: fa db 80 02           cmp     0x280, a3
48414d8e: c2 4c                 bge     0x48414dda
48414d90: db                    setlb
48414d91: f0 42                 movbu   (a2), d0
48414d93: 2d f0 00              mov     0xf0, d1
48414d96: 83                    mov     d0, d3
48414d97: 1f                    exthu   d3
48414d98: f2 0d                 and     d3, d1
48414d9a: fa c9 d0 00           cmp     0xd0, d1
48414d9e: c8 14                 beq     0x48414db2
48414da0: 1c                    exthu   d0
48414da1: e0                    add     d0, d0
48414da2: 4b 24                 mov     a2, (0x24, sp)
48414da4: fc de ac 2a 12 50     mov     0x50122aac, a2
48414daa: f4                    movhu   (d0, a2), d0
48414dab: 82                    mov     d0, d2
48414dac: 5e 24                 mov     (0x24, sp), a2
48414dae: f0 70                 movhu   d0, (a0)
48414db0: ca 1b                 bra     0x48414dcb
48414db2: f0 49                 movbu   (a1), d2
48414db4: f0 45                 movbu   (a1), d1
48414db6: f8 e2 f0              and     0xf0, d2
48414db9: f8 e1 0f              and     0x0f, d1
48414dbc: f8 c2 03              asl     3, d2
48414dbf: f8 e3 0f              and     0x0f, d3
48414dc2: f8 c3 0c              asl     12, d3
48414dc5: ee                    add     d3, d2
48414dc6: 84                    mov     d1, d0
48414dc7: e8                    add     d2, d0
48414dc8: e4                    add     d1, d0
48414dc9: f0 70                 movhu   d0, (a0)
48414dcb: 22 02                 add     2, a2
48414dcd: 21 02                 add     2, a1
48414dcf: 80 04                 mov     4, d0
48414dd1: f1 20                 sub     d0, a0
48414dd3: 23 02                 add     2, a3
48414dd5: fa db 80 02           cmp     0x280, a3
48414dd9: d0                    llt
48414dda: fa d2 80 02           add     0x280, a2
48414dde: 2c 00 05              mov     0x500, d0
48414de1: f1 20                 sub     d0, a0
48414de3: 58 0c                 mov     (0xc, sp), d0
48414de5: fa d1 80 02           add     0x280, a1
48414de9: 28 02                 add     2, d0
48414deb: 42 0c                 mov     d0, (0xc, sp)
48414ded: fa c8 f0 00           cmp     0xf0, d0
48414df1: c0 97                 blt     0x48414d88
48414df3: 59 14                 mov     (0x14, sp), d1
48414df5: 44                    inc     d1
48414df6: 1d                    exthu   d1
48414df7: 46 14                 mov     d1, (0x14, sp)
48414df9: a5 04                 cmp     4, d1
48414dfb: c2 05                 bge     0x48414e00
48414dfd: cc 2d ff              jmp     0x48414d2a
48414e00: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
48414e03: 00                    clr     d0
48414e04: 04                    clr     d1
48414e05: 46 20                 mov     d1, (0x20, sp)
48414e07: 1c                    exthu   d0
48414e08: 81                    mov     d0, d1
48414e09: f8 c1 03              asl     3, d1
48414e0c: fc dc a4 e2 59 48     mov     0x4859e2a4, a0
48414e12: f3 24                 mov     (d1, a0), d2
48414e14: f8 c0 03              asl     3, d0
48414e17: 4a 1c                 mov     d2, (0x1c, sp)
48414e19: f1 50                 add     a0, d0
48414e1b: f1 e0                 mov     d0, a0
48414e1d: f8 0c 04              mov     (4, a0), d3
48414e20: 2c 80 02              mov     0x280, d0
48414e23: cb                    nop
48414e24: cb                    nop
48414e25: f2 4c                 mul     d3, d0
48414e27: 4e 18                 mov     d3, (0x18, sp)
48414e29: fc cd 80 40 0d 50     mov     0x500d4080, d1
48414e2f: e1                    add     d0, d1
48414e30: e9                    add     d2, d1
48414e31: 46 10                 mov     d1, (0x10, sp)
48414e33: fc c0 80 98 0f 50     add     0x500f9880, d0
48414e39: e8                    add     d2, d0
48414e3a: 42 0c                 mov     d0, (0xc, sp)
48414e3c: 2d 7f 02              mov     0x27f, d1
48414e3f: f1 09                 sub     d2, d1
48414e41: 2c ef 00              mov     0xef, d0
48414e44: f1 0c                 sub     d3, d0
48414e46: 2e 80 02              mov     0x280, d2
48414e49: cb                    nop
48414e4a: cb                    nop
48414e4b: f2 48                 mul     d2, d0
48414e4d: e1                    add     d0, d1
48414e4e: 84                    mov     d1, d0
48414e4f: e4                    add     d1, d0
48414e50: f1 e3                 mov     d0, a3
48414e52: fc d3 00 00 e0 9c     add     0x9ce00000, a3
48414e58: fa cb f0 00           cmp     0xf0, d3
48414e5c: c0 05                 blt     0x48414e61
48414e5e: cc d5 00              jmp     0x48414f33
48414e61: 58 1c                 mov     (0x1c, sp), d0
48414e63: 42 14                 mov     d0, (0x14, sp)
48414e65: fa c8 80 02           cmp     0x280, d0
48414e69: c0 05                 blt     0x48414e6e
48414e6b: cc a4 00              jmp     0x48414f0f
48414e6e: 5c 10                 mov     (0x10, sp), a0
48414e70: 2e f0 00              mov     0xf0, d2
48414e73: f0 40                 movbu   (a0), d0
48414e75: 81                    mov     d0, d1
48414e76: 1d                    exthu   d1
48414e77: f2 06                 and     d1, d2
48414e79: fa ca d0 00           cmp     0xd0, d2
48414e7d: c8 10                 beq     0x48414e8d
48414e7f: 1c                    exthu   d0
48414e80: e0                    add     d0, d0
48414e81: fc dc ac 2a 12 50     mov     0x50122aac, a0
48414e87: f4                    movhu   (d0, a0), d0
48414e88: 80 f0                 mov     -0x10, d0
48414e8a: 73                    mov     (a3), d0
48414e8b: ca 65                 bra     0x48414ef0
48414e8d: 5c 0c                 mov     (0xc, sp), a0
48414e8f: f8 e1 0f              and     0x0f, d1
48414e92: f0 40                 movbu   (a0), d0
48414e94: f8 c1 14              asl     20, d1
48414e97: f8 e0 f0              and     0xf0, d0
48414e9a: f8 c0 10              asl     16, d0
48414e9d: 83                    mov     d0, d3
48414e9e: f0 40                 movbu   (a0), d0
48414ea0: e7                    add     d1, d3
48414ea1: f8 e0 0f              and     0x0f, d0
48414ea4: f8 c0 04              asl     4, d0
48414ea7: e3                    add     d0, d3
48414ea8: 8c                    mov     d3, d0
48414ea9: dd e1 8d 01 00 f0 10  call    0x4842dc8a, [d2,d3,a2,a3], 0x10
48414eb0: f1 e2                 mov     d0, a2
48414eb2: 8c                    mov     d3, d0
48414eb3: dd d7 8d 01 00 f0 10  call    0x4842dc8a, [d2,d3,a2,a3], 0x10
48414eba: 82                    mov     d0, d2
48414ebb: 8c                    mov     d3, d0
48414ebc: dd ce 8d 01 00 f0 10  call    0x4842dc8a, [d2,d3,a2,a3], 0x10
48414ec3: 81                    mov     d0, d1
48414ec4: f1 d8                 mov     a2, d0
48414ec6: f8 e0 ff              and     0xff, d0
48414ec9: f8 e0 f8              and     0xf8, d0
48414ecc: f8 c0 08              asl     8, d0
48414ecf: fa e2 00 ff           and     0xff00, d2
48414ed3: f8 c6 08              lsr     8, d2
48414ed6: f8 e2 fc              and     0xfc, d2
48414ed9: f8 c2 03              asl     3, d2
48414edc: e8                    add     d2, d0
48414edd: 86                    mov     d1, d2
48414ede: fc e2 00 00 ff 00     and     0x00ff0000, d2
48414ee4: f8 c6 10              lsr     16, d2
48414ee7: f8 e2 f8              and     0xf8, d2
48414eea: f8 ca 03              asr     3, d2
48414eed: e8                    add     d2, d0
48414eee: f0 73                 movhu   d0, (a3)
48414ef0: 58 10                 mov     (0x10, sp), d0
48414ef2: 28 02                 add     2, d0
48414ef4: 42 10                 mov     d0, (0x10, sp)
48414ef6: 58 0c                 mov     (0xc, sp), d0
48414ef8: 28 02                 add     2, d0
48414efa: 42 0c                 mov     d0, (0xc, sp)
48414efc: 80 04                 mov     4, d0
48414efe: f1 23                 sub     d0, a3
48414f00: 58 14                 mov     (0x14, sp), d0
48414f02: 28 02                 add     2, d0
48414f04: 42 14                 mov     d0, (0x14, sp)
48414f06: fa c8 80 02           cmp     0x280, d0
48414f0a: c2 05                 bge     0x48414f0f
48414f0c: cc 62 ff              jmp     0x48414e6e
48414f0f: 58 10                 mov     (0x10, sp), d0
48414f11: fa c0 80 02           add     0x280, d0
48414f15: 42 10                 mov     d0, (0x10, sp)
48414f17: 58 0c                 mov     (0xc, sp), d0
48414f19: fa c0 80 02           add     0x280, d0
48414f1d: 42 0c                 mov     d0, (0xc, sp)
48414f1f: 2c 00 05              mov     0x500, d0
48414f22: f1 23                 sub     d0, a3
48414f24: 58 18                 mov     (0x18, sp), d0
48414f26: 28 02                 add     2, d0
48414f28: 42 18                 mov     d0, (0x18, sp)
48414f2a: fa c8 f0 00           cmp     0xf0, d0
48414f2e: c2 05                 bge     0x48414f33
48414f30: cc 31 ff              jmp     0x48414e61
48414f33: 58 20                 mov     (0x20, sp), d0
48414f35: 40                    inc     d0
48414f36: 1c                    exthu   d0
48414f37: 42 20                 mov     d0, (0x20, sp)
48414f39: a0 04                 cmp     4, d0
48414f3b: c2 05                 bge     0x48414f40
48414f3d: cc ca fe              jmp     0x48414e07
48414f40: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
48414f43: dd 1b ce 00 00 00 00  call    0x48421d5e, 0, 0
48414f4a: 1c                    exthu   d0
48414f4b: a0 02                 cmp     2, d0
48414f4d: c9 05                 bne     0x48414f52
48414f4f: cc d4 00              jmp     0x48415023
48414f52: 04                    clr     d1
48414f53: 00                    clr     d0
48414f54: 42 14                 mov     d0, (0x14, sp)
48414f56: 1d                    exthu   d1
48414f57: 84                    mov     d1, d0
48414f58: f8 c0 03              asl     3, d0
48414f5b: fc dc a4 e2 59 48     mov     0x4859e2a4, a0
48414f61: f3 20                 mov     (d0, a0), d2
48414f63: f8 c1 03              asl     3, d1
48414f66: 4a 10                 mov     d2, (0x10, sp)
48414f68: f1 e4                 mov     d1, a0
48414f6a: fc d0 a4 e2 59 48     add     0x4859e2a4, a0
48414f70: f8 08 04              mov     (4, a0), d2
48414f73: 5e 10                 mov     (0x10, sp), a2
48414f75: 5d 10                 mov     (0x10, sp), a1
48414f77: 59 10                 mov     (0x10, sp), d1
48414f79: 4a 0c                 mov     d2, (0xc, sp)
48414f7b: 2c 80 02              mov     0x280, d0
48414f7e: cb                    nop
48414f7f: cb                    nop
48414f80: f2 48                 mul     d2, d0
48414f82: e4                    add     d1, d0
48414f83: e0                    add     d0, d0
48414f84: fc c0 00 00 e0 9c     add     0x9ce00000, d0
48414f8a: 2d 80 02              mov     0x280, d1
48414f8d: cb                    nop
48414f8e: cb                    nop
48414f8f: f2 49                 mul     d2, d1
48414f91: 24 00 05              mov     0x500, a0
48414f94: f1 60                 add     d0, a0
48414f96: fc cc 80 40 0d 50     mov     0x500d4080, d0
48414f9c: e4                    add     d1, d0
48414f9d: f1 62                 add     d0, a2
48414f9f: fc c1 80 98 0f 50     add     0x500f9880, d1
48414fa5: f1 65                 add     d1, a1
48414fa7: fa ca f0 00           cmp     0xf0, d2
48414fab: c2 68                 bge     0x48415013
48414fad: 5f 10                 mov     (0x10, sp), a3
48414faf: fa db 80 02           cmp     0x280, a3
48414fb3: c2 48                 bge     0x48414ffb
48414fb5: db                    setlb
48414fb6: f0 46                 movbu   (a2), d1
48414fb8: 2c f0 00              mov     0xf0, d0
48414fbb: 87                    mov     d1, d3
48414fbc: 1f                    exthu   d3
48414fbd: f2 0c                 and     d3, d0
48414fbf: fa c8 d0 00           cmp     0xd0, d0
48414fc3: c8 14                 beq     0x48414fd7
48414fc5: 1d                    exthu   d1
48414fc6: e5                    add     d1, d1
48414fc7: 4b 28                 mov     a2, (0x28, sp)
48414fc9: fc de ac 2a 12 50     mov     0x50122aac, a2
48414fcf: f4                    movhu   (d1, a2), d0
48414fd0: 86                    mov     d1, d2
48414fd1: 5e 28                 mov     (0x28, sp), a2
48414fd3: f0 70                 movhu   d0, (a0)
48414fd5: ca 1a                 bra     0x48414fef
48414fd7: f0 45                 movbu   (a1), d1
48414fd9: f0 49                 movbu   (a1), d2
48414fdb: f8 e1 f0              and     0xf0, d1
48414fde: f8 e2 0f              and     0x0f, d2
48414fe1: f8 c1 03              asl     3, d1
48414fe4: f8 e3 0f              and     0x0f, d3
48414fe7: f8 c3 0c              asl     12, d3
48414fea: ed                    add     d3, d1
48414feb: e9                    add     d2, d1
48414fec: e9                    add     d2, d1
48414fed: f0 74                 movhu   d1, (a0)
48414fef: 22 02                 add     2, a2
48414ff1: 21 02                 add     2, a1
48414ff3: 50                    inc4    a0
48414ff4: 23 02                 add     2, a3
48414ff6: fa db 80 02           cmp     0x280, a3
48414ffa: d0                    llt
48414ffb: 58 0c                 mov     (0xc, sp), d0
48414ffd: fa d2 80 02           add     0x280, a2
48415001: fa d1 80 02           add     0x280, a1
48415005: fa d0 00 05           add     0x500, a0
48415009: 28 02                 add     2, d0
4841500b: 42 0c                 mov     d0, (0xc, sp)
4841500d: fa c8 f0 00           cmp     0xf0, d0
48415011: c0 9c                 blt     0x48414fad
48415013: 59 14                 mov     (0x14, sp), d1
48415015: 44                    inc     d1
48415016: 1d                    exthu   d1
48415017: 46 14                 mov     d1, (0x14, sp)
48415019: a5 04                 cmp     4, d1
4841501b: c2 05                 bge     0x48415020
4841501d: cc 39 ff              jmp     0x48414f56
48415020: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
48415023: fc cc 00 00 e0 9c     mov     0x9ce00000, d0
48415029: 42 14                 mov     d0, (0x14, sp)
4841502b: 00                    clr     d0
4841502c: 42 18                 mov     d0, (0x18, sp)
4841502e: 42 10                 mov     d0, (0x10, sp)
48415030: 5f 10                 mov     (0x10, sp), a3
48415032: 5e 10                 mov     (0x10, sp), a2
48415034: fc d3 80 40 0d 50     add     0x500d4080, a3
4841503a: fc d2 80 98 0f 50     add     0x500f9880, a2
48415040: 00                    clr     d0
48415041: 42 0c                 mov     d0, (0xc, sp)
48415043: 08                    clr     d2
48415044: 0c                    clr     d3
48415045: f0 47                 movbu   (a3), d1
48415047: 2c f0 00              mov     0xf0, d0
4841504a: 1d                    exthu   d1
4841504b: f2 04                 and     d1, d0
4841504d: fa c8 d0 00           cmp     0xd0, d0
48415051: c8 0e                 beq     0x4841505f
48415053: f0 43                 movbu   (a3), d0
48415055: 18                    exth    d0
48415056: dd da 8a 01 00 00 00  call    0x4842db30, 0, 0
4841505d: ca 27                 bra     0x48415084
4841505f: f0 42                 movbu   (a2), d0
48415061: f8 e1 0f              and     0x0f, d1
48415064: f8 c1 14              asl     20, d1
48415067: f8 e0 f0              and     0xf0, d0
4841506a: f8 c0 10              asl     16, d0
4841506d: e1                    add     d0, d1
4841506e: f0 42                 movbu   (a2), d0
48415070: f8 e0 0f              and     0x0f, d0
48415073: f8 c0 04              asl     4, d0
48415076: e4                    add     d1, d0
48415077: dd 13 8c 01 00 f0 10  call    0x4842dc8a, [d2,d3,a2,a3], 0x10
4841507e: f8 c4 06              lsr     6, d0
48415081: f8 e0 03              and     0x03, d0
48415084: 1e                    exthu   d2
48415085: 56                    asl2    d2
48415086: 81                    mov     d0, d1
48415087: 1d                    exthu   d1
48415088: e6                    add     d1, d2
48415089: 4d                    inc     a3
4841508a: 49                    inc     a2
4841508b: 4c                    inc     d3
4841508c: af 08                 cmp     8, d3
4841508e: c0 b7                 blt     0x48415045
48415090: 5c 14                 mov     (0x14, sp), a0
48415092: 1e                    exthu   d2
48415093: 89                    mov     d2, d1
48415094: f8 c9 08              asr     8, d1
48415097: 15                    extbu   d1

CaptureLcd:
4841567d: f8 fe f8              add     -8, sp
48415680: dd de c6 00 00 00 00  call    0x48421d5e, 0, 0
48415687: 1c                    exthu   d0
48415688: a0 02                 cmp     2, d0
4841568a: c8 09                 beq     0x48415693
4841568c: cd 14 00 f0 84        call    0x484156a0, [d2,d3,a2,a3], 0x84
48415691: ca 07                 bra     0x48415698
48415693: cd b9 01 f0 d4        call    0x4841584c, [d2,d3,a2,a3], 0xd4
48415698: df 00 08              ret     0, 8
4841569b: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841569d: f8 fe 8c              add     -0x74, sp
484156a0: 3e                    mov     sp, a2
484156a1: 22 1c                 add     0x1c, a2
484156a3: 4b 08                 mov     a2, (8, sp)
484156a5: fc cc e4 e2 59 48     mov     0x4859e2e4, d0
484156ab: 42 0c                 mov     d0, (0xc, sp)
484156ad: fc a1 c8 1f 02 50     mov     (0x50021fc8), a1
484156b3: 47 10                 mov     a1, (0x10, sp)
484156b5: dd 93 c3 be 03 20 20  call    0x4c001a48, [a2], 0x20
484156bc: fc a4 c8 1f 02 50     mov     (0x50021fc8), d0
484156c2: 40                    inc     d0
484156c3: fc 81 c8 1f 02 50     mov     d0, (0x50021fc8)
484156c9: dd 04 a7 11 00 00 08  call    0x4852fdcd, 0, 8
484156d0: dd 46 ab 11 00 f0 10  call    0x48530216, [d2,d3,a2,a3], 0x10
484156d7: 98                    mov     a2, a0
484156d8: fc dd f4 e2 59 48     mov     0x4859e2f4, a1
484156de: dd b7 cc 11 00 30 24  call    0x48532395, [a2,a3], 0x24
484156e5: 18                    exth    d0
484156e6: a0 00                 cmp     0, d0
484156e8: c8 06                 beq     0x484156ee
484156ea: 00                    clr     d0
484156eb: df f0 84              ret     [d2,d3,a2,a3], 0x84
484156ee: 3f                    mov     sp, a3
484156ef: 23 2c                 add     0x2c, a3
484156f1: 9c                    mov     a3, a0
484156f2: fc dd f8 e2 59 48     mov     0x4859e2f8, a1
484156f8: dd 59 d9 be 03 20 04  call    0x4c003051, [a2], 4
484156ff: 8a 04                 mov     4, d2
48415701: f1 5e                 add     a3, d2
48415703: fc cc 36 08 07 00     mov     0x00070836, d0
48415709: f1 e8                 mov     d2, a0
4841570b: 60                    mov     d0, (a0)
4841570c: 00                    clr     d0
4841570d: f8 93 34              movhu   d0, (0x34, sp)
48415710: f8 93 36              movhu   d0, (0x36, sp)
48415713: 80 36                 mov     0x36, d0
48415715: 42 38                 mov     d0, (0x38, sp)
48415717: 3e                    mov     sp, a2
48415718: 22 3c                 add     0x3c, a2
4841571a: 98                    mov     a2, a0
4841571b: 80 02                 mov     2, d0
4841571d: 9d                    mov     a3, a1
4841571e: dd 1b d9 be 03 30 08  call    0x4c003039, [a2,a3], 8
48415725: 90 02                 mov     2, a0
48415727: f1 78                 add     a2, a0
48415729: f1 e9                 mov     d2, a1
4841572b: 80 0c                 mov     0xc, d0
4841572d: dd 0c d9 be 03 30 08  call    0x4c003039, [a2,a3], 8
48415734: 80 0e                 mov     0xe, d0
48415736: 98                    mov     a2, a0
48415737: dd 5d cd 11 00 a0 24  call    0x48532494, [d2,a2], 0x24
4841573e: a0 0e                 cmp     0xe, d0
48415740: c8 0d                 beq     0x4841574d
48415742: dd 7d cc 11 00 00 14  call    0x485323bf, 0, 0x14
48415749: 00                    clr     d0
4841574a: df f0 84              ret     [d2,d3,a2,a3], 0x84
4841574d: 80 28                 mov     0x28, d0
4841574f: 42 4c                 mov     d0, (0x4c, sp)
48415751: 2c 80 02              mov     0x280, d0
48415754: 42 50                 mov     d0, (0x50, sp)
48415756: 2c f0 00              mov     0xf0, d0
48415759: 42 54                 mov     d0, (0x54, sp)
4841575b: 80 01                 mov     1, d0
4841575d: f8 93 58              movhu   d0, (0x58, sp)
48415760: 80 18                 mov     0x18, d0
48415762: f8 93 5a              movhu   d0, (0x5a, sp)
48415765: 00                    clr     d0
48415766: 42 5c                 mov     d0, (0x5c, sp)
48415768: fc cc 00 08 07 00     mov     0x00070800, d0
4841576e: 42 60                 mov     d0, (0x60, sp)
48415770: 00                    clr     d0
48415771: 42 64                 mov     d0, (0x64, sp)
48415773: 42 68                 mov     d0, (0x68, sp)
48415775: 42 6c                 mov     d0, (0x6c, sp)
48415777: 42 70                 mov     d0, (0x70, sp)
48415779: 3c                    mov     sp, a0
4841577a: 20 4c                 add     0x4c, a0
4841577c: 80 28                 mov     0x28, d0
4841577e: dd 16 cd 11 00 a0 24  call    0x48532494, [d2,a2], 0x24
48415785: a0 28                 cmp     0x28, d0
48415787: c8 0d                 beq     0x48415794
48415789: dd 36 cc 11 00 00 14  call    0x485323bf, 0, 0x14
48415790: 00                    clr     d0
48415791: df f0 84              ret     [d2,d3,a2,a3], 0x84
48415794: 2c 00 3c              mov     0x3c00, d0
48415797: cd 93 0e b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841579c: 93                    mov     a0, a3
4841579d: bf 00                 cmp     0, a3
4841579f: c9 05                 bne     0x484157a4
484157a1: cc 99 00              jmp     0x4841583a
484157a4: 00                    clr     d0
484157a5: 42 14                 mov     d0, (0x14, sp)
484157a7: 08                    clr     d2
484157a8: 9a 00                 mov     0, a2
484157aa: 2d ef 00              mov     0xef, d1
484157ad: f1 01                 sub     d0, d1
484157af: 46 18                 mov     d1, (0x18, sp)
484157b1: 58 18                 mov     (0x18, sp), d0
484157b3: 2d 80 02              mov     0x280, d1
484157b6: f1 18                 sub     a2, d0
484157b8: 40                    inc     d0
484157b9: cb                    nop
484157ba: cb                    nop
484157bb: f2 44                 mul     d1, d0
484157bd: e0                    add     d0, d0
484157be: f1 e0                 mov     d0, a0
484157c0: fc d0 00 00 e0 9c     add     0x9ce00000, a0
484157c6: 95 00                 mov     0, a1
484157c8: db                    setlb
484157c9: f0 6c                 movhu   (a0), d3
484157cb: 1a                    exth    d2
484157cc: 1f                    exthu   d3
484157cd: 85 1f                 mov     0x1f, d1
484157cf: f2 0d                 and     d3, d1
484157d1: f8 c1 03              asl     3, d1
484157d4: f4                    movbu   d1, (d2, a3)
484157d5: 5b 48                 mov     (0x48, sp), d3
484157d7: 88                    mov     d2, d0
484157d8: 18                    exth    d0
484157d9: 2d e0 07              mov     0x7e0, d1
484157dc: f2 0d                 and     d3, d1
484157de: f8 c9 03              asr     3, d1
484157e1: f4                    movbu   d1, (d0, a3)
484157e2: 53                    inc4    a3
484157e3: 1a                    exth    d2
484157e4: 48                    inc     d2
484157e5: 88                    mov     d2, d0
484157e6: 18                    exth    d0
484157e7: fa e3 00 f8           and     0xf800, d3
484157eb: f8 cb 08              asr     8, d3
484157ee: f4                    movbu   d3, (d0, a3)
484157ef: 73                    mov     (a3), d0
484157f0: 1a                    exth    d2
484157f1: 48                    inc     d2
484157f2: 20 02                 add     2, a0
484157f4: f1 d4                 mov     a1, d0
484157f6: 40                    inc     d0
484157f7: 18                    exth    d0
484157f8: f1 e1                 mov     d0, a1
484157fa: fa c8 80 02           cmp     0x280, d0
484157fe: d0                    llt
484157ff: f1 d8                 mov     a2, d0
48415801: 40                    inc     d0
48415802: 18                    exth    d0
48415803: f1 e2                 mov     d0, a2
48415805: a0 08                 cmp     8, d0
48415807: c0 aa                 blt     0x484157b1
48415809: 9c                    mov     a3, a0
4841580a: 2c 00 3c              mov     0x3c00, d0
4841580d: dd 87 cc 11 00 a0 24  call    0x48532494, [d2,a2], 0x24
48415814: fa c8 00 3c           cmp     0x3c00, d0
48415818: c8 0c                 beq     0x48415824
4841581a: dd a5 cb 11 00 00 14  call    0x485323bf, 0, 0x14
48415821: 00                    clr     d0
48415822: ca 21                 bra     0x48415843
48415824: 58 14                 mov     (0x14, sp), d0
48415826: 28 08                 add     8, d0
48415828: 18                    exth    d0
48415829: 42 14                 mov     d0, (0x14, sp)
4841582b: fa c8 f0 00           cmp     0xf0, d0
4841582f: c2 05                 bge     0x48415834
48415831: cc 76 ff              jmp     0x484157a7
48415834: 9c                    mov     a3, a0
48415835: cd a9 0e f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841583a: dd 85 cb 11 00 00 14  call    0x485323bf, 0, 0x14
48415841: 80 01                 mov     1, d0
48415843: df f0 84              ret     [d2,d3,a2,a3], 0x84
48415846: cf f0                 movm    [d2,d3,a2,a3], (sp)
48415848: fa fe 3c ff           add     -0xc4, sp
4841584c: 3e                    mov     sp, a2
4841584d: 22 2c                 add     0x2c, a2
4841584f: 4b 08                 mov     a2, (8, sp)
48415851: fc cc 1c e3 59 48     mov     0x4859e31c, d0
48415857: 42 0c                 mov     d0, (0xc, sp)
48415859: fc a1 cc 1f 02 50     mov     (0x50021fcc), a1
4841585f: 47 10                 mov     a1, (0x10, sp)
48415861: dd e7 c1 be 03 20 20  call    0x4c001a48, [a2], 0x20
48415868: fc a4 cc 1f 02 50     mov     (0x50021fcc), d0
4841586e: 40                    inc     d0
4841586f: fc 81 cc 1f 02 50     mov     d0, (0x50021fcc)
48415875: dd 58 a5 11 00 00 08  call    0x4852fdcd, 0, 8
4841587c: dd 9a a9 11 00 f0 10  call    0x48530216, [d2,d3,a2,a3], 0x10
48415883: 98                    mov     a2, a0
48415884: fc dd 2c e3 59 48     mov     0x4859e32c, a1
4841588a: dd 0b cb 11 00 30 24  call    0x48532395, [a2,a3], 0x24
48415891: 18                    exth    d0
48415892: a0 00                 cmp     0, d0
48415894: c8 06                 beq     0x4841589a
48415896: 00                    clr     d0
48415897: df f0 d4              ret     [d2,d3,a2,a3], 0xd4
4841589a: 3f                    mov     sp, a3
4841589b: 23 3c                 add     0x3c, a3
4841589d: 9c                    mov     a3, a0
4841589e: fc dd 30 e3 59 48     mov     0x4859e330, a1
484158a4: dd ad d7 be 03 20 04  call    0x4c003051, [a2], 4
484158ab: 8a 04                 mov     4, d2
484158ad: f1 5e                 add     a3, d2
484158af: fc cc 36 2c 01 00     mov     0x00012c36, d0
484158b5: f1 e8                 mov     d2, a0
484158b7: 60                    mov     d0, (a0)
484158b8: 00                    clr     d0
484158b9: f8 93 44              movhu   d0, (0x44, sp)
484158bc: f8 93 46              movhu   d0, (0x46, sp)
484158bf: 80 76                 mov     0x76, d0
484158c1: 42 48                 mov     d0, (0x48, sp)
484158c3: 3e                    mov     sp, a2
484158c4: 22 4c                 add     0x4c, a2
484158c6: 98                    mov     a2, a0
484158c7: 80 02                 mov     2, d0
484158c9: 9d                    mov     a3, a1
484158ca: dd 6f d7 be 03 30 08  call    0x4c003039, [a2,a3], 8
484158d1: 90 02                 mov     2, a0
484158d3: f1 78                 add     a2, a0
484158d5: f1 e9                 mov     d2, a1
484158d7: 80 0c                 mov     0xc, d0
484158d9: dd 60 d7 be 03 30 08  call    0x4c003039, [a2,a3], 8
484158e0: 80 0e                 mov     0xe, d0
484158e2: 98                    mov     a2, a0
484158e3: dd b1 cb 11 00 a0 24  call    0x48532494, [d2,a2], 0x24
484158ea: a0 0e                 cmp     0xe, d0
484158ec: c8 0d                 beq     0x484158f9
484158ee: dd d1 ca 11 00 00 14  call    0x485323bf, 0, 0x14
484158f5: 00                    clr     d0
484158f6: df f0 d4              ret     [d2,d3,a2,a3], 0xd4
484158f9: 80 28                 mov     0x28, d0
484158fb: 42 5c                 mov     d0, (0x5c, sp)
484158fd: 2c 80 02              mov     0x280, d0
48415900: 42 60                 mov     d0, (0x60, sp)
48415902: 2c f0 00              mov     0xf0, d0
48415905: 42 64                 mov     d0, (0x64, sp)
48415907: 80 01                 mov     1, d0
48415909: f8 93 68              movhu   d0, (0x68, sp)
4841590c: 80 04                 mov     4, d0
4841590e: f8 93 6a              movhu   d0, (0x6a, sp)
48415911: 00                    clr     d0
48415912: 42 6c                 mov     d0, (0x6c, sp)
48415914: fc cc 00 2c 01 00     mov     0x00012c00, d0
4841591a: 42 70                 mov     d0, (0x70, sp)
4841591c: 00                    clr     d0
4841591d: 42 74                 mov     d0, (0x74, sp)
4841591f: 42 78                 mov     d0, (0x78, sp)
48415921: 42 7c                 mov     d0, (0x7c, sp)
48415923: 42 80                 mov     d0, (0x80, sp)
48415925: 3c                    mov     sp, a0
48415926: 20 5c                 add     0x5c, a0
48415928: 80 28                 mov     0x28, d0
4841592a: dd 6a cb 11 00 a0 24  call    0x48532494, [d2,a2], 0x24
48415931: a0 28                 cmp     0x28, d0
48415933: c8 0d                 beq     0x48415940
48415935: dd 8a ca 11 00 00 14  call    0x485323bf, 0, 0x14
4841593c: 00                    clr     d0
4841593d: df f0 d4              ret     [d2,d3,a2,a3], 0xd4
48415940: 0c                    clr     d3
48415941: fc df fc e2 59 48     mov     0x4859e2fc, a3
48415947: 3e                    mov     sp, a2
48415948: fa d2 84 00           add     0x84, a2
4841594c: 8c                    mov     d3, d0
4841594d: e0                    add     d0, d0
4841594e: f4                    movhu   (d0, a3), d0
4841594f: 83                    mov     d0, d3
48415950: 2e ff 00              mov     0xff, d2
48415953: 18                    exth    d0
48415954: fa c8 f9 00           cmp     0xf9, d0
48415958: c8 13                 beq     0x4841596b
4841595a: f1 ec                 mov     d3, a0
4841595c: f1 70                 add     a0, a0
4841595e: f1 d0                 mov     a0, d0
48415960: f4                    movhu   (d0, a3), d0
48415961: 83                    mov     d0, d3
48415962: 18                    exth    d0
48415963: dd c0 81 01 00 00 00  call    0x4842db23, 0, 0
4841596a: 82                    mov     d0, d2
4841596b: 8d                    mov     d3, d1
4841596c: 55                    asl2    d1
4841596d: 88                    mov     d2, d0
4841596e: fc e0 00 00 ff 00     and     0x00ff0000, d0
48415974: f8 c4 10              lsr     16, d0
48415977: f4                    movbu   d0, (d1, a2)
48415978: 46 8d                 mov     d1, (0x8d, sp)
4841597a: 55                    asl2    d1
4841597b: f1 59                 add     a2, d1
4841597d: fc cc 00 ff 00 00     mov     0x0000ff00, d0
48415983: f2 08                 and     d2, d0
48415985: f8 c4 08              lsr     8, d0
48415988: f1 e4                 mov     d1, a0
4841598a: f8 50 01              movbu   d0, (1, a0)
4841598d: 8c                    mov     d3, d0
4841598e: 54                    asl2    d0
4841598f: f1 58                 add     a2, d0
48415991: f8 e2 ff              and     0xff, d2
48415994: f1 e0                 mov     d0, a0
48415996: f8 58 02              movbu   d2, (2, a0)
48415999: 8c                    mov     d3, d0
4841599a: 54                    asl2    d0
4841599b: f1 e0                 mov     d0, a0
4841599d: f1 78                 add     a2, a0
4841599f: 00                    clr     d0
484159a0: f8 50 03              movbu   d0, (3, a0)
484159a3: 4c                    inc     d3
484159a4: 1b                    exth    d3
484159a5: af 10                 cmp     0x10, d3
484159a7: c0 a5                 blt     0x4841594c
484159a9: 3c                    mov     sp, a0
484159aa: fa d0 84 00           add     0x84, a0
484159ae: 80 40                 mov     0x40, d0
484159b0: dd e4 ca 11 00 a0 24  call    0x48532494, [d2,a2], 0x24
484159b7: a0 40                 cmp     0x40, d0
484159b9: c8 0d                 beq     0x484159c6
484159bb: dd 04 ca 11 00 00 14  call    0x485323bf, 0, 0x14
484159c2: 00                    clr     d0
484159c3: df f0 d4              ret     [d2,d3,a2,a3], 0xd4
484159c6: 2c 00 0a              mov     0xa00, d0
484159c9: cd 61 0c b0 28        call    0x4841662a, [d2,a2,a3], 0x28
484159ce: 43 20                 mov     a0, (0x20, sp)
484159d0: b0 00                 cmp     0, a0
484159d2: c9 05                 bne     0x484159d7
484159d4: cc a7 00              jmp     0x48415a7b
484159d7: 00                    clr     d0
484159d8: 42 1c                 mov     d0, (0x1c, sp)
484159da: 00                    clr     d0
484159db: f8 93 28              movhu   d0, (0x28, sp)
484159de: 42 18                 mov     d0, (0x18, sp)
484159e0: 58 1c                 mov     (0x1c, sp), d0
484159e2: 2d f0 00              mov     0xf0, d1
484159e5: f1 01                 sub     d0, d1
484159e7: 46 24                 mov     d1, (0x24, sp)
484159e9: 58 24                 mov     (0x24, sp), d0
484159eb: 59 18                 mov     (0x18, sp), d1
484159ed: fc de 80 fd ff ff     mov     0xfffffd80, a2
484159f3: f1 04                 sub     d1, d0
484159f5: 2d 80 02              mov     0x280, d1
484159f8: cb                    nop
484159f9: cb                    nop
484159fa: f2 44                 mul     d1, d0
484159fc: fc c0 80 40 0d 50     add     0x500d4080, d0
48415a02: f1 62                 add     d0, a2
48415a04: 9b                    mov     a2, a3
48415a05: 4d                    inc     a3
48415a06: 00                    clr     d0
48415a07: 42 14                 mov     d0, (0x14, sp)
48415a09: f0 42                 movbu   (a2), d0
48415a0b: 22 02                 add     2, a2
48415a0d: 18                    exth    d0
48415a0e: dd 22 81 01 00 00 00  call    0x4842db30, 0, 0
48415a15: 83                    mov     d0, d3
48415a16: f0 43                 movbu   (a3), d0
48415a18: f8 c3 04              asl     4, d3
48415a1b: 18                    exth    d0
48415a1c: dd 14 81 01 00 00 00  call    0x4842db30, 0, 0
48415a23: f8 bd 28              movhu   (0x28, sp), d1
48415a26: 5c 20                 mov     (0x20, sp), a0
48415a28: 19                    exth    d1
48415a29: ec                    add     d3, d0
48415a2a: f4                    movbu   d0, (d1, a0)
48415a2b: 44                    inc     d1
48415a2c: 44                    inc     d1
48415a2d: f8 97 28              movhu   d1, (0x28, sp)
48415a30: 58 14                 mov     (0x14, sp), d0
48415a32: 23 02                 add     2, a3
48415a34: 40                    inc     d0
48415a35: 18                    exth    d0
48415a36: 42 14                 mov     d0, (0x14, sp)
48415a38: fa c8 40 01           cmp     0x140, d0
48415a3c: c0 cd                 blt     0x48415a09
48415a3e: 58 18                 mov     (0x18, sp), d0
48415a40: 40                    inc     d0
48415a41: 18                    exth    d0
48415a42: 42 18                 mov     d0, (0x18, sp)
48415a44: a0 08                 cmp     8, d0
48415a46: c0 a3                 blt     0x484159e9
48415a48: 5c 20                 mov     (0x20, sp), a0
48415a4a: 2c 00 0a              mov     0xa00, d0
48415a4d: dd 47 ca 11 00 a0 24  call    0x48532494, [d2,a2], 0x24
48415a54: fa c8 00 0a           cmp     0xa00, d0
48415a58: c8 0c                 beq     0x48415a64
48415a5a: dd 65 c9 11 00 00 14  call    0x485323bf, 0, 0x14
48415a61: 00                    clr     d0
48415a62: ca 22                 bra     0x48415a84
48415a64: 58 1c                 mov     (0x1c, sp), d0
48415a66: 28 08                 add     8, d0
48415a68: 18                    exth    d0
48415a69: 42 1c                 mov     d0, (0x1c, sp)
48415a6b: fa c8 f0 00           cmp     0xf0, d0
48415a6f: c2 05                 bge     0x48415a74
48415a71: cc 69 ff              jmp     0x484159da
48415a74: 5c 20                 mov     (0x20, sp), a0
48415a76: cd 68 0c f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
48415a7b: dd 44 c9 11 00 00 14  call    0x485323bf, 0, 0x14

CaptureLcdArea:
48415a87: cf 20                 movm    [a2], (sp)
48415a89: f8 fe f4              add     -0xc, sp
48415a8c: 92                    mov     a0, a2
48415a8d: dd d1 c2 00 00 00 00  call    0x48421d5e, 0, 0
48415a94: 1c                    exthu   d0
48415a95: a0 02                 cmp     2, d0
48415a97: c8 0a                 beq     0x48415aa1
48415a99: 98                    mov     a2, a0
48415a9a: cd 11 00 f0 94        call    0x48415aab, [d2,d3,a2,a3], 0x94
48415a9f: ca 03                 bra     0x48415aa2
48415aa1: 00                    clr     d0
48415aa2: df 20 10              ret     [a2], 0x10
48415aa5: cf f0                 movm    [d2,d3,a2,a3], (sp)
48415aa7: fa fe 7c ff           add     -0x84, sp
48415aab: 3e                    mov     sp, a2
48415aac: 22 24                 add     0x24, a2
48415aae: 4b 08                 mov     a2, (8, sp)
48415ab0: fc cc 34 e3 59 48     mov     0x4859e334, d0
48415ab6: 42 0c                 mov     d0, (0xc, sp)
48415ab8: fc a1 d0 1f 02 50     mov     (0x50021fd0), a1
48415abe: 93                    mov     a0, a3
48415abf: 47 10                 mov     a1, (0x10, sp)
48415ac1: dd 87 bf be 03 20 20  call    0x4c001a48, [a2], 0x20
48415ac8: fc a4 d0 1f 02 50     mov     (0x50021fd0), d0
48415ace: 40                    inc     d0
48415acf: fc 81 d0 1f 02 50     mov     d0, (0x50021fd0)
48415ad5: dd f8 a2 11 00 00 08  call    0x4852fdcd, 0, 8
48415adc: dd 3a a7 11 00 f0 10  call    0x48530216, [d2,d3,a2,a3], 0x10
48415ae3: 98                    mov     a2, a0
48415ae4: fc dd 44 e3 59 48     mov     0x4859e344, a1
48415aea: dd ab c8 11 00 30 24  call    0x48532395, [a2,a3], 0x24
48415af1: 18                    exth    d0
48415af2: a0 00                 cmp     0, d0
48415af4: c8 06                 beq     0x48415afa
48415af6: 00                    clr     d0
48415af7: df f0 94              ret     [d2,d3,a2,a3], 0x94
48415afa: 80 04                 mov     4, d0
48415afc: f1 5c                 add     a3, d0
48415afe: 42 14                 mov     d0, (0x14, sp)
48415b00: f1 e0                 mov     d0, a0
48415b02: f0 68                 movhu   (a0), d2
48415b04: f0 67                 movhu   (a3), d1
48415b06: 8f 06                 mov     6, d3
48415b08: f1 5f                 add     a3, d3
48415b0a: f1 ec                 mov     d3, a0
48415b0c: f0 60                 movhu   (a0), d0
48415b0e: 9a 02                 mov     2, a2
48415b10: f1 7e                 add     a3, a2
48415b12: 1a                    exth    d2
48415b13: 19                    exth    d1
48415b14: f1 06                 sub     d1, d2
48415b16: f0 66                 movhu   (a2), d1
48415b18: 48                    inc     d2
48415b19: 18                    exth    d0
48415b1a: 19                    exth    d1
48415b1b: 1a                    exth    d2
48415b1c: 4a 18                 mov     d2, (0x18, sp)
48415b1e: f1 04                 sub     d1, d0
48415b20: 40                    inc     d0
48415b21: 18                    exth    d0
48415b22: 42 1c                 mov     d0, (0x1c, sp)
48415b24: 5c 18                 mov     (0x18, sp), a0
48415b26: 85 04                 mov     4, d1
48415b28: cb                    nop
48415b29: cb                    nop
48415b2a: f2 42                 mul     d0, d2
48415b2c: f1 d0                 mov     a0, d0
48415b2e: 54                    asl2    d0
48415b2f: f1 10                 sub     a0, d0
48415b31: 28 03                 add     3, d0
48415b33: dd a2 be be 03 00 00  call    0x4c0019d5, 0, 0
48415b3a: 54                    asl2    d0
48415b3b: 42 20                 mov     d0, (0x20, sp)
48415b3d: f0 62                 movhu   (a2), d0
48415b3f: 3e                    mov     sp, a2
48415b40: f8 93 36              movhu   d0, (0x36, sp)
48415b43: f0 63                 movhu   (a3), d0
48415b45: f8 93 34              movhu   d0, (0x34, sp)
48415b48: 5c 14                 mov     (0x14, sp), a0
48415b4a: f0 60                 movhu   (a0), d0
48415b4c: f1 ec                 mov     d3, a0
48415b4e: f8 93 38              movhu   d0, (0x38, sp)
48415b51: f0 60                 movhu   (a0), d0
48415b53: 3f                    mov     sp, a3
48415b54: f8 93 3a              movhu   d0, (0x3a, sp)
48415b57: 23 3c                 add     0x3c, a3
48415b59: 9c                    mov     a3, a0
48415b5a: 88                    mov     d2, d0
48415b5b: 54                    asl2    d0
48415b5c: 83                    mov     d0, d3
48415b5d: f1 0b                 sub     d2, d3
48415b5f: fc dd 48 e3 59 48     mov     0x4859e348, a1
48415b65: dd ec d4 be 03 20 04  call    0x4c003051, [a2], 4
48415b6c: 22 4c                 add     0x4c, a2
48415b6e: 9d                    mov     a3, a1
48415b6f: 8a 04                 mov     4, d2
48415b71: f1 5e                 add     a3, d2
48415b73: f1 e8                 mov     d2, a0
48415b75: 80 36                 mov     0x36, d0
48415b77: ec                    add     d3, d0
48415b78: 60                    mov     d0, (a0)
48415b79: 98                    mov     a2, a0
48415b7a: 00                    clr     d0
48415b7b: f8 93 44              movhu   d0, (0x44, sp)
48415b7e: f8 93 46              movhu   d0, (0x46, sp)
48415b81: 80 36                 mov     0x36, d0
48415b83: 42 48                 mov     d0, (0x48, sp)
48415b85: 80 02                 mov     2, d0
48415b87: dd b2 d4 be 03 30 08  call    0x4c003039, [a2,a3], 8
48415b8e: f1 e9                 mov     d2, a1
48415b90: 90 02                 mov     2, a0
48415b92: f1 78                 add     a2, a0
48415b94: 80 0c                 mov     0xc, d0
48415b96: dd a3 d4 be 03 30 08  call    0x4c003039, [a2,a3], 8
48415b9d: 98                    mov     a2, a0
48415b9e: 80 0e                 mov     0xe, d0
48415ba0: dd f4 c8 11 00 a0 24  call    0x48532494, [d2,a2], 0x24
48415ba7: a0 0e                 cmp     0xe, d0
48415ba9: c8 0d                 beq     0x48415bb6
48415bab: dd 14 c8 11 00 00 14  call    0x485323bf, 0, 0x14
48415bb2: 00                    clr     d0
48415bb3: df f0 94              ret     [d2,d3,a2,a3], 0x94
48415bb6: 80 28                 mov     0x28, d0
48415bb8: 42 5c                 mov     d0, (0x5c, sp)
48415bba: 58 18                 mov     (0x18, sp), d0
48415bbc: 3c                    mov     sp, a0
48415bbd: 42 60                 mov     d0, (0x60, sp)
48415bbf: 58 1c                 mov     (0x1c, sp), d0
48415bc1: 20 5c                 add     0x5c, a0
48415bc3: 42 64                 mov     d0, (0x64, sp)
48415bc5: 80 01                 mov     1, d0
48415bc7: f8 93 68              movhu   d0, (0x68, sp)
48415bca: 80 18                 mov     0x18, d0
48415bcc: f8 93 6a              movhu   d0, (0x6a, sp)
48415bcf: 00                    clr     d0
48415bd0: 42 6c                 mov     d0, (0x6c, sp)
48415bd2: 4e 70                 mov     d3, (0x70, sp)
48415bd4: 42 74                 mov     d0, (0x74, sp)
48415bd6: 42 78                 mov     d0, (0x78, sp)
48415bd8: 42 7c                 mov     d0, (0x7c, sp)
48415bda: 42 80                 mov     d0, (0x80, sp)
48415bdc: 80 28                 mov     0x28, d0
48415bde: dd b6 c8 11 00 a0 24  call    0x48532494, [d2,a2], 0x24
48415be5: a0 28                 cmp     0x28, d0
48415be7: c8 0d                 beq     0x48415bf4
48415be9: dd d6 c7 11 00 00 14  call    0x485323bf, 0, 0x14
48415bf0: 00                    clr     d0
48415bf1: df f0 94              ret     [d2,d3,a2,a3], 0x94
48415bf4: 58 20                 mov     (0x20, sp), d0
48415bf6: cd 34 0a b0 28        call    0x4841662a, [d2,a2,a3], 0x28
48415bfb: 43 14                 mov     a0, (0x14, sp)
48415bfd: b0 00                 cmp     0, a0
48415bff: c9 05                 bne     0x48415c04
48415c01: cc c8 00              jmp     0x48415cc9
48415c04: 00                    clr     d0
48415c05: 42 18                 mov     d0, (0x18, sp)
48415c07: 58 1c                 mov     (0x1c, sp), d0
48415c09: a0 00                 cmp     0, d0
48415c0b: c1 05                 bgt     0x48415c10
48415c0d: cc b5 00              jmp     0x48415cc2
48415c10: 04                    clr     d1
48415c11: 9f 00                 mov     0, a3
48415c13: 5b 1c                 mov     (0x1c, sp), d3
48415c15: f8 bc 36              movhu   (0x36, sp), d0
48415c18: f8 be 34              movhu   (0x34, sp), d2
48415c1b: 18                    exth    d0
48415c1c: 1a                    exth    d2
48415c1d: ec                    add     d3, d0
48415c1e: 5b 18                 mov     (0x18, sp), d3
48415c20: 28 ff                 add     -1, d0
48415c22: f1 0c                 sub     d3, d0
48415c24: f1 1c                 sub     a3, d0
48415c26: 2f 80 02              mov     0x280, d3
48415c29: cb                    nop
48415c2a: cb                    nop
48415c2b: f2 4c                 mul     d3, d0
48415c2d: e8                    add     d2, d0
48415c2e: e0                    add     d0, d0
48415c2f: fc c0 00 00 e0 9c     add     0x9ce00000, d0
48415c35: 26 00 05              mov     0x500, a2
48415c38: f1 62                 add     d0, a2
48415c3a: f8 bc 34              movhu   (0x34, sp), d0
48415c3d: 18                    exth    d0
48415c3e: f1 e1                 mov     d0, a1
48415c40: f8 bc 38              movhu   (0x38, sp), d0
48415c43: 18                    exth    d0
48415c44: f1 a1                 cmp     d0, a1
48415c46: c1 43                 bgt     0x48415c89
48415c48: db                    setlb
48415c49: f0 6e                 movhu   (a2), d3
48415c4b: 5c 14                 mov     (0x14, sp), a0
48415c4d: 86                    mov     d1, d2
48415c4e: 1a                    exth    d2
48415c4f: 1f                    exthu   d3
48415c50: 80 1f                 mov     0x1f, d0
48415c52: f2 0c                 and     d3, d0
48415c54: f8 c0 03              asl     3, d0
48415c57: f4                    movbu   d0, (d2, a0)
48415c58: 48                    inc     d2
48415c59: 5c 14                 mov     (0x14, sp), a0
48415c5b: 48                    inc     d2
48415c5c: 89                    mov     d2, d1
48415c5d: 19                    exth    d1
48415c5e: 2c e0 07              mov     0x7e0, d0
48415c61: f2 0c                 and     d3, d0
48415c63: f8 c8 03              asr     3, d0
48415c66: f4                    movbu   d0, (d1, a0)
48415c67: 44                    inc     d1
48415c68: 5c 14                 mov     (0x14, sp), a0
48415c6a: 1a                    exth    d2
48415c6b: 48                    inc     d2
48415c6c: 89                    mov     d2, d1
48415c6d: 19                    exth    d1
48415c6e: fa e3 00 f8           and     0xf800, d3
48415c72: f8 cb 08              asr     8, d3
48415c75: f4                    movbu   d3, (d1, a0)
48415c76: 74                    mov     (a0), d1
48415c77: 1a                    exth    d2
48415c78: f1 d4                 mov     a1, d0
48415c7a: 40                    inc     d0
48415c7b: 18                    exth    d0
48415c7c: f1 e1                 mov     d0, a1
48415c7e: f8 bc 38              movhu   (0x38, sp), d0
48415c81: 89                    mov     d2, d1
48415c82: 44                    inc     d1
48415c83: 22 02                 add     2, a2
48415c85: 18                    exth    d0
48415c86: f1 a1                 cmp     d0, a1
48415c88: d3                    lle
48415c89: f1 dc                 mov     a3, d0
48415c8b: 40                    inc     d0
48415c8c: 18                    exth    d0
48415c8d: f1 e3                 mov     d0, a3
48415c8f: a0 01                 cmp     1, d0
48415c91: c0 82                 blt     0x48415c13
48415c93: 5c 14                 mov     (0x14, sp), a0
48415c95: 58 20                 mov     (0x20, sp), d0
48415c97: dd fd c7 11 00 a0 24  call    0x48532494, [d2,a2], 0x24
48415c9e: 59 20                 mov     (0x20, sp), d1
48415ca0: a4                    cmp     d1, d0
48415ca1: c8 13                 beq     0x48415cb4
48415ca3: dd 1c c7 11 00 00 14  call    0x485323bf, 0, 0x14
48415caa: 5c 14                 mov     (0x14, sp), a0
48415cac: cd 32 0a f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
48415cb1: 00                    clr     d0
48415cb2: ca 20                 bra     0x48415cd2
48415cb4: 58 18                 mov     (0x18, sp), d0
48415cb6: 59 1c                 mov     (0x1c, sp), d1
48415cb8: 40                    inc     d0
48415cb9: 18                    exth    d0
48415cba: 42 18                 mov     d0, (0x18, sp)
48415cbc: a4                    cmp     d1, d0
48415cbd: c2 05                 bge     0x48415cc2
48415cbf: cc 51 ff              jmp     0x48415c10
48415cc2: 5c 14                 mov     (0x14, sp), a0
48415cc4: cd 1a 0a f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
48415cc9: dd f6 c6 11 00 00 14  call    0x485323bf, 0, 0x14
48415cd0: 80 01                 mov     1, d0
48415cd2: df f0 94              ret     [d2,d3,a2,a3], 0x94
48415cd5: f8 fe f4              add     -0xc, sp
48415cd8: 5c 1c                 mov     (0x1c, sp), a0
48415cda: cd 04 0a f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
48415cdf: 00                    clr     d0
48415ce0: df 00 0c              ret     0, 0xc
48415ce3: cf f0                 movm    [d2,d3,a2,a3], (sp)
48415ce5: f8 fe e4              add     -0x1c, sp
48415ce8: fc c9 60 00 06 00     cmp     0x60060, d1
48415cee: c8 1b                 beq     0x48415d09
48415cf0: fc c9 61 00 06 00     cmp     0x60061, d1
48415cf6: c9 05                 bne     0x48415cfb
48415cf8: cc 83 00              jmp     0x48415d7b
48415cfb: fc c9 5f 00 06 00     cmp     0x6005f, d1
48415d01: c9 05                 bne     0x48415d06
48415d03: cc 63 01              jmp     0x48415e66
48415d06: cc c8 01              jmp     0x48415ece
48415d09: 5e 3c                 mov     (0x3c, sp), a2
48415d0b: 80 18                 mov     0x18, d0
48415d0d: f0 0e                 mov     (a2), a3
48415d0f: cd 1b 09 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
48415d14: 43 14                 mov     a0, (0x14, sp)
48415d16: 99                    mov     a2, a1
48415d17: 85 fa                 mov     -6, d1
48415d19: db                    setlb
48415d1a: 71                    mov     (a1), d0
48415d1b: 51                    inc4    a1
48415d1c: 60                    mov     d0, (a0)
48415d1d: 50                    inc4    a0
48415d1e: 44                    inc     d1
48415d1f: d9                    lne
48415d20: f8 62 04              movhu   (4, a2), d0
48415d23: a0 01                 cmp     1, d0
48415d25: c8 0c                 beq     0x48415d31
48415d27: a0 02                 cmp     2, d0
48415d29: c8 14                 beq     0x48415d3d
48415d2b: a0 04                 cmp     4, d0
48415d2d: c8 1d                 beq     0x48415d4a
48415d2f: ca 21                 bra     0x48415d50
48415d31: 22 10                 add     0x10, a2
48415d33: 72                    mov     (a2), d0
48415d34: f0 53                 movbu   d0, (a3)
48415d36: 72                    mov     (a2), d0
48415d37: f8 e0 ff              and     0xff, d0
48415d3a: 62                    mov     d0, (a2)
48415d3b: ca 19                 bra     0x48415d54
48415d3d: 22 10                 add     0x10, a2
48415d3f: 72                    mov     (a2), d0
48415d40: f0 73                 movhu   d0, (a3)
48415d42: 72                    mov     (a2), d0
48415d43: fa e0 ff ff           and     0xffff, d0
48415d47: 62                    mov     d0, (a2)
48415d48: ca 0c                 bra     0x48415d54
48415d4a: f8 02 10              mov     (0x10, a2), d0
48415d4d: 63                    mov     d0, (a3)
48415d4e: ca 06                 bra     0x48415d54
48415d50: 00                    clr     d0
48415d51: f8 12 10              mov     d0, (0x10, a2)
48415d54: 5e 14                 mov     (0x14, sp), a2
48415d56: 80 ff                 mov     -1, d0
48415d58: 4b 10                 mov     a2, (0x10, sp)
48415d5a: fc cd 15 00 05 00     mov     0x00050015, d1
48415d60: dd 40 3b 01 00 80 1c  call    0x484298a0, [d2], 0x1c
48415d67: 4b 10                 mov     a2, (0x10, sp)
48415d69: 80 ff                 mov     -1, d0
48415d6b: fc cd 23 00 06 00     mov     0x00060023, d1
48415d71: dd 2f 3b 01 00 80 1c  call    0x484298a0, [d2], 0x1c
48415d78: cc 56 01              jmp     0x48415ece
48415d7b: 5f 3c                 mov     (0x3c, sp), a3
48415d7d: 73                    mov     (a3), d0
48415d7e: 42 14                 mov     d0, (0x14, sp)
48415d80: 80 04                 mov     4, d0
48415d82: f1 5c                 add     a3, d0
48415d84: 42 18                 mov     d0, (0x18, sp)
48415d86: f1 e0                 mov     d0, a0
48415d88: f0 64                 movhu   (a0), d1
48415d8a: a5 01                 cmp     1, d1
48415d8c: c8 0f                 beq     0x48415d9b
48415d8e: a5 02                 cmp     2, d1
48415d90: c8 28                 beq     0x48415db8
48415d92: 5c 14                 mov     (0x14, sp), a0
48415d94: a5 04                 cmp     4, d1
48415d96: 70                    mov     (a0), d0
48415d97: c8 40                 beq     0x48415dd7
48415d99: ca 3d                 bra     0x48415dd6
48415d9b: f8 07 08              mov     (8, a3), d1
48415d9e: f8 03 0c              mov     (0xc, a3), d0
48415da1: a1                    cmp     d0, d1
48415da2: c7 0c                 bls     0x48415dae
48415da4: 5c 14                 mov     (0x14, sp), a0
48415da6: f0 44                 movbu   (a0), d1
48415da8: f8 e1 ff              and     0xff, d1
48415dab: 84                    mov     d1, d0
48415dac: ca 2b                 bra     0x48415dd7
48415dae: 5c 14                 mov     (0x14, sp), a0
48415db0: f0 40                 movbu   (a0), d0
48415db2: f8 e0 ff              and     0xff, d0
48415db5: 10                    extb    d0
48415db6: ca 21                 bra     0x48415dd7
48415db8: f8 07 08              mov     (8, a3), d1
48415dbb: f8 03 0c              mov     (0xc, a3), d0
48415dbe: a1                    cmp     d0, d1
48415dbf: c7 0c                 bls     0x48415dcb
48415dc1: 5c 14                 mov     (0x14, sp), a0
48415dc3: f0 60                 movhu   (a0), d0
48415dc5: fa e0 ff ff           and     0xffff, d0
48415dc9: ca 0e                 bra     0x48415dd7
48415dcb: 5c 14                 mov     (0x14, sp), a0
48415dcd: f0 60                 movhu   (a0), d0
48415dcf: fa e0 ff ff           and     0xffff, d0
48415dd3: 18                    exth    d0
48415dd4: ca 03                 bra     0x48415dd7
48415dd6: 00                    clr     d0
48415dd7: 8f 10                 mov     0x10, d3
48415dd9: f1 5f                 add     a3, d3
48415ddb: f1 ec                 mov     d3, a0
48415ddd: 74                    mov     (a0), d1
48415dde: a5 00                 cmp     0, d1
48415de0: c3 14                 ble     0x48415df4
48415de2: 74                    mov     (a0), d1
48415de3: 95 08                 mov     8, a1
48415de5: f1 7d                 add     a3, a1
48415de7: 79                    mov     (a1), d2
48415de8: f1 06                 sub     d1, d2
48415dea: a2                    cmp     d0, d2
48415deb: c0 06                 blt     0x48415df1
48415ded: 78                    mov     (a0), d2
48415dee: e2                    add     d0, d2
48415def: ca 17                 bra     0x48415e06
48415df1: 79                    mov     (a1), d2
48415df2: ca 14                 bra     0x48415e06
48415df4: f1 ed                 mov     d3, a1
48415df6: 79                    mov     (a1), d2
48415df7: 90 0c                 mov     0xc, a0
48415df9: f1 7c                 add     a3, a0
48415dfb: 74                    mov     (a0), d1
48415dfc: f1 09                 sub     d2, d1
48415dfe: a1                    cmp     d0, d1
48415dff: c1 06                 bgt     0x48415e05
48415e01: 79                    mov     (a1), d2
48415e02: e2                    add     d0, d2
48415e03: ca 03                 bra     0x48415e06
48415e05: 78                    mov     (a0), d2
48415e06: 80 18                 mov     0x18, d0
48415e08: cd 22 08 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
48415e0d: 92                    mov     a0, a2
48415e0e: 99                    mov     a2, a1
48415e0f: 85 fa                 mov     -6, d1
48415e11: db                    setlb
48415e12: 73                    mov     (a3), d0
48415e13: 53                    inc4    a3
48415e14: 61                    mov     d0, (a1)
48415e15: 51                    inc4    a1
48415e16: 44                    inc     d1
48415e17: d9                    lne
48415e18: f8 1a 10              mov     d2, (0x10, a2)
48415e1b: 5c 18                 mov     (0x18, sp), a0
48415e1d: f0 64                 movhu   (a0), d1
48415e1f: a5 01                 cmp     1, d1
48415e21: c8 0c                 beq     0x48415e2d
48415e23: a5 02                 cmp     2, d1
48415e25: c8 0e                 beq     0x48415e33
48415e27: a5 04                 cmp     4, d1
48415e29: c8 10                 beq     0x48415e39
48415e2b: ca 13                 bra     0x48415e3e
48415e2d: 5c 14                 mov     (0x14, sp), a0
48415e2f: f0 58                 movbu   d2, (a0)
48415e31: ca 11                 bra     0x48415e42
48415e33: 5c 14                 mov     (0x14, sp), a0
48415e35: f0 78                 movhu   d2, (a0)
48415e37: ca 0b                 bra     0x48415e42
48415e39: 5c 14                 mov     (0x14, sp), a0
48415e3b: 68                    mov     d2, (a0)
48415e3c: ca 06                 bra     0x48415e42
48415e3e: 00                    clr     d0
48415e3f: f1 ec                 mov     d3, a0
48415e41: 60                    mov     d0, (a0)
48415e42: 4b 10                 mov     a2, (0x10, sp)
48415e44: 80 ff                 mov     -1, d0
48415e46: fc cd 15 00 05 00     mov     0x00050015, d1
48415e4c: dd 54 3a 01 00 80 1c  call    0x484298a0, [d2], 0x1c
48415e53: 4b 10                 mov     a2, (0x10, sp)
48415e55: 80 ff                 mov     -1, d0
48415e57: fc cd 23 00 06 00     mov     0x00060023, d1
48415e5d: dd 43 3a 01 00 80 1c  call    0x484298a0, [d2], 0x1c
48415e64: ca 6a                 bra     0x48415ece
48415e66: 5f 3c                 mov     (0x3c, sp), a3
48415e68: f8 63 04              movhu   (4, a3), d0
48415e6b: f0 07                 mov     (a3), a1
48415e6d: a0 01                 cmp     1, d0
48415e6f: c8 0c                 beq     0x48415e7b
48415e71: a0 02                 cmp     2, d0
48415e73: c8 12                 beq     0x48415e85
48415e75: a0 04                 cmp     4, d0
48415e77: c8 19                 beq     0x48415e90
48415e79: ca 1d                 bra     0x48415e96
48415e7b: f0 41                 movbu   (a1), d0
48415e7d: f8 e0 ff              and     0xff, d0
48415e80: f8 13 10              mov     d0, (0x10, a3)
48415e83: ca 17                 bra     0x48415e9a
48415e85: f0 61                 movhu   (a1), d0

GetSoundDev:
48416148: cf a0                 movm    [d2,a2], (sp)
4841614a: f8 fe e8              add     -0x18, sp
4841614d: 81                    mov     d0, d1
4841614e: 08                    clr     d2
4841614f: 3e                    mov     sp, a2
48416150: 22 10                 add     0x10, a2
48416152: 2c ff 00              mov     0xff, d0
48416155: f2 04                 and     d1, d0
48416157: f8 92 14              movbu   d0, (0x14, sp)
4841615a: fc cc 00 ff 00 00     mov     0x0000ff00, d0
48416160: f2 04                 and     d1, d0
48416162: f8 c4 08              lsr     8, d0
48416165: f8 92 13              movbu   d0, (0x13, sp)
48416168: 84                    mov     d1, d0
48416169: fc e0 00 00 ff 00     and     0x00ff0000, d0
4841616f: f8 c4 10              lsr     16, d0
48416172: f8 92 12              movbu   d0, (0x12, sp)
48416175: fc e1 00 00 00 ff     and     0xff000000, d1
4841617b: 84                    mov     d1, d0
4841617c: f8 c4 18              lsr     24, d0
4841617f: 14                    extbu   d0
48416180: 1c                    exthu   d0
48416181: cd 42 00 f0 20        call    0x484161c3, [d2,d3,a2,a3], 0x20
48416186: a8                    cmp     d2, d0
48416187: c8 09                 beq     0x48416190
48416189: 80 02                 mov     2, d0
4841618b: f8 92 15              movbu   d0, (0x15, sp)
4841618e: ca 07                 bra     0x48416195
48416190: 80 03                 mov     3, d0
48416192: f8 92 15              movbu   d0, (0x15, sp)
48416195: 98                    mov     a2, a0
48416196: dd 51 31 03 00 f0 38  call    0x484492e7, [d2,d3,a2,a3], 0x38
4841619d: f8 b8 15              movbu   (0x15, sp), d0
484161a0: a0 02                 cmp     2, d0
484161a2: c0 18                 blt     0x484161ba
484161a4: f8 b8 15              movbu   (0x15, sp), d0
484161a7: a0 0b                 cmp     0xb, d0
484161a9: c1 11                 bgt     0x484161ba
484161ab: f8 b8 15              movbu   (0x15, sp), d0
484161ae: 85 02                 mov     2, d1
484161b0: dd 25 b8 be 03 00 00  call    0x4c0019d5, 0, 0
484161b7: 8a ff                 mov     -1, d2
484161b9: e2                    add     d0, d2
484161ba: 88                    mov     d2, d0
484161bb: df a0 20              ret     [d2,a2], 0x20
484161be: cf f0                 movm    [d2,d3,a2,a3], (sp)
484161c0: f8 fe f0              add     -0x10, sp
484161c3: 1c                    exthu   d0
484161c4: f1 e3                 mov     d0, a3
484161c6: bf 12                 cmp     0x12, a3
484161c8: c3 05                 ble     0x484161cd
484161ca: 00                    clr     d0
484161cb: ca 36                 bra     0x48416201
484161cd: 08                    clr     d2
484161ce: 04                    clr     d1
484161cf: fc de 4c e3 59 48     mov     0x4859e34c, a2
484161d5: fc a0 4c e3 59 48     mov     (0x4859e34c), a0
484161db: 8f ff                 mov     -1, d3
484161dd: f1 ac                 cmp     d3, a0
484161df: c8 21                 beq     0x48416200
484161e1: 55                    asl2    d1
484161e2: f3 06                 mov     (d1, a2), d0
484161e4: 04                    clr     d1
484161e5: dd 15 e8 bf 03 00 10  call    0x4c0149fa, 0, 0x10
484161ec: 1c                    exthu   d0
484161ed: f1 a3                 cmp     d0, a3
484161ef: c9 06                 bne     0x484161f5
484161f1: 80 01                 mov     1, d0
484161f3: ca 0e                 bra     0x48416201
484161f5: 1e                    exthu   d2
484161f6: 48                    inc     d2
484161f7: 89                    mov     d2, d1
484161f8: 1d                    exthu   d1
484161f9: 84                    mov     d1, d0
484161fa: 54                    asl2    d0
484161fb: f3 02                 mov     (d0, a2), d0
484161fd: ac                    cmp     d3, d0
484161fe: c9 e3                 bne     0x484161e1
48416200: 00                    clr     d0
48416201: df f0 20              ret     [d2,d3,a2,a3], 0x20
48416204: f8 fe ec              add     -0x14, sp
48416207: fc c9 56 00 06 00     cmp     0x60056, d1
4841620d: c9 1d                 bne     0x4841622a
4841620f: fc cc 00 c0 00 00     mov     0x0000c000, d0
48416215: 3c                    mov     sp, a0
48416216: 20 10                 add     0x10, a0
48416218: dd 30 e7 bf 03 e0 24  call    0x4c014948, [d2,d3,a2], 0x24
4841621f: 5c 24                 mov     (0x24, sp), a0
48416221: 58 10                 mov     (0x10, sp), d0
48416223: dd 00 da 01 00 b0 20  call    0x48433c23, [d2,a2,a3], 0x20
4841622a: 00                    clr     d0
4841622b: df 00 14              ret     0, 0x14
4841622e: cf f0                 movm    [d2,d3,a2,a3], (sp)
48416230: f8 fe e0              add     -0x20, sp
48416233: fc c9 57 00 06 00     cmp     0x60057, d1
48416239: c8 05                 beq     0x4841623e
4841623b: cc c0 00              jmp     0x484162fb
4841623e: 3f                    mov     sp, a3
4841623f: 23 1c                 add     0x1c, a3
48416241: 80 08                 mov     8, d0
48416243: cd e7 03 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
48416248: f1 d3                 mov     a0, d3
4841624a: 80 11                 mov     0x11, d0
4841624c: cd de 03 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
48416251: 43 14                 mov     a0, (0x14, sp)
48416253: dd c8 b9 c0 03 00 00  call    0x4c021c1b, 0, 0
4841625a: 9c                    mov     a3, a0
4841625b: 9a 02                 mov     2, a2
4841625d: f1 6e                 add     d3, a2
4841625f: 82                    mov     d0, d2
48416260: 2c 80 00              mov     0x80, d0
48416263: dd e5 e6 bf 03 e0 24  call    0x4c014948, [d2,d3,a2], 0x24
4841626a: 58 1c                 mov     (0x1c, sp), d0
4841626c: 9c                    mov     a3, a0
4841626d: f8 e0 ff              and     0xff, d0
48416270: 14                    extbu   d0
48416271: f0 72                 movhu   d0, (a2)
48416273: 58 14                 mov     (0x14, sp), d0
48416275: 16                    extbu   d2
48416276: 42 18                 mov     d0, (0x18, sp)
48416278: 42 1c                 mov     d0, (0x1c, sp)
4841627a: 2c 40 60              mov     0x6040, d0
4841627d: dd cb e6 bf 03 e0 24  call    0x4c014948, [d2,d3,a2], 0x24
48416284: f0 62                 movhu   (a2), d0
48416286: 85 08                 mov     8, d1
48416288: 28 ff                 add     -1, d0
4841628a: dd 4b b7 be 03 00 00  call    0x4c0019d5, 0, 0
48416291: a2                    cmp     d0, d2
48416292: c9 1d                 bne     0x484162af
48416294: dd e2 b9 c0 03 00 00  call    0x4c021c76, 0, 0
4841629b: 14                    extbu   d0
4841629c: a0 00                 cmp     0, d0
4841629e: c8 0a                 beq     0x484162a8
484162a0: 80 01                 mov     1, d0
484162a2: f1 ec                 mov     d3, a0
484162a4: f0 70                 movhu   d0, (a0)
484162a6: ca 15                 bra     0x484162bb
484162a8: 00                    clr     d0
484162a9: f1 ec                 mov     d3, a0
484162ab: f0 70                 movhu   d0, (a0)
484162ad: ca 0e                 bra     0x484162bb
484162af: f8 c2 03              asl     3, d2
484162b2: 88                    mov     d2, d0
484162b3: 40                    inc     d0
484162b4: f0 72                 movhu   d0, (a2)
484162b6: 00                    clr     d0
484162b7: f1 ec                 mov     d3, a0
484162b9: f0 70                 movhu   d0, (a0)
484162bb: 58 14                 mov     (0x14, sp), d0
484162bd: fc cd 1a 00 05 00     mov     0x0005001a, d1
484162c3: f8 10 04              mov     d0, (4, a0)
484162c6: 5c 14                 mov     (0x14, sp), a0
484162c8: 00                    clr     d0
484162c9: f8 50 10              movbu   d0, (0x10, a0)
484162cc: 4e 10                 mov     d3, (0x10, sp)
484162ce: 80 ff                 mov     -1, d0
484162d0: dd d0 35 01 00 80 1c  call    0x484298a0, [d2], 0x1c
484162d7: 4e 10                 mov     d3, (0x10, sp)
484162d9: 80 ff                 mov     -1, d0
484162db: fc cd 23 00 06 00     mov     0x00060023, d1
484162e1: dd bf 35 01 00 80 1c  call    0x484298a0, [d2], 0x1c
484162e8: 58 18                 mov     (0x18, sp), d0
484162ea: fc cd 23 00 06 00     mov     0x00060023, d1
484162f0: 42 10                 mov     d0, (0x10, sp)
484162f2: 80 ff                 mov     -1, d0
484162f4: dd ac 35 01 00 80 1c  call    0x484298a0, [d2], 0x1c
484162fb: 00                    clr     d0
484162fc: df f0 30              ret     [d2,d3,a2,a3], 0x30
484162ff: f8 fe f4              add     -0xc, sp
48416302: fc c9 e3 00 06 00     cmp     0x600e3, d1
48416308: c8 24                 beq     0x4841632c
4841630a: fc c9 e2 00 06 00     cmp     0x600e2, d1
48416310: c8 0c                 beq     0x4841631c
48416312: fc c9 00 00 05 00     cmp     0x50000, d1
48416318: c8 11                 beq     0x48416329
4841631a: ca 12                 bra     0x4841632c
4841631c: 58 1c                 mov     (0x1c, sp), d0
4841631e: 14                    extbu   d0
4841631f: dd 3c af c0 03 c0 08  call    0x4c02125b, [d2,d3], 8
48416326: 18                    exth    d0
48416327: ca 06                 bra     0x4841632d
48416329: 00                    clr     d0
4841632a: ca 03                 bra     0x4841632d
4841632c: 00                    clr     d0
4841632d: df 00 0c              ret     0, 0xc
48416330: 00                    clr     d0
48416331: de 00 00              retf    0, 0
48416334: 5c 10                 mov     (0x10, sp), a0
48416336: e4                    add     d1, d0
48416337: f1 50                 add     a0, d0
48416339: de 00 00              retf    0, 0
4841633c: cf e0                 movm    [d2,d3,a2], (sp)
4841633e: f8 fe e8              add     -0x18, sp
48416341: 0c                    clr     d3
48416342: fc c9 bf 00 06 00     cmp     0x600bf, d1
48416348: c8 3c                 beq     0x48416384
4841634a: fc c9 c0 00 06 00     cmp     0x600c0, d1
48416350: c9 05                 bne     0x48416355
48416352: cc 90 00              jmp     0x484163e2
48416355: fc c9 c1 00 06 00     cmp     0x600c1, d1
4841635b: c9 05                 bne     0x48416360
4841635d: cc a4 00              jmp     0x48416401
48416360: fc c9 cf 00 06 00     cmp     0x600cf, d1
48416366: c9 05                 bne     0x4841636b
48416368: cc be 00              jmp     0x48416426
4841636b: fc c9 d0 00 06 00     cmp     0x600d0, d1
48416371: c9 05                 bne     0x48416376
48416373: cc d8 00              jmp     0x4841644b
48416376: fc c9 d1 00 06 00     cmp     0x600d1, d1
4841637c: c9 05                 bne     0x48416381
4841637e: cc f4 00              jmp     0x48416472
48416381: cc 07 01              jmp     0x48416488
48416384: 5c 34                 mov     (0x34, sp), a0
48416386: 78                    mov     (a0), d2
48416387: f8 00 04              mov     (4, a0), d0
4841638a: 3c                    mov     sp, a0
4841638b: 42 14                 mov     d0, (0x14, sp)
4841638d: 88                    mov     d2, d0
4841638e: 20 14                 add     0x14, a0
48416390: dd b8 e5 bf 03 e0 24  call    0x4c014948, [d2,d3,a2], 0x24
48416397: a0 ff                 cmp     -1, d0
48416399: c9 05                 bne     0x4841639e
4841639b: cc ed 00              jmp     0x48416488
4841639e: 80 10                 mov     0x10, d0
484163a0: cd 8a 02 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
484163a5: 92                    mov     a0, a2
484163a6: 6a                    mov     d2, (a2)
484163a7: 58 14                 mov     (0x14, sp), d0
484163a9: fc cd 14 00 05 00     mov     0x00050014, d1
484163af: f8 12 04              mov     d0, (4, a2)
484163b2: 43 10                 mov     a0, (0x10, sp)
484163b4: 80 ff                 mov     -1, d0
484163b6: dd c8 29 01 00 f0 60  call    0x48428d7e, [d2,d3,a2,a3], 0x60
484163bd: 4b 10                 mov     a2, (0x10, sp)
484163bf: 80 ff                 mov     -1, d0
484163c1: fc cd 14 00 05 00     mov     0x00050014, d1
484163c7: dd d9 34 01 00 80 1c  call    0x484298a0, [d2], 0x1c
484163ce: 4b 10                 mov     a2, (0x10, sp)
484163d0: 80 ff                 mov     -1, d0
484163d2: fc cd 23 00 06 00     mov     0x00060023, d1
484163d8: dd c8 34 01 00 80 1c  call    0x484298a0, [d2], 0x1c
484163df: cc a9 00              jmp     0x48416488
484163e2: 5c 34                 mov     (0x34, sp), a0
484163e4: 78                    mov     (a0), d2
484163e5: f8 04 04              mov     (4, a0), d1
484163e8: fc e2 ff ff ff 00     and     0x00ffffff, d2
484163ee: 46 14                 mov     d1, (0x14, sp)
484163f0: fc c2 00 00 00 90     add     0x90000000, d2
484163f6: 88                    mov     d2, d0
484163f7: dd 5f e6 bf 03 e0 24  call    0x4c014a56, [d2,d3,a2], 0x24
484163fe: cc 8a 00              jmp     0x48416488
48416401: 5c 34                 mov     (0x34, sp), a0
48416403: 78                    mov     (a0), d2
48416404: f8 00 04              mov     (4, a0), d0
48416407: fc e2 ff ff ff 00     and     0x00ffffff, d2
4841640d: 42 14                 mov     d0, (0x14, sp)
4841640f: f8 64 08              movhu   (8, a0), d1
48416412: fc c2 00 00 00 90     add     0x90000000, d2
48416418: 19                    exth    d1
48416419: 3c                    mov     sp, a0
4841641a: 20 14                 add     0x14, a0
4841641c: 88                    mov     d2, d0
4841641d: dd 9e e9 bf 03 f0 2c  call    0x4c014dbb, [d2,d3,a2,a3], 0x2c
48416424: ca 64                 bra     0x48416488
48416426: fc dd e0 02 00 50     mov     0x500002e0, a1
4841642c: db                    setlb
4841642d: 71                    mov     (a1), d0
4841642e: fc c8 00 00 00 ff     cmp     0xff000000, d0
48416434: c8 54                 beq     0x48416488
48416436: 71                    mov     (a1), d0
48416437: 5c 34                 mov     (0x34, sp), a0
48416439: f1 90                 cmp     a0, d0
4841643b: c9 06                 bne     0x48416441
4841643d: 8f 01                 mov     1, d3
4841643f: ca 49                 bra     0x48416488
48416441: 51                    inc4    a1
48416442: fc d9 e0 06 00 50     cmp     0x500006e0, a1
48416448: d4                    lcs
48416449: ca 3f                 bra     0x48416488
4841644b: fc dd e0 02 00 50     mov     0x500002e0, a1
48416451: db                    setlb
48416452: 71                    mov     (a1), d0
48416453: fc c8 00 00 00 ff     cmp     0xff000000, d0
48416459: c9 08                 bne     0x48416461
4841645b: 5c 34                 mov     (0x34, sp), a0
4841645d: f0 11                 mov     a0, (a1)
4841645f: ca 29                 bra     0x48416488
48416461: 71                    mov     (a1), d0
48416462: 5c 34                 mov     (0x34, sp), a0
48416464: f1 90                 cmp     a0, d0
48416466: c8 22                 beq     0x48416488
48416468: 51                    inc4    a1
48416469: fc d9 e0 06 00 50     cmp     0x500006e0, a1
4841646f: d4                    lcs
48416470: ca 18                 bra     0x48416488
48416472: fc dc e0 02 00 50     mov     0x500002e0, a0
48416478: db                    setlb
48416479: fc cc 00 00 00 ff     mov     0xff000000, d0
4841647f: 60                    mov     d0, (a0)
48416480: 50                    inc4    a0
48416481: fc d8 e0 06 00 50     cmp     0x500006e0, a0
48416487: d4                    lcs
48416488: 8c                    mov     d3, d0
48416489: df e0 24              ret     [d2,d3,a2], 0x24

GetPartSelect:
4841648c: f8 fe ec              add     -0x14, sp
4841648f: 3c                    mov     sp, a0
48416490: 20 10                 add     0x10, a0
48416492: fc cc 41 80 00 00     mov     0x00008041, d0
48416498: dd b0 e4 bf 03 e0 24  call    0x4c014948, [d2,d3,a2], 0x24
4841649f: 58 10                 mov     (0x10, sp), d0
484164a1: f8 e0 ff              and     0xff, d0
484164a4: 14                    extbu   d0
484164a5: df 00 14              ret     0, 0x14

GetIntTimeID:
484164a8: 1c                 exthu   d0
484164a9: a0 00              cmp     0, d0
484164ab: c8 18              beq     0x484164c3
484164ad: a0 01              cmp     1, d0
484164af: c8 18              beq     0x484164c7
484164b1: a0 02              cmp     2, d0
484164b3: c8 1c              beq     0x484164cf
484164b5: a0 03              cmp     3, d0
484164b7: c8 20              beq     0x484164d7
484164b9: a0 04              cmp     4, d0
484164bb: c8 24              beq     0x484164df
484164bd: a0 05              cmp     5, d0
484164bf: c8 28              beq     0x484164e7
484164c1: ca 2e              bra     0x484164ef
484164c3: 80 01              mov     1, d0
484164c5: ca 2c              bra     0x484164f1
484164c7: fc ac 86 35 0d 50  movhu   (0x500d3586), d0
484164cd: ca 24              bra     0x484164f1
484164cf: fc ac 88 35 0d 50  movhu   (0x500d3588), d0
484164d5: ca 1c              bra     0x484164f1
484164d7: fc ac 8c 35 0d 50  movhu   (0x500d358c), d0
484164dd: ca 14              bra     0x484164f1
484164df: fc ac 8e 35 0d 50  movhu   (0x500d358e), d0
484164e5: ca 0c              bra     0x484164f1
484164e7: fc ac 90 35 0d 50  movhu   (0x500d3590), d0
484164ed: ca 04              bra     0x484164f1
484164ef: 80 01              mov     1, d0
484164f1: de 00 00           retf    0, 0

SetOtherPartLed:
484164f4: f8 fe f4              add     -0xc, sp
484164f7: a0 00                 cmp     0, d0
484164f9: c8 0d                 beq     0x48416506
484164fb: 80 05                 mov     5, d0
484164fd: dd ce b6 09 00 00 0c  call    0x484b1bcb, 0, 0xc
48416504: ca 0b                 bra     0x4841650f
48416506: 80 05                 mov     5, d0
48416508: dd 99 b7 09 00 00 0c  call    0x484b1ca1, 0, 0xc
4841650f: df 00 0c              ret     0, 0xc

SetHoldLed:
48416512: f8 fe f4              add     -0xc, sp
48416515: fc 81 f8 1f 02 50     mov     d0, (0x50021ff8)
4841651b: a0 00                 cmp     0, d0
4841651d: c8 0d                 beq     0x4841652a
4841651f: 80 01                 mov     1, d0
48416521: dd aa b6 09 00 00 0c  call    0x484b1bcb, 0, 0xc
48416528: ca 0b                 bra     0x48416533
4841652a: 80 01                 mov     1, d0
4841652c: dd 75 b7 09 00 00 0c  call    0x484b1ca1, 0, 0xc
48416533: df 00 0c              ret     0, 0xc

BlinkHoldLed:
48416536: f8 fe f4              add     -0xc, sp
48416539: fc 81 fc 1f 02 50     mov     d0, (0x50021ffc)
4841653f: a0 00                 cmp     0, d0
48416541: c8 0d                 beq     0x4841654e
48416543: 80 42                 mov     0x42, d0
48416545: dd 22 b8 09 00 80 04  call    0x484b1d67, [d2], 4
4841654c: ca 0b                 bra     0x48416557
4841654e: 80 42                 mov     0x42, d0
48416550: dd 7e b8 09 00 80 04  call    0x484b1dce, [d2], 4
48416557: df 00 0c              ret     0, 0xc

CheckHoldLED:
4841655a: fc a4 f8 1f 02 50  mov     (0x50021ff8), d0
48416560: de 00 00           retf    0, 0

SetDialLed:
48416563: f8 fe f4              add     -0xc, sp
48416566: fc 81 00 20 02 50     mov     d0, (0x50022000)
4841656c: a0 00                 cmp     0, d0
4841656e: c8 0d                 beq     0x4841657b
48416570: 80 04                 mov     4, d0
48416572: dd 59 b6 09 00 00 0c  call    0x484b1bcb, 0, 0xc
48416579: ca 0b                 bra     0x48416584
4841657b: 80 04                 mov     4, d0
4841657d: dd 24 b7 09 00 00 0c  call    0x484b1ca1, 0, 0xc
48416584: df 00 0c              ret     0, 0xc

CheckDialLED:
48416587: fc a4 00 20 02 50  mov     (0x50022000), d0
4841658d: de 00 00           retf    0, 0

SetModeLed:
48416590: cf c0                 movm    [d2,d3], (sp)
48416592: f8 fe f4              add     -0xc, sp
48416595: 83                    mov     d0, d3
48416596: fc a8 d4 1f 02 50     movbu   (0x50021fd4), d0
4841659c: 2e ff 00              mov     0xff, d2
4841659f: a8                    cmp     d2, d0
484165a0: c8 09                 beq     0x484165a9
484165a2: dd ff b6 09 00 00 0c  call    0x484b1ca1, 0, 0xc
484165a9: 1f                    exthu   d3
484165aa: fc dc 64 e3 59 48     mov     0x4859e364, a0
484165b0: f4                    movbu   (d3, a0), d0
484165b1: 0c                    clr     d3
484165b2: fc 82 d4 1f 02 50     movbu   d0, (0x50021fd4)
484165b8: fc a8 d4 1f 02 50     movbu   (0x50021fd4), d0
484165be: a8                    cmp     d2, d0
484165bf: c8 09                 beq     0x484165c8
484165c1: dd 0a b6 09 00 00 0c  call    0x484b1bcb, 0, 0xc
484165c8: df c0 14              ret     [d2,d3], 0x14
484165cb: f8 fe f0              add     -0x10, sp
484165ce: 80 06                 mov     6, d0
484165d0: fc 83 04 a0 02 50     movhu   d0, (0x5002a004)
484165d6: fc dc 74 e3 59 48     mov     0x4859e374, a0
484165dc: dd 13 62 c2 03 00 00  call    0x4c03c7ef, 0, 0
484165e3: df 00 10              ret     0, 0x10
484165e6: 81                    mov     d0, d1
484165e7: a5 00                 cmp     0, d1
484165e9: c9 0a                 bne     0x484165f3
484165eb: fc a0 e4 06 00 50     mov     (0x500006e4), a0
484165f1: ca 31                 bra     0x48416622
484165f3: fc a0 e4 06 00 50     mov     (0x500006e4), a0
484165f9: f1 a0                 cmp     d0, a0
484165fb: c6 0a                 bcc     0x48416605
484165fd: fc dc ff ff ff ff     mov     0xffffffff, a0
48416603: ca 1f                 bra     0x48416622
48416605: fc a0 e0 06 00 50     mov     (0x500006e0), a0
4841660b: fc a4 e4 06 00 50     mov     (0x500006e4), d0
48416611: f1 04                 sub     d1, d0
48416613: fc 81 e4 06 00 50     mov     d0, (0x500006e4)
48416619: f1 d0                 mov     a0, d0
4841661b: e4                    add     d1, d0
4841661c: fc 81 e0 06 00 50     mov     d0, (0x500006e0)
48416622: de 00 00              retf    0, 0
48416625: cf b0                 movm    [d2,a2,a3], (sp)
48416627: f8 fe e4              add     -0x1c, sp
4841662a: 3c                    mov     sp, a0
4841662b: 20 18                 add     0x18, a0
4841662d: 85 01                 mov     1, d1
4841662f: 8a 03                 mov     3, d2
48416631: e2                    add     d0, d2
48416632: 80 01                 mov     1, d0
48416634: 42 14                 mov     d0, (0x14, sp)
48416636: fc ac 04 a0 02 50     movhu   (0x5002a004), d0
4841663c: f8 c6 02              lsr     2, d2
4841663f: 18                    exth    d0
48416640: dd 6f 5f c2 03 00 00  call    0x4c03c5af, 0, 0
48416647: fc a2 e8 06 00 50     mov     (0x500006e8), a2
4841664d: 56                    asl2    d2
4841664e: ba 00                 cmp     0, a2
48416650: c8 0f                 beq     0x4841665f
48416652: db                    setlb
48416653: f8 02 04              mov     (4, a2), d0
48416656: a8                    cmp     d2, d0
48416657: c6 08                 bcc     0x4841665f
48416659: 9b                    mov     a2, a3
4841665a: f0 0a                 mov     (a2), a2
4841665c: ba 00                 cmp     0, a2
4841665e: d9                    lne
4841665f: ba 00                 cmp     0, a2
48416661: c8 37                 beq     0x48416698
48416663: 99                    mov     a2, a1
48416664: 51                    inc4    a1
48416665: 71                    mov     (a1), d0
48416666: f1 08                 sub     d2, d0
48416668: a0 0c                 cmp     0xc, d0
4841666a: c4 18                 bcs     0x48416682
4841666c: 72                    mov     (a2), d0
4841666d: 85 08                 mov     8, d1
4841666f: f1 59                 add     a2, d1
48416671: e9                    add     d2, d1
48416672: f1 e4                 mov     d1, a0
48416674: 60                    mov     d0, (a0)
48416675: 71                    mov     (a1), d0
48416676: 85 08                 mov     8, d1
48416678: f1 04                 sub     d1, d0
4841667a: f1 08                 sub     d2, d0
4841667c: f8 10 04              mov     d0, (4, a0)
4841667f: f0 12                 mov     a0, (a2)
48416681: 69                    mov     d2, (a1)
48416682: fc a0 e8 06 00 50     mov     (0x500006e8), a0
48416688: b2                    cmp     a0, a2
48416689: c9 0b                 bne     0x48416694
4841668b: 72                    mov     (a2), d0
4841668c: fc 81 e8 06 00 50     mov     d0, (0x500006e8)
48416692: ca 30                 bra     0x484166c2
48416694: 72                    mov     (a2), d0
48416695: 63                    mov     d0, (a3)
48416696: ca 2c                 bra     0x484166c2
48416698: 80 08                 mov     8, d0
4841669a: e8                    add     d2, d0
4841669b: cd 4b ff 00 00        call    0x484165e6, 0, 0
484166a0: 92                    mov     a0, a2
484166a1: fc d8 ff ff ff ff     cmp     0xffffffff, a0
484166a7: c9 16                 bne     0x484166bd
484166a9: fc ac 04 a0 02 50     movhu   (0x5002a004), d0
484166af: 85 01                 mov     1, d1
484166b1: 18                    exth    d0
484166b2: dd cd 66 c2 03 00 00  call    0x4c03cd7f, 0, 0
484166b9: 90 00                 mov     0, a0
484166bb: ca 1b                 bra     0x484166d6
484166bd: 00                    clr     d0
484166be: 62                    mov     d0, (a2)
484166bf: f8 1a 04              mov     d2, (4, a2)
484166c2: fc ac 04 a0 02 50     movhu   (0x5002a004), d0
484166c8: 85 01                 mov     1, d1
484166ca: 18                    exth    d0
484166cb: dd b4 66 c2 03 00 00  call    0x4c03cd7f, 0, 0
484166d2: 90 08                 mov     8, a0
484166d4: f1 78                 add     a2, a0
484166d6: df b0 28              ret     [d2,a2,a3], 0x28
484166d9: cf f0                 movm    [d2,d3,a2,a3], (sp)
484166db: f8 fe e4              add     -0x1c, sp
484166de: f1 d2                 mov     a0, d2
484166e0: aa 00                 cmp     0, d2
484166e2: c9 05                 bne     0x484166e7
484166e4: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
484166e7: 80 01                 mov     1, d0
484166e9: 42 14                 mov     d0, (0x14, sp)
484166eb: fc ac 04 a0 02 50     movhu   (0x5002a004), d0
484166f1: 3c                    mov     sp, a0
484166f2: 20 18                 add     0x18, a0
484166f4: 18                    exth    d0
484166f5: 85 01                 mov     1, d1
484166f7: dd b8 5e c2 03 00 00  call    0x4c03c5af, 0, 0
484166fe: fc a2 e8 06 00 50     mov     (0x500006e8), a2
48416704: 80 08                 mov     8, d0
48416706: f1 02                 sub     d0, d2
48416708: ba 00                 cmp     0, a2
4841670a: c9 1f                 bne     0x48416729
4841670c: f1 e8                 mov     d2, a0
4841670e: 00                    clr     d0
4841670f: 60                    mov     d0, (a0)
48416710: fc 80 e8 06 00 50     mov     a0, (0x500006e8)
48416716: fc ac 04 a0 02 50     movhu   (0x5002a004), d0
4841671c: 85 01                 mov     1, d1
4841671e: 18                    exth    d0
4841671f: dd 60 66 c2 03 00 00  call    0x4c03cd7f, 0, 0
48416726: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
48416729: 99                    mov     a2, a1
4841672a: 97                    mov     a1, a3
4841672b: bf 00                 cmp     0, a3
4841672d: c8 0d                 beq     0x4841673a
4841672f: db                    setlb
48416730: f1 96                 cmp     a1, d2
48416732: c7 08                 bls     0x4841673a
48416734: 97                    mov     a1, a3
48416735: f0 05                 mov     (a1), a1
48416737: b5 00                 cmp     0, a1
48416739: d9                    lne
4841673a: f1 96                 cmp     a1, d2
4841673c: c9 15                 bne     0x48416751
4841673e: fc ac 04 a0 02 50     movhu   (0x5002a004), d0
48416744: 85 01                 mov     1, d1
48416746: 18                    exth    d0
48416747: dd 38 66 c2 03 00 00  call    0x4c03cd7f, 0, 0
4841674e: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
48416751: 8f 04                 mov     4, d3
48416753: eb                    add     d2, d3
48416754: f1 ec                 mov     d3, a0
48416756: 70                    mov     (a0), d0
48416757: f1 e8                 mov     d2, a0
48416759: f1 60                 add     d0, a0
4841675b: 20 08                 add     8, a0
4841675d: b9                    cmp     a2, a1
4841675e: c9 39                 bne     0x48416797
48416760: b8                    cmp     a2, a0
48416761: c9 1a                 bne     0x4841677b
48416763: 72                    mov     (a2), d0
48416764: f1 e8                 mov     d2, a0
48416766: 60                    mov     d0, (a0)
48416767: fc a0 e8 06 00 50     mov     (0x500006e8), a0
4841676d: f8 00 04              mov     (4, a0), d0
48416770: f1 ec                 mov     d3, a0
48416772: 74                    mov     (a0), d1
48416773: f1 ec                 mov     d3, a0
48416775: e1                    add     d0, d1
48416776: 29 08                 add     8, d1
48416778: 64                    mov     d1, (a0)
48416779: ca 06                 bra     0x4841677f
4841677b: f1 e8                 mov     d2, a0
4841677d: f0 18                 mov     a2, (a0)
4841677f: fc 89 e8 06 00 50     mov     d2, (0x500006e8)
48416785: fc ac 04 a0 02 50     movhu   (0x5002a004), d0
4841678b: 85 01                 mov     1, d1
4841678d: 18                    exth    d0
4841678e: dd f1 65 c2 03 00 00  call    0x4c03cd7f, 0, 0
48416795: ca 48                 bra     0x484167dd
48416797: b5 00                 cmp     0, a1
48416799: c8 15                 beq     0x484167ae
4841679b: b4                    cmp     a1, a0
4841679c: c9 12                 bne     0x484167ae
4841679e: 71                    mov     (a1), d0
4841679f: f1 e8                 mov     d2, a0
484167a1: 60                    mov     d0, (a0)
484167a2: f1 ec                 mov     d3, a0
484167a4: 74                    mov     (a0), d1
484167a5: f8 01 04              mov     (4, a1), d0
484167a8: e1                    add     d0, d1
484167a9: 29 08                 add     8, d1
484167ab: 64                    mov     d1, (a0)
484167ac: ca 06                 bra     0x484167b2
484167ae: f1 e8                 mov     d2, a0
484167b0: f0 14                 mov     a1, (a0)
484167b2: 9d                    mov     a3, a1
484167b3: 51                    inc4    a1
484167b4: 71                    mov     (a1), d0
484167b5: 9c                    mov     a3, a0
484167b6: f1 60                 add     d0, a0
484167b8: 20 08                 add     8, a0
484167ba: f1 a8                 cmp     d2, a0
484167bc: c9 10                 bne     0x484167cc
484167be: f1 e8                 mov     d2, a0
484167c0: 70                    mov     (a0), d0
484167c1: f1 ec                 mov     d3, a0
484167c3: 63                    mov     d0, (a3)
484167c4: 75                    mov     (a1), d1
484167c5: 70                    mov     (a0), d0
484167c6: e1                    add     d0, d1
484167c7: 29 08                 add     8, d1
484167c9: 65                    mov     d1, (a1)
484167ca: ca 03                 bra     0x484167cd
484167cc: 6b                    mov     d2, (a3)
484167cd: fc ac 04 a0 02 50     movhu   (0x5002a004), d0
484167d3: 85 01                 mov     1, d1
484167d5: 18                    exth    d0
484167d6: dd a9 65 c2 03 00 00  call    0x4c03cd7f, 0, 0
484167dd: df f0 2c              ret     [d2,d3,a2,a3], 0x2c

SetZeroPoint:
484167e0: cf 80                 movm    [d2], (sp)
484167e2: 82                    mov     d0, d2
484167e3: fc ac 74 3c 0d 50     movhu   (0x500d3c74), d0
484167e9: fc ad 76 3c 0d 50     movhu   (0x500d3c76), d1
484167ef: 1c                    exthu   d0
484167f0: f8 c0 10              asl     16, d0
484167f3: 1d                    exthu   d1
484167f4: e4                    add     d1, d0
484167f5: 89                    mov     d2, d1
484167f6: f8 c5 10              lsr     16, d1
484167f9: fa e1 ff ff           and     0xffff, d1
484167fd: fc 87 74 3c 0d 50     movhu   d1, (0x500d3c74)
48416803: fc 8b 76 3c 0d 50     movhu   d2, (0x500d3c76)
48416809: de 80 04              retf    [d2], 4
4841680c: fc 81 78 3c 0d 50     mov     d0, (0x500d3c78)
48416812: de 00 00              retf    0, 0
48416815: f8 fe f8              add     -8, sp
48416818: dd 34 b5 00 00 00 00  call    0x48421d4c, 0, 0
4841681f: 1c                    exthu   d0
48416820: a0 02                 cmp     2, d0
48416822: c9 06                 bne     0x48416828
48416824: 80 01                 mov     1, d0
48416826: ca 03                 bra     0x48416829
48416828: 00                    clr     d0
48416829: df 00 08              ret     0, 8
4841682c: cf 80                 movm    [d2], (sp)
4841682e: 1c                    exthu   d0
4841682f: fc e0 7f ff ff ff     and     0xffffff7f, d0
48416835: 1c                    exthu   d0
48416836: 08                    clr     d2
48416837: a8                    cmp     d2, d0
48416838: c0 04                 blt     0x4841683c
4841683a: 8a 01                 mov     1, d2
4841683c: 04                    clr     d1
4841683d: a0 0f                 cmp     0xf, d0
4841683f: c1 04                 bgt     0x48416843
48416841: 85 01                 mov     1, d1
48416843: f2 06                 and     d1, d2
48416845: c8 06                 beq     0x4841684b
48416847: 80 01                 mov     1, d0
48416849: ca 03                 bra     0x4841684c
4841684b: 00                    clr     d0
4841684c: de 80 04              retf    [d2], 4
4841684f: cf 80                 movm    [d2], (sp)
48416851: f8 fe ec              add     -0x14, sp
48416854: 82                    mov     d0, d2
48416855: cd c3 ff 00 08        call    0x48416818, 0, 8
4841685a: a0 00                 cmp     0, d0
4841685c: c8 2b                 beq     0x48416887
4841685e: fc a5 78 3c 0d 50     mov     (0x500d3c78), d1
48416864: a5 00                 cmp     0, d1
48416866: c8 21                 beq     0x48416887
48416868: 00                    clr     d0
48416869: 42 10                 mov     d0, (0x10, sp)
4841686b: fc cd ee 00 06 00     mov     0x000600ee, d1
48416871: 88                    mov     d2, d0
48416872: dd 1b 2b 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416879: 1c                    exthu   d0
4841687a: cd b4 ff 80 04        call    0x4841682e, [d2], 4
4841687f: a0 00                 cmp     0, d0
48416881: c8 06                 beq     0x48416887
48416883: 80 01                 mov     1, d0
48416885: ca 03                 bra     0x48416888
48416887: 00                    clr     d0
48416888: df 80 18              ret     [d2], 0x18

ShiftBox:
4841688b: cf b0                 movm    [d2,a2,a3], (sp)
4841688d: f8 fe f0              add     -0x10, sp
48416890: 92                    mov     a0, a2
48416891: cd c3 ff 80 18        call    0x48416854, [d2], 0x18
48416896: a0 00                 cmp     0, d0
48416898: c8 37                 beq     0x484168cf
4841689a: 9b                    mov     a2, a3
4841689b: 53                    inc4    a3
4841689c: f0 63                 movhu   (a3), d0
4841689e: f0 66                 movhu   (a2), d1
484168a0: f0 6a                 movhu   (a2), d2
484168a2: 18                    exth    d0
484168a3: 19                    exth    d1
484168a4: 1a                    exth    d2
484168a5: f1 04                 sub     d1, d0
484168a7: 40                    inc     d0
484168a8: 85 02                 mov     2, d1
484168aa: dd 2b b1 be 03 00 00  call    0x4c0019d5, 0, 0
484168b1: e8                    add     d2, d0
484168b2: 28 05                 add     5, d0
484168b4: 85 0a                 mov     0xa, d1
484168b6: dd 1f b1 be 03 00 00  call    0x4c0019d5, 0, 0
484168bd: f0 66                 movhu   (a2), d1
484168bf: 8a 20                 mov     0x20, d2
484168c1: 19                    exth    d1
484168c2: f1 02                 sub     d0, d2
484168c4: 88                    mov     d2, d0
484168c5: 18                    exth    d0
484168c6: e1                    add     d0, d1
484168c7: f0 76                 movhu   d1, (a2)
484168c9: f0 67                 movhu   (a3), d1
484168cb: 19                    exth    d1
484168cc: e1                    add     d0, d1
484168cd: f0 77                 movhu   d1, (a3)
484168cf: df b0 1c              ret     [d2,a2,a3], 0x1c

ShiftSize:
484168d2: cf b0                 movm    [d2,a2,a3], (sp)
484168d4: f8 fe f0              add     -0x10, sp
484168d7: 92                    mov     a0, a2
484168d8: cd 7c ff 80 18        call    0x48416854, [d2], 0x18
484168dd: a0 00                 cmp     0, d0
484168df: c8 26                 beq     0x48416905
484168e1: 9b                    mov     a2, a3
484168e2: 53                    inc4    a3
484168e3: f0 63                 movhu   (a3), d0
484168e5: f0 66                 movhu   (a2), d1
484168e7: 18                    exth    d0
484168e8: 19                    exth    d1
484168e9: f1 04                 sub     d1, d0
484168eb: 28 06                 add     6, d0
484168ed: 85 14                 mov     0x14, d1
484168ef: dd e6 b0 be 03 00 00  call    0x4c0019d5, 0, 0
484168f6: f0 66                 movhu   (a2), d1
484168f8: 82                    mov     d0, d2
484168f9: 19                    exth    d1
484168fa: 1a                    exth    d2
484168fb: e9                    add     d2, d1
484168fc: f0 76                 movhu   d1, (a2)
484168fe: f0 63                 movhu   (a3), d0
48416900: 18                    exth    d0
48416901: f1 08                 sub     d2, d0
48416903: f0 73                 movhu   d0, (a3)
48416905: df b0 1c              ret     [d2,a2,a3], 0x1c

IvPR604Proc:
48416908: cf c0                 movm    [d2,d3], (sp)
4841690a: f8 fe ec              add     -0x14, sp
4841690d: 83                    mov     d0, d3
4841690e: 86                    mov     d1, d2
4841690f: fc ca b2 00 06 00     cmp     0x600b2, d2
48416915: c8 14                 beq     0x48416929
48416917: fc ca 01 00 05 00     cmp     0x50001, d2
4841691d: c8 30                 beq     0x4841694d
4841691f: fc ca 02 00 05 00     cmp     0x50002, d2
48416925: c8 3e                 beq     0x48416963
48416927: ca 51                 bra     0x48416978
48416929: 5c 2c                 mov     (0x2c, sp), a0
4841692b: 43 10                 mov     a0, (0x10, sp)
4841692d: dd 3c 2c 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48416934: fc cc 80 e3 59 48     mov     0x4859e380, d0
4841693a: 42 10                 mov     d0, (0x10, sp)
4841693c: fc cd b4 00 06 00     mov     0x000600b4, d1
48416942: 8c                    mov     d3, d0
48416943: dd 4a 2a 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841694a: 00                    clr     d0
4841694b: ca 38                 bra     0x48416983
4841694d: 00                    clr     d0
4841694e: cd be fe 00 00        call    0x4841680c, 0, 0
48416953: 5c 2c                 mov     (0x2c, sp), a0
48416955: 89                    mov     d2, d1
48416956: 43 10                 mov     a0, (0x10, sp)
48416958: 8c                    mov     d3, d0
48416959: dd 10 2c 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48416960: 00                    clr     d0
48416961: ca 22                 bra     0x48416983
48416963: 5c 2c                 mov     (0x2c, sp), a0
48416965: 43 10                 mov     a0, (0x10, sp)
48416967: dd 02 2c 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841696e: 80 01                 mov     1, d0
48416970: cd 9c fe 00 00        call    0x4841680c, 0, 0
48416975: 00                    clr     d0
48416976: ca 0d                 bra     0x48416983
48416978: 5c 2c                 mov     (0x2c, sp), a0
4841697a: 43 10                 mov     a0, (0x10, sp)
4841697c: dd ed 2b 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48416983: df c0 1c              ret     [d2,d3], 0x1c

VwBoxProc:
48416986: cf f0                 movm    [d2,d3,a2,a3], (sp)
48416988: f8 fe e0              add     -0x20, sp
4841698b: 83                    mov     d0, d3
4841698c: fc c9 b2 00 06 00     cmp     0x600b2, d1
48416992: c8 47                 beq     0x484169d9
48416994: fc c9 4b 00 06 00     cmp     0x6004b, d1
4841699a: c9 05                 bne     0x4841699f
4841699c: cc 88 00              jmp     0x48416a24
4841699f: fc c9 4e 00 06 00     cmp     0x6004e, d1
484169a5: c9 05                 bne     0x484169aa
484169a7: cc be 00              jmp     0x48416a65
484169aa: fc c9 4d 00 06 00     cmp     0x6004d, d1
484169b0: c9 05                 bne     0x484169b5
484169b2: cc c1 00              jmp     0x48416a73
484169b5: fc c9 a2 00 06 00     cmp     0x600a2, d1
484169bb: c9 05                 bne     0x484169c0
484169bd: cc ce 00              jmp     0x48416a8b
484169c0: fc c9 a3 00 06 00     cmp     0x600a3, d1
484169c6: c9 05                 bne     0x484169cb
484169c8: cc d0 00              jmp     0x48416a98
484169cb: fc c9 f0 00 06 00     cmp     0x600f0, d1
484169d1: c9 05                 bne     0x484169d6
484169d3: cc d2 00              jmp     0x48416aa5
484169d6: cc fe 00              jmp     0x48416ad4
484169d9: 5c 40                 mov     (0x40, sp), a0
484169db: 3e                    mov     sp, a2
484169dc: 43 10                 mov     a0, (0x10, sp)
484169de: dd 8b 2b 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484169e5: 22 18                 add     0x18, a2
484169e7: 00                    clr     d0
484169e8: 42 10                 mov     d0, (0x10, sp)
484169ea: 8c                    mov     d3, d0
484169eb: fc cd a3 00 06 00     mov     0x000600a3, d1
484169f1: dd 9c 29 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484169f8: f1 e3                 mov     d0, a3
484169fa: 00                    clr     d0
484169fb: 42 10                 mov     d0, (0x10, sp)
484169fd: 8c                    mov     d3, d0
484169fe: fc cd a2 00 06 00     mov     0x000600a2, d1
48416a04: dd 89 29 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416a0b: 82                    mov     d0, d2
48416a0c: 98                    mov     a2, a0
48416a0d: 8c                    mov     d3, d0
48416a0e: cd e4 03 00 14        call    0x48416df2, 0, 0x14
48416a13: 88                    mov     d2, d0
48416a14: 18                    exth    d0
48416a15: f1 dd                 mov     a3, d1
48416a17: 19                    exth    d1
48416a18: 98                    mov     a2, a0
48416a19: dd 8d f7 00 00 e0 20  call    0x484261a6, [d2,d3,a2], 0x20
48416a20: 00                    clr     d0
48416a21: df f0 30              ret     [d2,d3,a2,a3], 0x30
48416a24: 3e                    mov     sp, a2
48416a25: 22 18                 add     0x18, a2
48416a27: 98                    mov     a2, a0
48416a28: cd bd 00 00 14        call    0x48416ae5, 0, 0x14
48416a2d: 00                    clr     d0
48416a2e: 42 10                 mov     d0, (0x10, sp)
48416a30: fc cd a3 00 06 00     mov     0x000600a3, d1
48416a36: 8c                    mov     d3, d0
48416a37: dd 56 29 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416a3e: 5c 40                 mov     (0x40, sp), a0
48416a40: b0 00                 cmp     0, a0
48416a42: c8 12                 beq     0x48416a54
48416a44: 80 1a                 mov     0x1a, d0
48416a46: 42 14                 mov     d0, (0x14, sp)
48416a48: 80 01                 mov     1, d0
48416a4a: 85 02                 mov     2, d1
48416a4c: 98                    mov     a2, a0
48416a4d: cd 6f 22 f0 28        call    0x48418cbc, [d2,d3,a2,a3], 0x28
48416a52: ca 0f                 bra     0x48416a61
48416a54: 18                    exth    d0
48416a55: 42 14                 mov     d0, (0x14, sp)
48416a57: 80 01                 mov     1, d0
48416a59: 85 02                 mov     2, d1
48416a5b: 98                    mov     a2, a0
48416a5c: cd 60 22 f0 28        call    0x48418cbc, [d2,d3,a2,a3], 0x28
48416a61: 00                    clr     d0
48416a62: df f0 30              ret     [d2,d3,a2,a3], 0x30
48416a65: dd b5 6e 01 00 00 00  call    0x4842d91a, 0, 0
48416a6c: f8 60 1c              movhu   (0x1c, a0), d0
48416a6f: 18                    exth    d0
48416a70: df f0 30              ret     [d2,d3,a2,a3], 0x30
48416a73: dd a7 6e 01 00 00 00  call    0x4842d91a, 0, 0
48416a7a: f8 60 1c              movhu   (0x1c, a0), d0
48416a7d: 5d 40                 mov     (0x40, sp), a1
48416a7f: 18                    exth    d0
48416a80: f1 94                 cmp     a1, d0
48416a82: c9 06                 bne     0x48416a88
48416a84: 80 01                 mov     1, d0
48416a86: ca 59                 bra     0x48416adf
48416a88: 00                    clr     d0
48416a89: ca 56                 bra     0x48416adf
48416a8b: dd 8f 6e 01 00 00 00  call    0x4842d91a, 0, 0
48416a92: f8 60 1a              movhu   (0x1a, a0), d0
48416a95: 18                    exth    d0
48416a96: ca 49                 bra     0x48416adf
48416a98: dd 82 6e 01 00 00 00  call    0x4842d91a, 0, 0
48416a9f: f8 60 18              movhu   (0x18, a0), d0
48416aa2: 18                    exth    d0
48416aa3: ca 3c                 bra     0x48416adf
48416aa5: 3e                    mov     sp, a2
48416aa6: 22 18                 add     0x18, a2
48416aa8: 4b 10                 mov     a2, (0x10, sp)
48416aaa: fc cd ef 00 06 00     mov     0x000600ef, d1
48416ab0: dd dd 28 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416ab7: 00                    clr     d0
48416ab8: 42 10                 mov     d0, (0x10, sp)
48416aba: fc cd a2 00 06 00     mov     0x000600a2, d1
48416ac0: 8c                    mov     d3, d0
48416ac1: dd cc 28 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416ac8: 5d 40                 mov     (0x40, sp), a1
48416aca: 18                    exth    d0
48416acb: 98                    mov     a2, a0
48416acc: cd 30 00 f0 2c        call    0x48416afc, [d2,d3,a2,a3], 0x2c
48416ad1: 00                    clr     d0
48416ad2: ca 0d                 bra     0x48416adf
48416ad4: 5c 40                 mov     (0x40, sp), a0
48416ad6: 43 10                 mov     a0, (0x10, sp)
48416ad8: dd 91 2a 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48416adf: df f0 30              ret     [d2,d3,a2,a3], 0x30

GetClientBox:
48416ae2: f8 fe ec              add     -0x14, sp
48416ae5: 43 10                 mov     a0, (0x10, sp)
48416ae7: fc cd f0 00 06 00     mov     0x000600f0, d1
48416aed: dd a0 28 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416af4: df 00 14              ret     0, 0x14

GetClientBox2:
48416af7: cf f0                 movm    [d2,d3,a2,a3], (sp)
48416af9: f8 fe e4              add     -0x1c, sp
48416afc: 8f 02                 mov     2, d3
48416afe: f1 57                 add     a1, d3
48416b00: 97                    mov     a1, a3
48416b01: f1 ed                 mov     d3, a1
48416b03: 9e                    mov     a3, a2
48416b04: 52                    inc4    a2
48416b05: 82                    mov     d0, d2
48416b06: f8 60 02              movhu   (2, a0), d0
48416b09: 4e 14                 mov     d3, (0x14, sp)
48416b0b: f0 71                 movhu   d0, (a1)
48416b0d: f0 60                 movhu   (a0), d0
48416b0f: 1a                    exth    d2
48416b10: f0 73                 movhu   d0, (a3)
48416b12: f8 60 04              movhu   (4, a0), d0
48416b15: 04                    clr     d1
48416b16: f0 72                 movhu   d0, (a2)
48416b18: f8 60 06              movhu   (6, a0), d0
48416b1b: 8f 06                 mov     6, d3
48416b1d: f1 5f                 add     a3, d3
48416b1f: f1 ec                 mov     d3, a0
48416b21: f0 70                 movhu   d0, (a0)
48416b23: a6                    cmp     d1, d2
48416b24: c2 05                 bge     0x48416b29
48416b26: cc 9c 02              jmp     0x48416dc2
48416b29: fa ca cd 00           cmp     0xcd, d2
48416b2d: c3 05                 ble     0x48416b32
48416b2f: cc 93 02              jmp     0x48416dc2
48416b32: 48                    inc     d2
48416b33: fc dd b4 14 5a 48     mov     0x485a14b4, a1
48416b39: 80 3f                 mov     0x3f, d0
48416b3b: f2 08                 and     d2, d0
48416b3d: f8 c0 03              asl     3, d0
48416b40: f1 e0                 mov     d0, a0
48416b42: f1 74                 add     a1, a0
48416b44: 70                    mov     (a0), d0
48416b45: a8                    cmp     d2, d0
48416b46: c8 18                 beq     0x48416b5e
48416b48: db                    setlb
48416b49: a0 00                 cmp     0, d0
48416b4b: c9 05                 bne     0x48416b50
48416b4d: cc 75 02              jmp     0x48416dc2
48416b50: 20 08                 add     8, a0
48416b52: fc d8 b4 16 5a 48     cmp     0x485a16b4, a0
48416b58: c4 03                 bcs     0x48416b5b
48416b5a: 94                    mov     a1, a0
48416b5b: 70                    mov     (a0), d0
48416b5c: a8                    cmp     d2, d0
48416b5d: d9                    lne
48416b5e: f8 20 04              mov     (4, a0), a0
48416b61: f0 f4                 jmp     (a0)
48416b63: 85 04                 mov     4, d1
48416b65: cc 5d 02              jmp     0x48416dc2
48416b68: 85 03                 mov     3, d1
48416b6a: cc 58 02              jmp     0x48416dc2
48416b6d: f0 62                 movhu   (a2), d0
48416b6f: f1 ec                 mov     d3, a0
48416b71: 18                    exth    d0
48416b72: 28 fe                 add     -2, d0
48416b74: f0 72                 movhu   d0, (a2)
48416b76: f0 60                 movhu   (a0), d0
48416b78: 85 01                 mov     1, d1
48416b7a: 18                    exth    d0
48416b7b: 28 fe                 add     -2, d0
48416b7d: f0 70                 movhu   d0, (a0)
48416b7f: cc 43 02              jmp     0x48416dc2
48416b82: 85 02                 mov     2, d1
48416b84: cc 3e 02              jmp     0x48416dc2
48416b87: 3c                    mov     sp, a0
48416b88: 20 18                 add     0x18, a0
48416b8a: 3d                    mov     sp, a1
48416b8b: 21 1a                 add     0x1a, a1
48416b8d: 80 30                 mov     0x30, d0
48416b8f: dd 94 73 01 00 20 04  call    0x4842df23, [a2], 4
48416b96: f0 67                 movhu   (a3), d1
48416b98: f8 bc 18              movhu   (0x18, sp), d0
48416b9b: 19                    exth    d1
48416b9c: 18                    exth    d0
48416b9d: e4                    add     d1, d0
48416b9e: f0 73                 movhu   d0, (a3)
48416ba0: 85 02                 mov     2, d1
48416ba2: cc 20 02              jmp     0x48416dc2
48416ba5: 3c                    mov     sp, a0
48416ba6: 20 18                 add     0x18, a0
48416ba8: 3d                    mov     sp, a1
48416ba9: 21 1a                 add     0x1a, a1
48416bab: 80 2b                 mov     0x2b, d0
48416bad: dd 76 73 01 00 20 04  call    0x4842df23, [a2], 4
48416bb4: f0 66                 movhu   (a2), d1
48416bb6: f8 bc 18              movhu   (0x18, sp), d0
48416bb9: 19                    exth    d1
48416bba: 18                    exth    d0
48416bbb: f1 01                 sub     d0, d1
48416bbd: f0 76                 movhu   d1, (a2)
48416bbf: 85 02                 mov     2, d1
48416bc1: cc 01 02              jmp     0x48416dc2
48416bc4: 3c                    mov     sp, a0
48416bc5: 20 18                 add     0x18, a0
48416bc7: 3d                    mov     sp, a1
48416bc8: 21 1a                 add     0x1a, a1
48416bca: 80 31                 mov     0x31, d0
48416bcc: dd 57 73 01 00 20 04  call    0x4842df23, [a2], 4
48416bd3: f0 67                 movhu   (a3), d1
48416bd5: f8 bc 18              movhu   (0x18, sp), d0
48416bd8: 19                    exth    d1
48416bd9: 18                    exth    d0
48416bda: e4                    add     d1, d0
48416bdb: f0 73                 movhu   d0, (a3)
48416bdd: 85 02                 mov     2, d1
48416bdf: cc e3 01              jmp     0x48416dc2
48416be2: 3c                    mov     sp, a0
48416be3: 20 18                 add     0x18, a0
48416be5: 3d                    mov     sp, a1
48416be6: 21 1a                 add     0x1a, a1
48416be8: 80 2c                 mov     0x2c, d0
48416bea: dd 39 73 01 00 20 04  call    0x4842df23, [a2], 4
48416bf1: f0 62                 movhu   (a2), d0
48416bf3: f8 bd 18              movhu   (0x18, sp), d1
48416bf6: 18                    exth    d0
48416bf7: 19                    exth    d1
48416bf8: f1 04                 sub     d1, d0
48416bfa: f0 72                 movhu   d0, (a2)
48416bfc: 85 02                 mov     2, d1
48416bfe: cc c4 01              jmp     0x48416dc2
48416c01: 3c                    mov     sp, a0
48416c02: 20 18                 add     0x18, a0
48416c04: 3d                    mov     sp, a1
48416c05: 21 1a                 add     0x1a, a1
48416c07: 80 34                 mov     0x34, d0
48416c09: dd 1a 73 01 00 20 04  call    0x4842df23, [a2], 4
48416c10: f0 67                 movhu   (a3), d1
48416c12: f8 bc 18              movhu   (0x18, sp), d0
48416c15: 19                    exth    d1
48416c16: 18                    exth    d0
48416c17: e4                    add     d1, d0
48416c18: f0 73                 movhu   d0, (a3)
48416c1a: 85 02                 mov     2, d1
48416c1c: cc a6 01              jmp     0x48416dc2
48416c1f: 3c                    mov     sp, a0
48416c20: 20 18                 add     0x18, a0
48416c22: 3d                    mov     sp, a1
48416c23: 21 1a                 add     0x1a, a1
48416c25: 80 35                 mov     0x35, d0
48416c27: dd fc 72 01 00 20 04  call    0x4842df23, [a2], 4
48416c2e: f0 67                 movhu   (a3), d1
48416c30: f8 bc 18              movhu   (0x18, sp), d0
48416c33: 19                    exth    d1
48416c34: 18                    exth    d0
48416c35: e4                    add     d1, d0
48416c36: f0 73                 movhu   d0, (a3)
48416c38: 85 02                 mov     2, d1
48416c3a: cc 88 01              jmp     0x48416dc2
48416c3d: 3c                    mov     sp, a0
48416c3e: 20 18                 add     0x18, a0
48416c40: 3d                    mov     sp, a1
48416c41: 21 1a                 add     0x1a, a1
48416c43: 80 38                 mov     0x38, d0
48416c45: dd de 72 01 00 20 04  call    0x4842df23, [a2], 4
48416c4c: f0 66                 movhu   (a2), d1
48416c4e: f8 bc 18              movhu   (0x18, sp), d0
48416c51: 19                    exth    d1
48416c52: 18                    exth    d0
48416c53: f1 01                 sub     d0, d1
48416c55: f0 76                 movhu   d1, (a2)
48416c57: 85 02                 mov     2, d1
48416c59: cc 69 01              jmp     0x48416dc2
48416c5c: 3c                    mov     sp, a0
48416c5d: 20 18                 add     0x18, a0
48416c5f: 3d                    mov     sp, a1
48416c60: 21 1a                 add     0x1a, a1
48416c62: 80 39                 mov     0x39, d0
48416c64: dd bf 72 01 00 20 04  call    0x4842df23, [a2], 4
48416c6b: f0 62                 movhu   (a2), d0
48416c6d: f8 bd 18              movhu   (0x18, sp), d1
48416c70: 18                    exth    d0
48416c71: 19                    exth    d1
48416c72: f1 04                 sub     d1, d0
48416c74: f0 72                 movhu   d0, (a2)
48416c76: 85 02                 mov     2, d1
48416c78: cc 4a 01              jmp     0x48416dc2
48416c7b: f0 62                 movhu   (a2), d0
48416c7d: f1 ec                 mov     d3, a0
48416c7f: 18                    exth    d0
48416c80: 28 ff                 add     -1, d0
48416c82: f0 72                 movhu   d0, (a2)
48416c84: f0 60                 movhu   (a0), d0
48416c86: 85 01                 mov     1, d1
48416c88: 18                    exth    d0
48416c89: 28 ff                 add     -1, d0
48416c8b: f0 70                 movhu   d0, (a0)
48416c8d: cc 35 01              jmp     0x48416dc2
48416c90: 85 01                 mov     1, d1
48416c92: cc 30 01              jmp     0x48416dc2
48416c95: 3c                    mov     sp, a0
48416c96: 20 18                 add     0x18, a0
48416c98: 3d                    mov     sp, a1
48416c99: 21 1a                 add     0x1a, a1
48416c9b: 80 2d                 mov     0x2d, d0
48416c9d: dd 86 72 01 00 20 04  call    0x4842df23, [a2], 4
48416ca4: f0 67                 movhu   (a3), d1
48416ca6: f8 bc 18              movhu   (0x18, sp), d0
48416ca9: 19                    exth    d1
48416caa: 18                    exth    d0
48416cab: e4                    add     d1, d0
48416cac: f0 73                 movhu   d0, (a3)
48416cae: 85 01                 mov     1, d1
48416cb0: cc 12 01              jmp     0x48416dc2
48416cb3: 3c                    mov     sp, a0
48416cb4: 20 18                 add     0x18, a0
48416cb6: 3d                    mov     sp, a1
48416cb7: 21 1a                 add     0x1a, a1
48416cb9: 80 28                 mov     0x28, d0
48416cbb: dd 68 72 01 00 20 04  call    0x4842df23, [a2], 4
48416cc2: f0 62                 movhu   (a2), d0
48416cc4: f8 bd 18              movhu   (0x18, sp), d1
48416cc7: 18                    exth    d0
48416cc8: 19                    exth    d1
48416cc9: f1 04                 sub     d1, d0
48416ccb: f0 72                 movhu   d0, (a2)
48416ccd: 85 01                 mov     1, d1
48416ccf: cc f3 00              jmp     0x48416dc2
48416cd2: 3c                    mov     sp, a0
48416cd3: 20 18                 add     0x18, a0
48416cd5: 3d                    mov     sp, a1
48416cd6: 21 1a                 add     0x1a, a1
48416cd8: 80 2e                 mov     0x2e, d0
48416cda: dd 49 72 01 00 20 04  call    0x4842df23, [a2], 4
48416ce1: f0 67                 movhu   (a3), d1
48416ce3: f8 bc 18              movhu   (0x18, sp), d0
48416ce6: 19                    exth    d1
48416ce7: 18                    exth    d0
48416ce8: e4                    add     d1, d0
48416ce9: f0 73                 movhu   d0, (a3)
48416ceb: 85 01                 mov     1, d1
48416ced: cc d5 00              jmp     0x48416dc2
48416cf0: 3c                    mov     sp, a0
48416cf1: 20 18                 add     0x18, a0
48416cf3: 3d                    mov     sp, a1
48416cf4: 21 1a                 add     0x1a, a1
48416cf6: 80 29                 mov     0x29, d0
48416cf8: dd 2b 72 01 00 20 04  call    0x4842df23, [a2], 4
48416cff: f0 62                 movhu   (a2), d0
48416d01: f8 bd 18              movhu   (0x18, sp), d1
48416d04: 18                    exth    d0
48416d05: 19                    exth    d1
48416d06: f1 04                 sub     d1, d0
48416d08: f0 72                 movhu   d0, (a2)
48416d0a: 85 01                 mov     1, d1
48416d0c: cc b6 00              jmp     0x48416dc2
48416d0f: 3c                    mov     sp, a0
48416d10: 20 18                 add     0x18, a0
48416d12: 3d                    mov     sp, a1
48416d13: 21 1a                 add     0x1a, a1
48416d15: 80 2f                 mov     0x2f, d0
48416d17: dd 0c 72 01 00 20 04  call    0x4842df23, [a2], 4
48416d1e: f0 67                 movhu   (a3), d1
48416d20: f8 bc 18              movhu   (0x18, sp), d0
48416d23: 19                    exth    d1
48416d24: 18                    exth    d0
48416d25: e4                    add     d1, d0
48416d26: f0 73                 movhu   d0, (a3)
48416d28: 85 01                 mov     1, d1
48416d2a: cc 98 00              jmp     0x48416dc2
48416d2d: 3c                    mov     sp, a0
48416d2e: 20 18                 add     0x18, a0
48416d30: 3d                    mov     sp, a1
48416d31: 21 1a                 add     0x1a, a1
48416d33: 80 2a                 mov     0x2a, d0
48416d35: dd ee 71 01 00 20 04  call    0x4842df23, [a2], 4
48416d3c: f0 62                 movhu   (a2), d0
48416d3e: f8 bd 18              movhu   (0x18, sp), d1
48416d41: 18                    exth    d0
48416d42: 19                    exth    d1
48416d43: f1 04                 sub     d1, d0
48416d45: f0 72                 movhu   d0, (a2)
48416d47: 85 01                 mov     1, d1
48416d49: ca 79                 bra     0x48416dc2
48416d4b: 3c                    mov     sp, a0
48416d4c: 20 18                 add     0x18, a0
48416d4e: 3d                    mov     sp, a1
48416d4f: 21 1a                 add     0x1a, a1
48416d51: 80 32                 mov     0x32, d0
48416d53: dd d0 71 01 00 20 04  call    0x4842df23, [a2], 4
48416d5a: f0 67                 movhu   (a3), d1
48416d5c: f8 bc 18              movhu   (0x18, sp), d0
48416d5f: 19                    exth    d1
48416d60: 18                    exth    d0
48416d61: e4                    add     d1, d0
48416d62: f0 73                 movhu   d0, (a3)
48416d64: 85 01                 mov     1, d1
48416d66: ca 5c                 bra     0x48416dc2
48416d68: 3c                    mov     sp, a0
48416d69: 20 18                 add     0x18, a0
48416d6b: 3d                    mov     sp, a1
48416d6c: 21 1a                 add     0x1a, a1
48416d6e: 80 33                 mov     0x33, d0
48416d70: dd b3 71 01 00 20 04  call    0x4842df23, [a2], 4
48416d77: f0 67                 movhu   (a3), d1
48416d79: f8 bc 18              movhu   (0x18, sp), d0
48416d7c: 19                    exth    d1
48416d7d: 18                    exth    d0
48416d7e: e4                    add     d1, d0
48416d7f: f0 73                 movhu   d0, (a3)
48416d81: 85 01                 mov     1, d1
48416d83: ca 3f                 bra     0x48416dc2
48416d85: 3c                    mov     sp, a0
48416d86: 20 18                 add     0x18, a0
48416d88: 3d                    mov     sp, a1
48416d89: 21 1a                 add     0x1a, a1
48416d8b: 80 36                 mov     0x36, d0
48416d8d: dd 96 71 01 00 20 04  call    0x4842df23, [a2], 4
48416d94: f0 66                 movhu   (a2), d1
48416d96: f8 bc 18              movhu   (0x18, sp), d0
48416d99: 19                    exth    d1
48416d9a: 18                    exth    d0
48416d9b: f1 01                 sub     d0, d1
48416d9d: f0 76                 movhu   d1, (a2)
48416d9f: 85 01                 mov     1, d1
48416da1: ca 21                 bra     0x48416dc2
48416da3: 3c                    mov     sp, a0
48416da4: 20 18                 add     0x18, a0
48416da6: 3d                    mov     sp, a1
48416da7: 21 1a                 add     0x1a, a1
48416da9: 80 37                 mov     0x37, d0
48416dab: dd 78 71 01 00 20 04  call    0x4842df23, [a2], 4
48416db2: f0 66                 movhu   (a2), d1
48416db4: f8 bc 18              movhu   (0x18, sp), d0
48416db7: 19                    exth    d1
48416db8: 18                    exth    d0
48416db9: f1 01                 sub     d0, d1
48416dbb: f0 76                 movhu   d1, (a2)
48416dbd: 85 01                 mov     1, d1
48416dbf: ca 03                 bra     0x48416dc2
48416dc1: 04                    clr     d1
48416dc2: a5 00                 cmp     0, d1
48416dc4: c8 28                 beq     0x48416dec
48416dc6: 08                    clr     d2
48416dc7: a9                    cmp     d2, d1
48416dc8: c3 24                 ble     0x48416dec
48416dca: db                    setlb
48416dcb: 5c 14                 mov     (0x14, sp), a0
48416dcd: 48                    inc     d2
48416dce: f0 60                 movhu   (a0), d0
48416dd0: 18                    exth    d0
48416dd1: 40                    inc     d0
48416dd2: f0 70                 movhu   d0, (a0)
48416dd4: f1 ec                 mov     d3, a0
48416dd6: f0 60                 movhu   (a0), d0
48416dd8: 18                    exth    d0
48416dd9: 28 ff                 add     -1, d0
48416ddb: f0 70                 movhu   d0, (a0)
48416ddd: f0 63                 movhu   (a3), d0
48416ddf: 18                    exth    d0
48416de0: 40                    inc     d0
48416de1: f0 73                 movhu   d0, (a3)
48416de3: f0 62                 movhu   (a2), d0
48416de5: 18                    exth    d0
48416de6: 28 ff                 add     -1, d0
48416de8: f0 72                 movhu   d0, (a2)
48416dea: a6                    cmp     d1, d2
48416deb: d0                    llt
48416dec: df f0 2c              ret     [d2,d3,a2,a3], 0x2c

GetBox:
48416def: f8 fe ec              add     -0x14, sp
48416df2: 43 10                 mov     a0, (0x10, sp)
48416df4: fc cd ef 00 06 00     mov     0x000600ef, d1
48416dfa: dd 93 25 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416e01: df 00 14              ret     0, 0x14

SetBox:
48416e04: cf a0                 movm    [d2,a2], (sp)
48416e06: f8 fe f0              add     -0x10, sp
48416e09: 92                    mov     a0, a2
48416e0a: 82                    mov     d0, d2
48416e0b: dd 0f 6b 01 00 00 00  call    0x4842d91a, 0, 0
48416e12: 20 0e                 add     0xe, a0
48416e14: 85 fc                 mov     -4, d1
48416e16: db                    setlb
48416e17: f0 62                 movhu   (a2), d0
48416e19: 22 02                 add     2, a2
48416e1b: f0 70                 movhu   d0, (a0)
48416e1d: 20 02                 add     2, a0
48416e1f: 44                    inc     d1
48416e20: d9                    lne
48416e21: 85 01                 mov     1, d1
48416e23: 88                    mov     d2, d0
48416e24: dd 42 65 01 00 80 10  call    0x4842d366, [d2], 0x10
48416e2b: df a0 18              ret     [d2,a2], 0x18

GetBoxCenter:
48416e2e: cf f0                 movm    [d2,d3,a2,a3], (sp)
48416e30: f8 fe f0              add     -0x10, sp
48416e33: 92                    mov     a0, a2
48416e34: f8 62 04              movhu   (4, a2), d0
48416e37: f0 66                 movhu   (a2), d1
48416e39: f0 6a                 movhu   (a2), d2
48416e3b: 97                    mov     a1, a3
48416e3c: 18                    exth    d0
48416e3d: 19                    exth    d1
48416e3e: 1a                    exth    d2
48416e3f: f1 04                 sub     d1, d0
48416e41: 40                    inc     d0
48416e42: 85 02                 mov     2, d1
48416e44: dd 91 ab be 03 00 00  call    0x4c0019d5, 0, 0
48416e4b: e8                    add     d2, d0
48416e4c: f0 73                 movhu   d0, (a3)
48416e4e: f8 62 06              movhu   (6, a2), d0
48416e51: 22 02                 add     2, a2
48416e53: f0 66                 movhu   (a2), d1
48416e55: f0 6a                 movhu   (a2), d2
48416e57: 18                    exth    d0
48416e58: 19                    exth    d1
48416e59: 1a                    exth    d2
48416e5a: f1 04                 sub     d1, d0
48416e5c: 40                    inc     d0
48416e5d: 85 02                 mov     2, d1
48416e5f: dd 76 ab be 03 00 00  call    0x4c0019d5, 0, 0
48416e66: e8                    add     d2, d0
48416e67: f8 73 02              movhu   d0, (2, a3)
48416e6a: df f0 20              ret     [d2,d3,a2,a3], 0x20

GetFrameColor:
48416e6d: f8 fe f8              add     -8, sp
48416e70: dd dc ae 00 00 00 00  call    0x48421d4c, 0, 0
48416e77: 81                    mov     d0, d1
48416e78: 1d                    exthu   d1
48416e79: 2c ff 00              mov     0xff, d0
48416e7c: a5 01                 cmp     1, d1
48416e7e: c8 09                 beq     0x48416e87
48416e80: 80 07                 mov     7, d0
48416e82: a5 02                 cmp     2, d1
48416e84: c8 03                 beq     0x48416e87
48416e86: 00                    clr     d0
48416e87: df 00 08              ret     0, 8

BoxLeftCheck:
48416e8a: 18                 exth    d0
48416e8b: 2d 80 00           mov     0x80, d1
48416e8e: a4                 cmp     d1, d0
48416e8f: c0 19              blt     0x48416ea8
48416e91: fa c8 88 00        cmp     0x88, d0
48416e95: c1 13              bgt     0x48416ea8
48416e97: f1 04              sub     d1, d0
48416e99: 54                 asl2    d0
48416e9a: fc dc b4 16 5a 48  mov     0x485a16b4, a0
48416ea0: f3 80              mov     (d0, a0), a0
48416ea2: f0 f4              jmp     (a0)
48416ea4: 80 01              mov     1, d0
48416ea6: ca 03              bra     0x48416ea9
48416ea8: 00                 clr     d0
48416ea9: de 00 00           retf    0, 0

BoxRightCheck:
48416eac: 18                 exth    d0
48416ead: 2d a0 00           mov     0xa0, d1
48416eb0: a4                 cmp     d1, d0
48416eb1: c0 19              blt     0x48416eca
48416eb3: fa c8 a8 00        cmp     0xa8, d0
48416eb7: c1 13              bgt     0x48416eca
48416eb9: f1 04              sub     d1, d0
48416ebb: 54                 asl2    d0
48416ebc: fc dc d8 16 5a 48  mov     0x485a16d8, a0
48416ec2: f3 80              mov     (d0, a0), a0
48416ec4: f0 f4              jmp     (a0)
48416ec6: 80 01              mov     1, d0
48416ec8: ca 03              bra     0x48416ecb
48416eca: 00                 clr     d0
48416ecb: de 00 00           retf    0, 0

GroupBoxProc:
48416ece: cf f0                 movm    [d2,d3,a2,a3], (sp)
48416ed0: f8 fe d8              add     -0x28, sp
48416ed3: f1 e3                 mov     d0, a3
48416ed5: 87                    mov     d1, d3
48416ed6: fc cb 01 00 05 00     cmp     0x50001, d3
48416edc: c2 05                 bge     0x48416ee1
48416ede: cc 11 07              jmp     0x484175ef
48416ee1: fc cb a8 00 06 00     cmp     0x600a8, d3
48416ee7: c3 05                 ble     0x48416eec
48416ee9: cc 06 07              jmp     0x484175ef
48416eec: fc dd fc 16 5a 48     mov     0x485a16fc, a1
48416ef2: 80 3f                 mov     0x3f, d0
48416ef4: fc cd 00 00 fb ff     mov     0xfffb0000, d1
48416efa: ed                    add     d3, d1
48416efb: f2 04                 and     d1, d0
48416efd: f8 c0 03              asl     3, d0
48416f00: f1 e0                 mov     d0, a0
48416f02: f1 74                 add     a1, a0
48416f04: 70                    mov     (a0), d0
48416f05: a4                    cmp     d1, d0
48416f06: c8 18                 beq     0x48416f1e
48416f08: db                    setlb
48416f09: a0 00                 cmp     0, d0
48416f0b: c9 05                 bne     0x48416f10
48416f0d: cc e2 06              jmp     0x484175ef
48416f10: 20 08                 add     8, a0
48416f12: fc d8 fc 18 5a 48     cmp     0x485a18fc, a0
48416f18: c4 03                 bcs     0x48416f1b
48416f1a: 94                    mov     a1, a0
48416f1b: 70                    mov     (a0), d0
48416f1c: a4                    cmp     d1, d0
48416f1d: d9                    lne
48416f1e: f8 20 04              mov     (4, a0), a0
48416f21: f0 f4                 jmp     (a0)
48416f23: 58 48                 mov     (0x48, sp), d0
48416f25: 04                    clr     d1
48416f26: dd 22 44 01 00 e0 20  call    0x4842b348, [d2,d3,a2], 0x20
48416f2d: 00                    clr     d0
48416f2e: df f0 38              ret     [d2,d3,a2,a3], 0x38
48416f31: 58 48                 mov     (0x48, sp), d0
48416f33: 04                    clr     d1
48416f34: dd c0 44 01 00 e0 20  call    0x4842b3f4, [d2,d3,a2], 0x20
48416f3b: 00                    clr     d0
48416f3c: df f0 38              ret     [d2,d3,a2,a3], 0x38
48416f3f: 58 48                 mov     (0x48, sp), d0
48416f41: 04                    clr     d1
48416f42: dd 5e 45 01 00 e0 20  call    0x4842b4a0, [d2,d3,a2], 0x20
48416f49: 00                    clr     d0
48416f4a: df f0 38              ret     [d2,d3,a2,a3], 0x38
48416f4d: dd 38 5a 01 00 00 10  call    0x4842c985, 0, 0x10
48416f54: 5c 48                 mov     (0x48, sp), a0
48416f56: 8d                    mov     d3, d1
48416f57: 43 10                 mov     a0, (0x10, sp)
48416f59: dd 34 24 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416f60: 00                    clr     d0
48416f61: df f0 38              ret     [d2,d3,a2,a3], 0x38
48416f64: dd 21 5a 01 00 00 10  call    0x4842c985, 0, 0x10
48416f6b: 5c 48                 mov     (0x48, sp), a0
48416f6d: 8d                    mov     d3, d1
48416f6e: 43 10                 mov     a0, (0x10, sp)
48416f70: dd 1d 24 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416f77: 00                    clr     d0
48416f78: df f0 38              ret     [d2,d3,a2,a3], 0x38
48416f7b: f1 dc                 mov     a3, d0
48416f7d: dd e8 24 01 00 40 14  call    0x48429465, [d3], 0x14
48416f84: 5e 48                 mov     (0x48, sp), a2
48416f86: f1 dc                 mov     a3, d0
48416f88: 4b 10                 mov     a2, (0x10, sp)
48416f8a: 8d                    mov     d3, d1
48416f8b: dd de 25 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48416f92: dd ac 24 01 00 00 10  call    0x4842943e, 0, 0x10
48416f99: f1 9c                 cmp     a3, d0
48416f9b: c9 37                 bne     0x48416fd2
48416f9d: dd 4e 5a 01 00 00 10  call    0x4842c9eb, 0, 0x10
48416fa4: a0 00                 cmp     0, d0
48416fa6: c9 2c                 bne     0x48416fd2
48416fa8: ba 05                 cmp     5, a2
48416faa: c8 16                 beq     0x48416fc0
48416fac: 00                    clr     d0
48416fad: 42 10                 mov     d0, (0x10, sp)
48416faf: f1 dc                 mov     a3, d0
48416fb1: fc cd 08 00 05 00     mov     0x00050008, d1
48416fb7: dd d6 23 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416fbe: ca 14                 bra     0x48416fd2
48416fc0: 00                    clr     d0
48416fc1: 42 10                 mov     d0, (0x10, sp)
48416fc3: f1 dc                 mov     a3, d0
48416fc5: fc cd 09 00 05 00     mov     0x00050009, d1
48416fcb: dd c2 23 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48416fd2: 00                    clr     d0
48416fd3: df f0 38              ret     [d2,d3,a2,a3], 0x38
48416fd6: 80 ff                 mov     -1, d0
48416fd8: fc 81 08 07 00 50     mov     d0, (0x50000708)
48416fde: 04                    clr     d1
48416fdf: fc ce 7c 3c 0d 50     mov     0x500d3c7c, d2
48416fe5: db                    setlb
48416fe6: 84                    mov     d1, d0
48416fe7: f8 c0 05              asl     5, d0
48416fea: e8                    add     d2, d0
48416feb: 4e 1c                 mov     d3, (0x1c, sp)
48416fed: 0c                    clr     d3
48416fee: f1 e0                 mov     d0, a0
48416ff0: f8 5c 01              movbu   d3, (1, a0)
48416ff3: 84                    mov     d1, d0
48416ff4: f8 c0 05              asl     5, d0
48416ff7: e8                    add     d2, d0
48416ff8: f1 e0                 mov     d0, a0
48416ffa: f8 5c 11              movbu   d3, (0x11, a0)
48416ffd: 5b 1c                 mov     (0x1c, sp), d3
48416fff: 44                    inc     d1
48417000: 19                    exth    d1
48417001: a5 1f                 cmp     0x1f, d1
48417003: d3                    lle
48417004: 5c 48                 mov     (0x48, sp), a0
48417006: f1 dc                 mov     a3, d0
48417008: 43 10                 mov     a0, (0x10, sp)
4841700a: 8d                    mov     d3, d1
4841700b: dd 5e 25 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48417012: 00                    clr     d0
48417013: df f0 38              ret     [d2,d3,a2,a3], 0x38
48417016: 00                    clr     d0
48417017: 42 10                 mov     d0, (0x10, sp)
48417019: f1 dc                 mov     a3, d0
4841701b: fc cd 09 00 05 00     mov     0x00050009, d1
48417021: dd 6c 23 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417028: 00                    clr     d0
48417029: df f0 38              ret     [d2,d3,a2,a3], 0x38
4841702c: fc a4 ec 06 00 50     mov     (0x500006ec), d0
48417032: a0 00                 cmp     0, d0
48417034: c8 57                 beq     0x4841708b
48417036: 5c 48                 mov     (0x48, sp), a0
48417038: b0 00                 cmp     0, a0
4841703a: c2 1f                 bge     0x48417059
4841703c: fc a4 04 07 00 50     mov     (0x50000704), d0
48417042: 42 10                 mov     d0, (0x10, sp)
48417044: fc a4 f4 06 00 50     mov     (0x500006f4), d0
4841704a: fc a5 fc 06 00 50     mov     (0x500006fc), d1
48417050: dd 3d 23 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417057: ca 1d                 bra     0x48417074
48417059: fc a4 00 07 00 50     mov     (0x50000700), d0
4841705f: 42 10                 mov     d0, (0x10, sp)
48417061: fc a4 f0 06 00 50     mov     (0x500006f0), d0
48417067: fc a5 f8 06 00 50     mov     (0x500006f8), d1
4841706d: dd 20 23 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417074: dd 11 59 01 00 00 10  call    0x4842c985, 0, 0x10
4841707b: 04                    clr     d1
4841707c: 46 10                 mov     d1, (0x10, sp)
4841707e: fc cd 6e 00 06 00     mov     0x0006006e, d1
48417084: dd 09 23 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841708b: 00                    clr     d0
4841708c: df f0 38              ret     [d2,d3,a2,a3], 0x38
4841708f: 5e 48                 mov     (0x48, sp), a2
48417091: f1 dc                 mov     a3, d0
48417093: 4b 10                 mov     a2, (0x10, sp)
48417095: 8d                    mov     d3, d1
48417096: dd d3 24 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841709d: fc cc 3f 00 04 00     mov     0x0004003f, d0
484170a3: 42 10                 mov     d0, (0x10, sp)
484170a5: fc cd 24 00 06 00     mov     0x00060024, d1
484170ab: f1 dc                 mov     a3, d0
484170ad: dd e0 22 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484170b4: a0 00                 cmp     0, d0
484170b6: c8 13                 beq     0x484170c9
484170b8: 4b 10                 mov     a2, (0x10, sp)
484170ba: f1 dc                 mov     a3, d0
484170bc: fc cd 2a 00 05 00     mov     0x0005002a, d1
484170c2: dd cb 22 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484170c9: ba ff                 cmp     0xff, a2
484170cb: c5 55                 bhi     0x48417120
484170cd: f1 d8                 mov     a2, d0
484170cf: f8 e0 1f              and     0x1f, d0
484170d2: 83                    mov     d0, d3
484170d3: 1b                    exth    d3
484170d4: f1 d8                 mov     a2, d0
484170d6: f8 c4 07              lsr     7, d0
484170d9: f8 e0 01              and     0x01, d0
484170dc: 82                    mov     d0, d2
484170dd: 1a                    exth    d2
484170de: 8c                    mov     d3, d0
484170df: f8 c0 05              asl     5, d0
484170e2: 4a 20                 mov     d2, (0x20, sp)
484170e4: fc cd 7c 3c 0d 50     mov     0x500d3c7c, d1
484170ea: e4                    add     d1, d0
484170eb: f1 e0                 mov     d0, a0
484170ed: 88                    mov     d2, d0
484170ee: f8 c0 04              asl     4, d0
484170f1: 8a 01                 mov     1, d2
484170f3: f4                    movbu   d2, (d0, a0)
484170f4: 60                    mov     d0, (a0)
484170f5: 5a 20                 mov     (0x20, sp), d2
484170f7: f8 c3 05              asl     5, d3
484170fa: ed                    add     d3, d1
484170fb: f8 c2 04              asl     4, d2
484170fe: f1 e8                 mov     d2, a0
48417100: f1 64                 add     d1, a0
48417102: f8 40 01              movbu   (1, a0), d0
48417105: a0 01                 cmp     1, d0
48417107: c9 19                 bne     0x48417120
48417109: 4f 10                 mov     a3, (0x10, sp)
4841710b: fc cc 1e 00 05 00     mov     0x0005001e, d0
48417111: 42 14                 mov     d0, (0x14, sp)
48417113: 4b 18                 mov     a2, (0x18, sp)
48417115: 80 10                 mov     0x10, d0
48417117: f1 dd                 mov     a3, d1
48417119: dd 81 2b 01 00 f0 34  call    0x48429c9a, [d2,d3,a2,a3], 0x34
48417120: 00                    clr     d0
48417121: df f0 38              ret     [d2,d3,a2,a3], 0x38
48417124: 5e 48                 mov     (0x48, sp), a2
48417126: f1 dc                 mov     a3, d0
48417128: 4b 10                 mov     a2, (0x10, sp)
4841712a: 8d                    mov     d3, d1
4841712b: dd 3e 24 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48417132: fc cc 3f 00 04 00     mov     0x0004003f, d0
48417138: 42 10                 mov     d0, (0x10, sp)
4841713a: fc cd 24 00 06 00     mov     0x00060024, d1
48417140: f1 dc                 mov     a3, d0
48417142: dd 4b 22 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417149: a0 00                 cmp     0, d0
4841714b: c8 13                 beq     0x4841715e
4841714d: 4b 10                 mov     a2, (0x10, sp)
4841714f: f1 dc                 mov     a3, d0
48417151: fc cd 2b 00 05 00     mov     0x0005002b, d1
48417157: dd 36 22 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841715e: ba ff                 cmp     0xff, a2
48417160: c5 6a                 bhi     0x484171ca
48417162: f1 d8                 mov     a2, d0
48417164: f8 e0 1f              and     0x1f, d0
48417167: 18                    exth    d0
48417168: f1 e1                 mov     d0, a1
4841716a: f1 d8                 mov     a2, d0
4841716c: f8 c4 07              lsr     7, d0
4841716f: f8 e0 01              and     0x01, d0
48417172: 83                    mov     d0, d3
48417173: 1b                    exth    d3
48417174: f1 d5                 mov     a1, d1
48417176: f8 c1 05              asl     5, d1
48417179: 8c                    mov     d3, d0
4841717a: f8 c0 04              asl     4, d0
4841717d: 4e 24                 mov     d3, (0x24, sp)
4841717f: fc ce 7c 3c 0d 50     mov     0x500d3c7c, d2
48417185: e9                    add     d2, d1
48417186: f1 e4                 mov     d1, a0
48417188: 0c                    clr     d3
48417189: f4                    movbu   d3, (d0, a0)
4841718a: 70                    mov     (a0), d0
4841718b: 5b 24                 mov     (0x24, sp), d3
4841718d: f1 d4                 mov     a1, d0
4841718f: f8 c0 05              asl     5, d0
48417192: e8                    add     d2, d0
48417193: 8d                    mov     d3, d1
48417194: f8 c1 04              asl     4, d1
48417197: f1 e4                 mov     d1, a0
48417199: f1 60                 add     d0, a0
4841719b: f8 40 01              movbu   (1, a0), d0
4841719e: a0 00                 cmp     0, d0
484171a0: c8 2a                 beq     0x484171ca
484171a2: f1 d4                 mov     a1, d0
484171a4: f8 c0 05              asl     5, d0
484171a7: e2                    add     d0, d2
484171a8: f8 c3 04              asl     4, d3
484171ab: f1 ec                 mov     d3, a0
484171ad: f1 68                 add     d2, a0
484171af: 00                    clr     d0
484171b0: f8 50 01              movbu   d0, (1, a0)
484171b3: 4f 10                 mov     a3, (0x10, sp)
484171b5: fc cc 1e 00 05 00     mov     0x0005001e, d0
484171bb: 42 14                 mov     d0, (0x14, sp)
484171bd: 4b 18                 mov     a2, (0x18, sp)
484171bf: 80 10                 mov     0x10, d0
484171c1: f1 dd                 mov     a3, d1
484171c3: dd 12 2e 01 00 f0 30  call    0x48429fd5, [d2,d3,a2,a3], 0x30
484171ca: 00                    clr     d0
484171cb: df f0 38              ret     [d2,d3,a2,a3], 0x38
484171ce: 5e 48                 mov     (0x48, sp), a2
484171d0: f1 dc                 mov     a3, d0
484171d2: 4b 10                 mov     a2, (0x10, sp)
484171d4: 8d                    mov     d3, d1
484171d5: dd 94 23 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484171dc: fc cc 3f 00 04 00     mov     0x0004003f, d0
484171e2: 42 10                 mov     d0, (0x10, sp)
484171e4: fc cd 24 00 06 00     mov     0x00060024, d1
484171ea: f1 dc                 mov     a3, d0
484171ec: dd a1 21 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484171f3: a0 00                 cmp     0, d0
484171f5: c8 13                 beq     0x48417208
484171f7: 4b 10                 mov     a2, (0x10, sp)
484171f9: f1 dc                 mov     a3, d0
484171fb: fc cd 23 00 05 00     mov     0x00050023, d1
48417201: dd 8c 21 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417208: ba ff                 cmp     0xff, a2
4841720a: c7 05                 bls     0x4841720f
4841720c: cc e4 00              jmp     0x484172f0
4841720f: ba 17                 cmp     0x17, a2
48417211: c8 10                 beq     0x48417221
48417213: ba 15                 cmp     0x15, a2
48417215: c8 44                 beq     0x48417259
48417217: ba 95                 cmp     0x95, a2
48417219: c9 05                 bne     0x4841721e
4841721b: cc 7e 00              jmp     0x48417299
4841721e: cc bb 00              jmp     0x484172d9
48417221: dd 64 57 01 00 00 10  call    0x4842c985, 0, 0x10
48417228: 04                    clr     d1
48417229: 46 10                 mov     d1, (0x10, sp)
4841722b: fc cd 70 00 06 00     mov     0x00060070, d1
48417231: dd 5c 21 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417238: a0 00                 cmp     0, d0
4841723a: c8 05                 beq     0x4841723f
4841723c: cc b4 00              jmp     0x484172f0
4841723f: dd 46 57 01 00 00 10  call    0x4842c985, 0, 0x10
48417246: 04                    clr     d1
48417247: 46 10                 mov     d1, (0x10, sp)
48417249: fc cd 8b 00 06 00     mov     0x0006008b, d1
4841724f: dd 3e 21 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417256: cc 9a 00              jmp     0x484172f0
48417259: fc a4 ec 06 00 50     mov     (0x500006ec), d0
4841725f: a0 00                 cmp     0, d0
48417261: c8 34                 beq     0x48417295
48417263: fc a4 00 07 00 50     mov     (0x50000700), d0
48417269: 42 10                 mov     d0, (0x10, sp)
4841726b: fc a4 f0 06 00 50     mov     (0x500006f0), d0
48417271: fc a5 f8 06 00 50     mov     (0x500006f8), d1
48417277: dd 16 21 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841727e: dd 07 57 01 00 00 10  call    0x4842c985, 0, 0x10
48417285: 04                    clr     d1
48417286: 46 10                 mov     d1, (0x10, sp)
48417288: fc cd 6e 00 06 00     mov     0x0006006e, d1
4841728e: dd ff 20 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417295: 00                    clr     d0
48417296: df f0 38              ret     [d2,d3,a2,a3], 0x38
48417299: fc a4 ec 06 00 50     mov     (0x500006ec), d0
4841729f: a0 00                 cmp     0, d0
484172a1: c8 34                 beq     0x484172d5
484172a3: fc a4 04 07 00 50     mov     (0x50000704), d0
484172a9: 42 10                 mov     d0, (0x10, sp)
484172ab: fc a4 f4 06 00 50     mov     (0x500006f4), d0
484172b1: fc a5 fc 06 00 50     mov     (0x500006fc), d1
484172b7: dd d6 20 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484172be: dd c7 56 01 00 00 10  call    0x4842c985, 0, 0x10
484172c5: 04                    clr     d1
484172c6: 46 10                 mov     d1, (0x10, sp)
484172c8: fc cd 6e 00 06 00     mov     0x0006006e, d1

CheckProgDial:
48417600: fc a4 10 07 00 50  mov     (0x50000710), d0
48417606: de 00 00           retf    0, 0

SetProgDial:
48417609: fc 81 10 07 00 50  mov     d0, (0x50000710)
4841760f: de 00 00           retf    0, 0

SetDialEnable:
48417612: cf 80                 movm    [d2], (sp)
48417614: f8 fe ec              add     -0x14, sp
48417617: 82                    mov     d0, d2
48417618: fc a4 ec 06 00 50     mov     (0x500006ec), d0
4841761e: a8                    cmp     d2, d0
4841761f: c8 56                 beq     0x48417675
48417621: fc 89 ec 06 00 50     mov     d2, (0x500006ec)
48417627: aa 00                 cmp     0, d2
48417629: c9 25                 bne     0x4841764e
4841762b: fc a4 0c 07 00 50     mov     (0x5000070c), d0
48417631: a0 ff                 cmp     -1, d0
48417633: c8 42                 beq     0x48417675
48417635: 80 ff                 mov     -1, d0
48417637: fc 81 0c 07 00 50     mov     d0, (0x5000070c)
4841763d: 42 10                 mov     d0, (0x10, sp)
4841763f: fc cd 24 00 05 00     mov     0x00050024, d1
48417645: dd 48 1d 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841764c: ca 29                 bra     0x48417675
4841764e: fc a0 08 07 00 50     mov     (0x50000708), a0
48417654: fc a4 0c 07 00 50     mov     (0x5000070c), d0
4841765a: f1 90                 cmp     a0, d0
4841765c: c8 19                 beq     0x48417675
4841765e: fc 80 0c 07 00 50     mov     a0, (0x5000070c)
48417664: 43 10                 mov     a0, (0x10, sp)
48417666: 80 ff                 mov     -1, d0
48417668: fc cd 24 00 05 00     mov     0x00050024, d1
4841766e: dd 1f 1d 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417675: 4a 10                 mov     d2, (0x10, sp)
48417677: fc cc 01 00 03 00     mov     0x00030001, d0
4841767d: fc cd d7 00 06 00     mov     0x000600d7, d1
48417683: dd c2 36 01 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841768a: df 80 18              ret     [d2], 0x18

SetDialFocus:
4841768d: f8 fe ec              add     -0x14, sp
48417690: fc a5 08 07 00 50     mov     (0x50000708), d1
48417696: a1                    cmp     d0, d1
48417697: c8 32                 beq     0x484176c9
48417699: fc a5 ec 06 00 50     mov     (0x500006ec), d1
4841769f: fc 81 08 07 00 50     mov     d0, (0x50000708)
484176a5: a5 00                 cmp     0, d1
484176a7: c8 22                 beq     0x484176c9
484176a9: fc a5 0c 07 00 50     mov     (0x5000070c), d1
484176af: a1                    cmp     d0, d1
484176b0: c8 19                 beq     0x484176c9
484176b2: fc 81 0c 07 00 50     mov     d0, (0x5000070c)
484176b8: 42 10                 mov     d0, (0x10, sp)
484176ba: 80 ff                 mov     -1, d0
484176bc: fc cd 24 00 05 00     mov     0x00050024, d1
484176c2: dd cb 1c 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484176c9: df 00 14              ret     0, 0x14

GetDialFocus:
484176cc: fc a4 0c 07 00 50  mov     (0x5000070c), d0
484176d2: de 00 00           retf    0, 0

SetDialUp:
484176d5: f8 fe f4           add     -0xc, sp
484176d8: fc 81 f0 06 00 50  mov     d0, (0x500006f0)
484176de: fc 85 f8 06 00 50  mov     d1, (0x500006f8)
484176e4: 59 1c              mov     (0x1c, sp), d1
484176e6: fc 85 00 07 00 50  mov     d1, (0x50000700)
484176ec: cd a4 ff 00 14     call    0x48417690, 0, 0x14
484176f1: df 00 0c           ret     0, 0xc

SetDialDown:
484176f4: f8 fe f4           add     -0xc, sp
484176f7: fc 81 f4 06 00 50  mov     d0, (0x500006f4)
484176fd: fc 85 fc 06 00 50  mov     d1, (0x500006fc)
48417703: 59 1c              mov     (0x1c, sp), d1
48417705: fc 85 04 07 00 50  mov     d1, (0x50000704)
4841770b: cd 85 ff 00 14     call    0x48417690, 0, 0x14
48417710: df 00 0c           ret     0, 0xc

SetAutoIncDefault:
48417713: cf c0                 movm    [d2,d3], (sp)
48417715: f8 fe ec              add     -0x14, sp
48417718: dd f7 1e 01 00 00 10  call    0x4842960f, 0, 0x10
4841771f: 83                    mov     d0, d3
48417720: dd 14 1f 01 00 00 10  call    0x48429634, 0, 0x10
48417727: 82                    mov     d0, d2
48417728: dd 31 1f 01 00 00 10  call    0x48429659, 0, 0x10
4841772f: 42 10                 mov     d0, (0x10, sp)
48417731: 89                    mov     d2, d1
48417732: 8c                    mov     d3, d0
48417733: cd 0d 00 f0 2c        call    0x48417740, [d2,d3,a2,a3], 0x2c
48417738: df c0 1c              ret     [d2,d3], 0x1c

SetAutoInc:
4841773b: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841773d: f8 fe e4              add     -0x1c, sp
48417740: 46 38                 mov     d1, (0x38, sp)
48417742: 42 34                 mov     d0, (0x34, sp)
48417744: dd f0 1e 01 00 00 10  call    0x48429634, 0, 0x10
4841774b: fc c8 06 00 05 00     cmp     0x50006, d0
48417751: c8 1d                 beq     0x4841776e
48417753: fc c8 05 00 05 00     cmp     0x50005, d0
48417759: c8 15                 beq     0x4841776e
4841775b: fc c8 07 00 05 00     cmp     0x50007, d0
48417761: c8 0d                 beq     0x4841776e
48417763: fc c8 1e 00 05 00     cmp     0x5001e, d0
48417769: c8 05                 beq     0x4841776e
4841776b: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
4841776e: dd eb 1e 01 00 00 10  call    0x48429659, 0, 0x10
48417775: f1 e3                 mov     d0, a3
48417777: bf ff                 cmp     0xff, a3
48417779: c7 05                 bls     0x4841777e
4841777b: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
4841777e: 83                    mov     d0, d3
4841777f: f8 e3 1f              and     0x1f, d3
48417782: 1f                    exthu   d3
48417783: f8 c4 07              lsr     7, d0
48417786: f8 e0 01              and     0x01, d0
48417789: 1c                    exthu   d0
4841778a: f1 e2                 mov     d0, a2
4841778c: 8c                    mov     d3, d0
4841778d: f8 c0 05              asl     5, d0
48417790: f1 d9                 mov     a2, d1
48417792: f8 c1 04              asl     4, d1
48417795: f1 e4                 mov     d1, a0
48417797: fc ce 7c 3c 0d 50     mov     0x500d3c7c, d2
4841779d: e8                    add     d2, d0
4841779e: f1 60                 add     d0, a0
484177a0: 58 34                 mov     (0x34, sp), d0
484177a2: f1 d9                 mov     a2, d1
484177a4: f8 10 04              mov     d0, (4, a0)
484177a7: 8c                    mov     d3, d0
484177a8: f8 c0 05              asl     5, d0
484177ab: e8                    add     d2, d0
484177ac: f8 c1 04              asl     4, d1
484177af: f1 e4                 mov     d1, a0
484177b1: f1 60                 add     d0, a0
484177b3: 58 38                 mov     (0x38, sp), d0
484177b5: 8d                    mov     d3, d1
484177b6: f8 10 08              mov     d0, (8, a0)
484177b9: 5d 3c                 mov     (0x3c, sp), a1
484177bb: f8 c1 05              asl     5, d1
484177be: e9                    add     d2, d1
484177bf: f1 d8                 mov     a2, d0
484177c1: f8 c0 04              asl     4, d0
484177c4: e1                    add     d0, d1
484177c5: f1 e4                 mov     d1, a0
484177c7: f8 34 0c              mov     a1, (0xc, a0)
484177ca: 8c                    mov     d3, d0
484177cb: f8 c0 05              asl     5, d0
484177ce: e8                    add     d2, d0
484177cf: f1 d9                 mov     a2, d1
484177d1: f8 c1 04              asl     4, d1
484177d4: f1 e4                 mov     d1, a0
484177d6: f1 60                 add     d0, a0
484177d8: f8 40 01              movbu   (1, a0), d0
484177db: a0 00                 cmp     0, d0
484177dd: c9 30                 bne     0x4841780d
484177df: dd 30 1e 01 00 00 10  call    0x4842960f, 0, 0x10
484177e6: 81                    mov     d0, d1
484177e7: f8 c3 05              asl     5, d3
484177ea: eb                    add     d2, d3
484177eb: f1 da                 mov     a2, d2
484177ed: f8 c2 04              asl     4, d2
484177f0: eb                    add     d2, d3
484177f1: f1 ec                 mov     d3, a0
484177f3: 80 01                 mov     1, d0
484177f5: f8 50 01              movbu   d0, (1, a0)
484177f8: 46 10                 mov     d1, (0x10, sp)
484177fa: fc cc 1e 00 05 00     mov     0x0005001e, d0
48417800: 42 14                 mov     d0, (0x14, sp)
48417802: 4f 18                 mov     a3, (0x18, sp)
48417804: 80 10                 mov     0x10, d0
48417806: dd 94 24 01 00 f0 34  call    0x48429c9a, [d2,d3,a2,a3], 0x34
4841780d: df f0 2c              ret     [d2,d3,a2,a3], 0x2c

ScreenProc:
48417810: cf f0                 movm    [d2,d3,a2,a3], (sp)
48417812: f8 fe ec              add     -0x14, sp
48417815: 82                    mov     d0, d2
48417816: 87                    mov     d1, d3
48417817: fc cb 01 00 05 00     cmp     0x50001, d3
4841781d: c2 05                 bge     0x48417822
4841781f: cc 8e 02              jmp     0x48417aad
48417822: fc cb b2 00 06 00     cmp     0x600b2, d3
48417828: c3 05                 ble     0x4841782d
4841782a: cc 83 02              jmp     0x48417aad
4841782d: fc dd fc 18 5a 48     mov     0x485a18fc, a1
48417833: 80 0f                 mov     0xf, d0
48417835: fc cd 00 00 fb ff     mov     0xfffb0000, d1
4841783b: ed                    add     d3, d1
4841783c: f2 04                 and     d1, d0
4841783e: f8 c0 03              asl     3, d0
48417841: f1 e0                 mov     d0, a0
48417843: f1 74                 add     a1, a0
48417845: 70                    mov     (a0), d0
48417846: a4                    cmp     d1, d0
48417847: c8 18                 beq     0x4841785f
48417849: db                    setlb
4841784a: a0 00                 cmp     0, d0
4841784c: c9 05                 bne     0x48417851
4841784e: cc 5f 02              jmp     0x48417aad
48417851: 20 08                 add     8, a0
48417853: fc d8 7c 19 5a 48     cmp     0x485a197c, a0
48417859: c4 03                 bcs     0x4841785c
4841785b: 94                    mov     a1, a0
4841785c: 70                    mov     (a0), d0
4841785d: a4                    cmp     d1, d0
4841785e: d9                    lne
4841785f: f8 20 04              mov     (4, a0), a0
48417862: f0 f4                 jmp     (a0)
48417864: 80 01                 mov     1, d0
48417866: cd a6 ef 00 00        call    0x4841680c, 0, 0
4841786b: 00                    clr     d0
4841786c: cd ab fd 80 18        call    0x48417617, [d2], 0x18
48417871: dd cd 1b 01 00 00 10  call    0x4842943e, 0, 0x10
48417878: 04                    clr     d1
48417879: 46 10                 mov     d1, (0x10, sp)
4841787b: fc cd 48 00 06 00     mov     0x00060048, d1
48417881: dd 0c 1b 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417888: a0 ff                 cmp     -1, d0
4841788a: c8 24                 beq     0x484178ae
4841788c: dd d9 1b 01 00 40 14  call    0x48429465, [d3], 0x14
48417893: dd ab 1b 01 00 00 10  call    0x4842943e, 0, 0x10
4841789a: 04                    clr     d1
4841789b: 46 10                 mov     d1, (0x10, sp)
4841789d: fc cd 48 00 06 00     mov     0x00060048, d1
484178a3: dd ea 1a 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484178aa: a0 ff                 cmp     -1, d0
484178ac: c9 e0                 bne     0x4841788c
484178ae: dd 90 1b 01 00 00 10  call    0x4842943e, 0, 0x10
484178b5: fc cd 41 00 04 00     mov     0x00040041, d1
484178bb: 46 10                 mov     d1, (0x10, sp)
484178bd: fc cd 14 00 06 00     mov     0x00060014, d1
484178c3: dd ca 1a 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484178ca: a0 00                 cmp     0, d0
484178cc: c9 35                 bne     0x48417901
484178ce: 5c 34                 mov     (0x34, sp), a0
484178d0: 80 ff                 mov     -1, d0
484178d2: 43 10                 mov     a0, (0x10, sp)
484178d4: fc cd 02 00 05 00     mov     0x00050002, d1
484178da: dd b3 1a 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484178e1: dd 5d 1b 01 00 00 10  call    0x4842943e, 0, 0x10
484178e8: fc cd 41 00 04 00     mov     0x00040041, d1
484178ee: 46 10                 mov     d1, (0x10, sp)
484178f0: fc cd 14 00 06 00     mov     0x00060014, d1
484178f6: dd 97 1a 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484178fd: a0 00                 cmp     0, d0
484178ff: c8 cf                 beq     0x484178ce
48417901: 5e 34                 mov     (0x34, sp), a2
48417903: 80 ff                 mov     -1, d0
48417905: fc cd 02 00 05 00     mov     0x00050002, d1
4841790b: 4b 10                 mov     a2, (0x10, sp)
4841790d: dd 80 1a 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417914: 88                    mov     d2, d0
48417915: dd 05 60 01 00 00 00  call    0x4842d91a, 0, 0
4841791c: 93                    mov     a0, a3
4841791d: ba 00                 cmp     0, a2
4841791f: c8 0a                 beq     0x48417929
48417921: ba 05                 cmp     5, a2
48417923: c8 06                 beq     0x48417929
48417925: ba 03                 cmp     3, a2
48417927: c9 08                 bne     0x4841792f
48417929: f8 23 24              mov     (0x24, a3), a0
4841792c: 80 ff                 mov     -1, d0
4841792e: 60                    mov     d0, (a0)
4841792f: 00                    clr     d0
48417930: 42 10                 mov     d0, (0x10, sp)
48417932: 88                    mov     d2, d0
48417933: fc cd a2 00 06 00     mov     0x000600a2, d1
48417939: dd 54 1a 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417940: 18                    exth    d0
48417941: cd 7f 01 00 0c        call    0x48417ac0, 0, 0xc
48417946: dd 3f 50 01 00 00 10  call    0x4842c985, 0, 0x10
4841794d: 4a 10                 mov     d2, (0x10, sp)
4841794f: fc cd 6d 00 06 00     mov     0x0006006d, d1
48417955: dd 38 1a 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841795c: 4b 10                 mov     a2, (0x10, sp)
4841795e: 8d                    mov     d3, d1
4841795f: 88                    mov     d2, d0
48417960: dd 09 1c 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48417967: ba 00                 cmp     0, a2
48417969: c8 24                 beq     0x4841798d
4841796b: ba 05                 cmp     5, a2
4841796d: c8 20                 beq     0x4841798d
4841796f: ba 03                 cmp     3, a2
48417971: c8 1c                 beq     0x4841798d
48417973: ba 04                 cmp     4, a2
48417975: c9 18                 bne     0x4841798d
48417977: 23 24                 add     0x24, a3
48417979: f0 03                 mov     (a3), a0
4841797b: 70                    mov     (a0), d0
4841797c: a0 ff                 cmp     -1, d0
4841797e: c8 0f                 beq     0x4841798d
48417980: f0 03                 mov     (a3), a0
48417982: 8d                    mov     d3, d1
48417983: 70                    mov     (a0), d0
48417984: 4b 10                 mov     a2, (0x10, sp)
48417986: dd 07 1a 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841798d: 00                    clr     d0
4841798e: df f0 24              ret     [d2,d3,a2,a3], 0x24
48417991: 5e 34                 mov     (0x34, sp), a2
48417993: 88                    mov     d2, d0
48417994: 4b 10                 mov     a2, (0x10, sp)
48417996: 8d                    mov     d3, d1
48417997: dd d2 1b 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841799e: 88                    mov     d2, d0
4841799f: dd 7b 5f 01 00 00 00  call    0x4842d91a, 0, 0
484179a6: ba 00                 cmp     0, a2
484179a8: c8 0a                 beq     0x484179b2
484179aa: ba 05                 cmp     5, a2
484179ac: c8 06                 beq     0x484179b2
484179ae: ba 04                 cmp     4, a2
484179b0: c9 08                 bne     0x484179b8
484179b2: f8 20 24              mov     (0x24, a0), a0
484179b5: 80 ff                 mov     -1, d0
484179b7: 60                    mov     d0, (a0)
484179b8: 00                    clr     d0
484179b9: df f0 24              ret     [d2,d3,a2,a3], 0x24
484179bc: 5c 34                 mov     (0x34, sp), a0
484179be: 8d                    mov     d3, d1
484179bf: 43 10                 mov     a0, (0x10, sp)
484179c1: 88                    mov     d2, d0
484179c2: dd a7 1b 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484179c9: 00                    clr     d0
484179ca: 42 10                 mov     d0, (0x10, sp)
484179cc: 80 ff                 mov     -1, d0
484179ce: fc cd 08 00 05 00     mov     0x00050008, d1
484179d4: dd de 19 01 00 c0 24  call    0x484293b2, [d2,d3], 0x24
484179db: 00                    clr     d0
484179dc: df f0 24              ret     [d2,d3,a2,a3], 0x24
484179df: dd 24 c0 00 00 00 10  call    0x48423a03, 0, 0x10
484179e6: 00                    clr     d0
484179e7: df f0 24              ret     [d2,d3,a2,a3], 0x24
484179ea: 88                    mov     d2, d0
484179eb: dd 2f 5f 01 00 00 00  call    0x4842d91a, 0, 0
484179f2: 5f 34                 mov     (0x34, sp), a3
484179f4: 92                    mov     a0, a2
484179f5: bf ff                 cmp     0xff, a3
484179f7: c7 05                 bls     0x484179fc
484179f9: cc 80 00              jmp     0x48417a79
484179fc: bf 17                 cmp     0x17, a3
484179fe: c9 7b                 bne     0x48417a79
48417a00: fc cc 3d 00 04 00     mov     0x0004003d, d0
48417a06: 42 10                 mov     d0, (0x10, sp)
48417a08: 88                    mov     d2, d0
48417a09: fc cd 24 00 06 00     mov     0x00060024, d1
48417a0f: dd 7e 19 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417a16: a0 00                 cmp     0, d0
48417a18: c9 61                 bne     0x48417a79
48417a1a: dd 6b 4f 01 00 00 10  call    0x4842c985, 0, 0x10
48417a21: 04                    clr     d1
48417a22: 46 10                 mov     d1, (0x10, sp)
48417a24: fc cd 70 00 06 00     mov     0x00060070, d1
48417a2a: dd 63 19 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417a31: a0 00                 cmp     0, d0
48417a33: c9 18                 bne     0x48417a4b
48417a35: 22 20                 add     0x20, a2
48417a37: 72                    mov     (a2), d0
48417a38: fc c8 00 00 0f 00     cmp     0xf0000, d0
48417a3e: c8 3b                 beq     0x48417a79
48417a40: 72                    mov     (a2), d0
48417a41: 04                    clr     d1
48417a42: dd b2 39 01 00 e0 20  call    0x4842b3f4, [d2,d3,a2], 0x20
48417a49: ca 30                 bra     0x48417a79
48417a4b: dd 3a 4f 01 00 00 10  call    0x4842c985, 0, 0x10
48417a52: 04                    clr     d1
48417a53: 46 10                 mov     d1, (0x10, sp)
48417a55: fc cd 6f 00 06 00     mov     0x0006006f, d1
48417a5b: dd 32 19 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417a62: dd 23 4f 01 00 00 10  call    0x4842c985, 0, 0x10
48417a69: 04                    clr     d1
48417a6a: 46 10                 mov     d1, (0x10, sp)
48417a6c: fc cd 8b 00 06 00     mov     0x0006008b, d1
48417a72: dd 1b 19 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417a79: 4f 10                 mov     a3, (0x10, sp)
48417a7b: 8d                    mov     d3, d1
48417a7c: 88                    mov     d2, d0
48417a7d: dd ec 1a 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48417a84: ca 36                 bra     0x48417aba
48417a86: 88                    mov     d2, d0
48417a87: dd 93 5e 01 00 00 00  call    0x4842d91a, 0, 0
48417a8e: f8 24 24              mov     (0x24, a0), a1
48417a91: 5c 34                 mov     (0x34, sp), a0
48417a93: 00                    clr     d0
48417a94: f0 11                 mov     a0, (a1)
48417a96: ca 24                 bra     0x48417aba
48417a98: 88                    mov     d2, d0
48417a99: dd 81 5e 01 00 00 00  call    0x4842d91a, 0, 0
48417aa0: f8 20 24              mov     (0x24, a0), a0
48417aa3: 70                    mov     (a0), d0
48417aa4: ca 16                 bra     0x48417aba
48417aa6: 00                    clr     d0
48417aa7: ca 13                 bra     0x48417aba
48417aa9: 80 ff                 mov     -1, d0
48417aab: ca 0f                 bra     0x48417aba
48417aad: 5c 34                 mov     (0x34, sp), a0
48417aaf: 8d                    mov     d3, d1
48417ab0: 43 10                 mov     a0, (0x10, sp)
48417ab2: 88                    mov     d2, d0
48417ab3: dd b6 1a 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48417aba: df f0 24              ret     [d2,d3,a2,a3], 0x24
48417abd: f8 fe f4              add     -0xc, sp
48417ac0: 18                    exth    d0
48417ac1: a0 00                 cmp     0, d0
48417ac3: c0 4f                 blt     0x48417b12
48417ac5: a0 0c                 cmp     0xc, d0
48417ac7: c1 4b                 bgt     0x48417b12
48417ac9: 81                    mov     d0, d1
48417aca: 55                    asl2    d1
48417acb: fc dc 7c 19 5a 48     mov     0x485a197c, a0
48417ad1: f3 84                 mov     (d1, a0), a0
48417ad3: f0 f4                 jmp     (a0)
48417ad5: fc ad a2 35 0d 50     movhu   (0x500d35a2), d1
48417adb: fc ac a4 35 0d 50     movhu   (0x500d35a4), d0
48417ae1: a5 00                 cmp     0, d1
48417ae3: c9 30                 bne     0x48417b13
48417ae5: 00                    clr     d0
48417ae6: ca 2d                 bra     0x48417b13
48417ae8: fc ad 9e 35 0d 50     movhu   (0x500d359e), d1
48417aee: fc ac a4 35 0d 50     movhu   (0x500d35a4), d0
48417af4: a5 00                 cmp     0, d1
48417af6: c9 1d                 bne     0x48417b13
48417af8: 00                    clr     d0
48417af9: ca 1a                 bra     0x48417b13
48417afb: fc ad a0 35 0d 50     movhu   (0x500d35a0), d1
48417b01: fc ac a4 35 0d 50     movhu   (0x500d35a4), d0
48417b07: a5 00                 cmp     0, d1
48417b09: c9 0a                 bne     0x48417b13
48417b0b: 00                    clr     d0
48417b0c: ca 07                 bra     0x48417b13
48417b0e: 28 fd                 add     -3, d0
48417b10: ca 03                 bra     0x48417b13
48417b12: 00                    clr     d0
48417b13: fc 83 10 a0 02 50     movhu   d0, (0x5002a010)
48417b19: 1c                    exthu   d0
48417b1a: dd 8c 02 01 00 80 10  call    0x48427da6, [d2], 0x10
48417b21: df 00 0c              ret     0, 0xc

GetEditSwPoint:
48417b24: f8 fe f0        add     -0x10, sp
48417b27: 1c              exthu   d0
48417b28: cd 08 00 00 00  call    0x48417b30, 0, 0
48417b2d: df 00 10        ret     0, 0x10

GetEditSwPointInit:
48417b30: 91                 mov     a0, a1
48417b31: 81                 mov     d0, d1
48417b32: 1d                 exthu   d1
48417b33: 84                 mov     d1, d0
48417b34: f8 c4 07           lsr     7, d0
48417b37: f8 e0 01           and     0x01, d0
48417b3a: 1c                 exthu   d0
48417b3b: a0 00              cmp     0, d0
48417b3d: c8 22              beq     0x48417b5f
48417b3f: 80 1f              mov     0x1f, d0
48417b41: f2 04              and     d1, d0
48417b43: 1c                 exthu   d0
48417b44: 54                 asl2    d0
48417b45: fc dc 04 e4 59 48  mov     0x4859e404, a0
48417b4b: f4                 movhu   (d0, a0), d0
48417b4c: 80 f8              mov     -8, d0
48417b4e: e1                 add     d0, d1
48417b4f: 1f                 exthu   d3
48417b50: f0 71              movhu   d0, (a1)
48417b52: 84                 mov     d1, d0
48417b53: 1c                 exthu   d0
48417b54: 54                 asl2    d0
48417b55: f1 60              add     d0, a0
48417b57: f8 60 02           movhu   (2, a0), d0
48417b5a: f8 71 02           movhu   d0, (2, a1)
48417b5d: ca 20              bra     0x48417b7d
48417b5f: 80 1f              mov     0x1f, d0
48417b61: f2 04              and     d1, d0
48417b63: 1c                 exthu   d0
48417b64: 54                 asl2    d0
48417b65: fc dc 84 e3 59 48  mov     0x4859e384, a0
48417b6b: f4                 movhu   (d0, a0), d0
48417b6c: 80 f8              mov     -8, d0
48417b6e: e1                 add     d0, d1
48417b6f: 1f                 exthu   d3
48417b70: f0 71              movhu   d0, (a1)
48417b72: 84                 mov     d1, d0
48417b73: 1c                 exthu   d0
48417b74: 54                 asl2    d0
48417b75: f1 60              add     d0, a0
48417b77: f8 60 02           movhu   (2, a0), d0
48417b7a: f8 71 02           movhu   d0, (2, a1)
48417b7d: de 00 00           retf    0, 0

IvScreenProc:
48417b80: f8 fe ec              add     -0x14, sp
48417b83: fc c9 b2 00 06 00     cmp     0x600b2, d1
48417b89: c9 0e                 bne     0x48417b97
48417b8b: 80 0d                 mov     0xd, d0
48417b8d: dd 19 02 01 00 80 10  call    0x48427da6, [d2], 0x10
48417b94: 00                    clr     d0
48417b95: ca 0d                 bra     0x48417ba2
48417b97: 5c 24                 mov     (0x24, sp), a0
48417b99: 43 10                 mov     a0, (0x10, sp)
48417b9b: dd ce 19 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48417ba2: df 00 14              ret     0, 0x14

TtlScreenProc:
48417ba5: cf f0                 movm    [d2,d3,a2,a3], (sp)
48417ba7: f8 fe d4              add     -0x2c, sp
48417baa: 83                    mov     d0, d3
48417bab: 86                    mov     d1, d2
48417bac: fc ca 01 00 05 00     cmp     0x50001, d2
48417bb2: c8 52                 beq     0x48417c04
48417bb4: fc ca b2 00 06 00     cmp     0x600b2, d2
48417bba: c9 05                 bne     0x48417bbf
48417bbc: cc aa 00              jmp     0x48417c66
48417bbf: fc ca 14 00 05 00     cmp     0x50014, d2
48417bc5: c9 05                 bne     0x48417bca
48417bc7: cc 0c 01              jmp     0x48417cd3
48417bca: fc ca da 00 06 00     cmp     0x600da, d2
48417bd0: c9 05                 bne     0x48417bd5
48417bd2: cc 23 01              jmp     0x48417cf5
48417bd5: fc ca db 00 06 00     cmp     0x600db, d2
48417bdb: c9 05                 bne     0x48417be0
48417bdd: cc 2b 01              jmp     0x48417d08
48417be0: fc ca b4 00 06 00     cmp     0x600b4, d2
48417be6: c9 05                 bne     0x48417beb
48417be8: cc 2c 01              jmp     0x48417d14
48417beb: fc ca b8 00 06 00     cmp     0x600b8, d2
48417bf1: c9 05                 bne     0x48417bf6
48417bf3: cc b6 01              jmp     0x48417da9
48417bf6: fc ca 3a 00 06 00     cmp     0x6003a, d2
48417bfc: c9 05                 bne     0x48417c01
48417bfe: cc b7 01              jmp     0x48417db5
48417c01: cc cb 01              jmp     0x48417dcc
48417c04: fc cc 2d 00 04 00     mov     0x0004002d, d0
48417c0a: 42 10                 mov     d0, (0x10, sp)
48417c0c: 8c                    mov     d3, d0
48417c0d: fc cd 24 00 06 00     mov     0x00060024, d1
48417c13: dd 7a 17 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417c1a: 04                    clr     d1
48417c1b: a4                    cmp     d1, d0
48417c1c: c9 04                 bne     0x48417c20
48417c1e: 85 01                 mov     1, d1
48417c20: fc 85 08 a0 02 50     mov     d1, (0x5002a008)
48417c26: fc cc 21 00 04 00     mov     0x00040021, d0
48417c2c: 42 10                 mov     d0, (0x10, sp)
48417c2e: 8c                    mov     d3, d0
48417c2f: fc cd 24 00 06 00     mov     0x00060024, d1
48417c35: dd 58 17 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417c3c: fc 81 0c a0 02 50     mov     d0, (0x5002a00c)
48417c42: 5e 4c                 mov     (0x4c, sp), a2
48417c44: 8c                    mov     d3, d0
48417c45: 4b 10                 mov     a2, (0x10, sp)
48417c47: 89                    mov     d2, d1
48417c48: dd 21 19 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48417c4f: fc a4 08 a0 02 50     mov     (0x5002a008), d0
48417c55: a0 00                 cmp     0, d0
48417c57: c8 0b                 beq     0x48417c62
48417c59: 4b 10                 mov     a2, (0x10, sp)
48417c5b: 89                    mov     d2, d1
48417c5c: 8c                    mov     d3, d0
48417c5d: cd 3e 17 a0 24        call    0x4841939b, [d2,a2], 0x24
48417c62: 00                    clr     d0
48417c63: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
48417c66: 5c 4c                 mov     (0x4c, sp), a0
48417c68: 3f                    mov     sp, a3
48417c69: 43 10                 mov     a0, (0x10, sp)
48417c6b: dd fe 18 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48417c72: 23 20                 add     0x20, a3
48417c74: 8c                    mov     d3, d0
48417c75: 9c                    mov     a3, a0
48417c76: cd 7c f1 00 14        call    0x48416df2, 0, 0x14
48417c7b: 00                    clr     d0
48417c7c: 42 10                 mov     d0, (0x10, sp)
48417c7e: 8c                    mov     d3, d0
48417c7f: fc cd b8 00 06 00     mov     0x000600b8, d1
48417c85: dd 08 17 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417c8c: 82                    mov     d0, d2
48417c8d: 2c 00 01              mov     0x100, d0
48417c90: cd 9a e9 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
48417c95: 43 10                 mov     a0, (0x10, sp)
48417c97: 92                    mov     a0, a2
48417c98: 8c                    mov     d3, d0
48417c99: fc cd 3a 00 06 00     mov     0x0006003a, d1
48417c9f: dd ee 16 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417ca6: fc a4 0c a0 02 50     mov     (0x5002a00c), d0
48417cac: 99                    mov     a2, a1
48417cad: 42 18                 mov     d0, (0x18, sp)
48417caf: 88                    mov     d2, d0
48417cb0: 9c                    mov     a3, a0
48417cb1: 85 01                 mov     1, d1
48417cb3: cd 56 01 f0 34        call    0x48417e09, [d2,d3,a2,a3], 0x34
48417cb8: 98                    mov     a2, a0
48417cb9: cd 25 ea f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
48417cbe: 00                    clr     d0
48417cbf: 42 10                 mov     d0, (0x10, sp)
48417cc1: fc cd b4 00 06 00     mov     0x000600b4, d1
48417cc7: 8c                    mov     d3, d0
48417cc8: dd c5 16 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48417ccf: 00                    clr     d0
48417cd0: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
48417cd3: 5e 4c                 mov     (0x4c, sp), a2
48417cd5: 4b 10                 mov     a2, (0x10, sp)
48417cd7: dd 92 18 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48417cde: fc a4 08 a0 02 50     mov     (0x5002a008), d0
48417ce4: a0 00                 cmp     0, d0
48417ce6: c8 0b                 beq     0x48417cf1
48417ce8: 4b 10                 mov     a2, (0x10, sp)
48417cea: 89                    mov     d2, d1
48417ceb: 8c                    mov     d3, d0
48417cec: cd af 16 a0 24        call    0x4841939b, [d2,a2], 0x24
48417cf1: 00                    clr     d0
48417cf2: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
48417cf5: 5c 4c                 mov     (0x4c, sp), a0
48417cf7: 00                    clr     d0
48417cf8: b0 00                 cmp     0, a0
48417cfa: c9 04                 bne     0x48417cfe
48417cfc: 80 01                 mov     1, d0
48417cfe: fc 81 08 a0 02 50     mov     d0, (0x5002a008)
48417d04: 00                    clr     d0
48417d05: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
48417d08: 58 4c                 mov     (0x4c, sp), d0
48417d0a: fc 81 0c a0 02 50     mov     d0, (0x5002a00c)
48417d10: 00                    clr     d0
48417d11: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
48417d14: fc a4 08 a0 02 50     mov     (0x5002a008), d0
48417d1a: a0 00                 cmp     0, d0
48417d1c: c9 05                 bne     0x48417d21
48417d1e: cc 88 00              jmp     0x48417da6
48417d21: 3c                    mov     sp, a0
48417d22: f1 d2                 mov     a0, d2
48417d24: 2a 20                 add     0x20, d2
48417d26: 8c                    mov     d3, d0
48417d27: f1 e8                 mov     d2, a0
48417d29: cd c9 f0 00 14        call    0x48416df2, 0, 0x14
48417d2e: f8 bc 22              movhu   (0x22, sp), d0
48417d31: 3f                    mov     sp, a3
48417d32: 18                    exth    d0
48417d33: f8 93 22              movhu   d0, (0x22, sp)
48417d36: f8 bc 20              movhu   (0x20, sp), d0
48417d39: 23 28                 add     0x28, a3
48417d3b: 18                    exth    d0
48417d3c: f8 93 20              movhu   d0, (0x20, sp)
48417d3f: f8 bc 24              movhu   (0x24, sp), d0
48417d42: f1 e8                 mov     d2, a0
48417d44: 18                    exth    d0
48417d45: f8 93 24              movhu   d0, (0x24, sp)
48417d48: f8 bc 22              movhu   (0x22, sp), d0
48417d4b: 9d                    mov     a3, a1
48417d4c: 18                    exth    d0
48417d4d: 28 1b                 add     0x1b, d0
48417d4f: f8 93 26              movhu   d0, (0x26, sp)
48417d52: cd e1 f0 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
48417d57: fc a4 0c a0 02 50     mov     (0x5002a00c), d0
48417d5d: a0 00                 cmp     0, d0
48417d5f: c8 0d                 beq     0x48417d6c
48417d61: f8 bc 24              movhu   (0x24, sp), d0
48417d64: 18                    exth    d0
48417d65: 28 94                 add     -0x6c, d0
48417d67: f8 93 28              movhu   d0, (0x28, sp)
48417d6a: ca 0b                 bra     0x48417d75
48417d6c: f8 bc 24              movhu   (0x24, sp), d0
48417d6f: 18                    exth    d0
48417d70: 28 e0                 add     -0x20, d0
48417d72: f8 93 28              movhu   d0, (0x28, sp)
48417d75: 80 20                 mov     0x20, d0
48417d77: cd b3 e8 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
48417d7c: 92                    mov     a0, a2
48417d7d: 43 10                 mov     a0, (0x10, sp)
48417d7f: fc cd 3a 00 06 00     mov     0x0006003a, d1
48417d85: 8c                    mov     d3, d0
48417d86: cd 15 16 a0 24        call    0x4841939b, [d2,a2], 0x24
48417d8b: 4b 10                 mov     a2, (0x10, sp)
48417d8d: 80 17                 mov     0x17, d0
48417d8f: 42 1c                 mov     d0, (0x1c, sp)
48417d91: f1 e8                 mov     d2, a0
48417d93: 80 04                 mov     4, d0
48417d95: 2d ff 00              mov     0xff, d1
48417d98: 9d                    mov     a3, a1
48417d99: dd ff da 00 00 f0 10  call    0x48425898, [d2,d3,a2,a3], 0x10
48417da0: 98                    mov     a2, a0
48417da1: cd 3d e9 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
48417da6: 00                    clr     d0
48417da7: ca 30                 bra     0x48417dd7
48417da9: dd 71 5b 01 00 00 00  call    0x4842d91a, 0, 0
48417db0: f8 00 2c              mov     (0x2c, a0), d0
48417db3: ca 24                 bra     0x48417dd7
48417db5: dd 65 5b 01 00 00 00  call    0x4842d91a, 0, 0
48417dbc: 91                    mov     a0, a1
48417dbd: 5c 4c                 mov     (0x4c, sp), a0
48417dbf: f8 25 28              mov     (0x28, a1), a1
48417dc2: dd 8f b2 be 03 20 04  call    0x4c003051, [a2], 4
48417dc9: 00                    clr     d0
48417dca: ca 0d                 bra     0x48417dd7
48417dcc: 5c 4c                 mov     (0x4c, sp), a0
48417dce: 43 10                 mov     a0, (0x10, sp)
48417dd0: dd 99 17 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48417dd7: df f0 3c              ret     [d2,d3,a2,a3], 0x3c

SetTempoObject:
48417dda: f8 fe ec           add     -0x14, sp
48417ddd: 42 10              mov     d0, (0x10, sp)
48417ddf: 80 ff              mov     -1, d0
48417de1: fc cd da 00 06 00  mov     0x000600da, d1
48417de7: cd c3 fd f0 3c     call    0x48417baa, [d2,d3,a2,a3], 0x3c
48417dec: df 00 14           ret     0, 0x14

SetPageObject:
48417def: f8 fe ec           add     -0x14, sp
48417df2: 42 10              mov     d0, (0x10, sp)
48417df4: 80 ff              mov     -1, d0
48417df6: fc cd db 00 06 00  mov     0x000600db, d1
48417dfc: cd ae fd f0 3c     call    0x48417baa, [d2,d3,a2,a3], 0x3c
48417e01: df 00 14           ret     0, 0x14

DrawTitleBar:
48417e04: cf f0                 movm    [d2,d3,a2,a3], (sp)
48417e06: f8 fe dc              add     -0x24, sp
48417e09: 93                    mov     a0, a3
48417e0a: 47 48                 mov     a1, (0x48, sp)
48417e0c: 83                    mov     d0, d3
48417e0d: f8 63 02              movhu   (2, a3), d0
48417e10: 86                    mov     d1, d2
48417e11: 18                    exth    d0
48417e12: f8 93 1e              movhu   d0, (0x1e, sp)
48417e15: 18                    exth    d0
48417e16: 28 1b                 add     0x1b, d0
48417e18: f8 93 22              movhu   d0, (0x22, sp)
48417e1b: f0 63                 movhu   (a3), d0
48417e1d: 3e                    mov     sp, a2
48417e1e: 18                    exth    d0
48417e1f: f8 93 1c              movhu   d0, (0x1c, sp)
48417e22: f8 63 04              movhu   (4, a3), d0
48417e25: 22 1c                 add     0x1c, a2
48417e27: 18                    exth    d0
48417e28: f8 93 20              movhu   d0, (0x20, sp)
48417e2b: dd 21 9f 00 00 00 00  call    0x48421d4c, 0, 0
48417e32: 1c                    exthu   d0
48417e33: a0 02                 cmp     2, d0
48417e35: c9 11                 bne     0x48417e46
48417e37: 2c c0 00              mov     0xc0, d0
48417e3a: 85 17                 mov     0x17, d1
48417e3c: 98                    mov     a2, a0
48417e3d: dd 69 e3 00 00 e0 20  call    0x484261a6, [d2,d3,a2], 0x20
48417e44: ca 17                 bra     0x48417e5b
48417e46: 98                    mov     a2, a0
48417e47: 80 17                 mov     0x17, d0
48417e49: dd e8 b1 00 00 a0 18  call    0x48423031, [d2,a2], 0x18
48417e50: 2c f8 00              mov     0xf8, d0
48417e53: 98                    mov     a2, a0
48417e54: dd 50 b3 00 00 a0 18  call    0x484231a4, [d2,a2], 0x18
48417e5b: 5c 4c                 mov     (0x4c, sp), a0
48417e5d: 16                    extbu   d2
48417e5e: 43 18                 mov     a0, (0x18, sp)
48417e60: 5d 48                 mov     (0x48, sp), a1
48417e62: 89                    mov     d2, d1
48417e63: 8c                    mov     d3, d0
48417e64: 9c                    mov     a3, a0
48417e65: cd 0d 00 f0 60        call    0x48417e72, [d2,d3,a2,a3], 0x60
48417e6a: df f0 34              ret     [d2,d3,a2,a3], 0x34

DrawTitleBarOW:
48417e6d: cf f0                 movm    [d2,d3,a2,a3], (sp)
48417e6f: f8 fe b0              add     -0x50, sp
48417e72: 47 74                 mov     a1, (0x74, sp)
48417e74: f8 96 70              movbu   d1, (0x70, sp)
48417e77: 42 6c                 mov     d0, (0x6c, sp)
48417e79: 91                    mov     a0, a1
48417e7a: f8 61 02              movhu   (2, a1), d0
48417e7d: 3c                    mov     sp, a0
48417e7e: 18                    exth    d0
48417e7f: f1 d1                 mov     a0, d1
48417e81: 29 34                 add     0x34, d1
48417e83: 46 2c                 mov     d1, (0x2c, sp)
48417e85: f8 93 36              movhu   d0, (0x36, sp)
48417e88: 18                    exth    d0
48417e89: 28 1b                 add     0x1b, d0
48417e8b: f8 93 3a              movhu   d0, (0x3a, sp)
48417e8e: f0 61                 movhu   (a1), d0
48417e90: 8f 4c                 mov     0x4c, d3
48417e92: 18                    exth    d0
48417e93: f8 93 34              movhu   d0, (0x34, sp)
48417e96: f8 61 04              movhu   (4, a1), d0
48417e99: 18                    exth    d0
48417e9a: f8 93 38              movhu   d0, (0x38, sp)
48417e9d: 58 78                 mov     (0x78, sp), d0
48417e9f: a0 00                 cmp     0, d0
48417ea1: c9 03                 bne     0x48417ea4
48417ea3: 0c                    clr     d3
48417ea4: 58 6c                 mov     (0x6c, sp), d0
48417ea6: 08                    clr     d2
48417ea7: a8                    cmp     d2, d0
48417ea8: c8 04                 beq     0x48417eac
48417eaa: 8a 1d                 mov     0x1d, d2
48417eac: f1 d0                 mov     a0, d0
48417eae: 28 3c                 add     0x3c, d0
48417eb0: 42 24                 mov     d0, (0x24, sp)
48417eb2: f1 e4                 mov     d1, a0
48417eb4: 5d 24                 mov     (0x24, sp), a1
48417eb6: 2c c0 00              mov     0xc0, d0
48417eb9: cd 43 ec f0 2c        call    0x48416afc, [d2,d3,a2,a3], 0x2c
48417ebe: f8 bd 3c              movhu   (0x3c, sp), d1
48417ec1: 1a                    exth    d2
48417ec2: 19                    exth    d1
48417ec3: e6                    add     d1, d2
48417ec4: f8 9b 3c              movhu   d2, (0x3c, sp)
48417ec7: 3c                    mov     sp, a0
48417ec8: f1 d0                 mov     a0, d0
48417eca: 28 44                 add     0x44, d0
48417ecc: 42 28                 mov     d0, (0x28, sp)
48417ece: 5c 24                 mov     (0x24, sp), a0
48417ed0: f1 e1                 mov     d0, a1
48417ed2: cd 61 ef f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
48417ed7: 5c 74                 mov     (0x74, sp), a0
48417ed9: 80 04                 mov     4, d0
48417edb: dd e5 61 01 00 f0 24  call    0x4842e0c0, [d2,d3,a2,a3], 0x24
48417ee2: f8 93 30              movhu   d0, (0x30, sp)
48417ee5: f8 be 44              movhu   (0x44, sp), d2
48417ee8: f8 bc 30              movhu   (0x30, sp), d0
48417eeb: 85 02                 mov     2, d1
48417eed: 18                    exth    d0
48417eee: 1a                    exth    d2
48417eef: f1 e2                 mov     d0, a2
48417ef1: dd e4 9a be 03 00 00  call    0x4c0019d5, 0, 0
48417ef8: 81                    mov     d0, d1
48417ef9: f8 bc 40              movhu   (0x40, sp), d0
48417efc: 1b                    exth    d3
48417efd: 18                    exth    d0
48417efe: 4e 20                 mov     d3, (0x20, sp)
48417f00: e6                    add     d1, d2
48417f01: f1 0c                 sub     d3, d0
48417f03: 28 fc                 add     -4, d0
48417f05: a2                    cmp     d0, d2
48417f06: 9f 04                 mov     4, a3
48417f08: c1 05                 bgt     0x48417f0d
48417f0a: cc b0 00              jmp     0x48417fba
48417f0d: 58 78                 mov     (0x78, sp), d0
48417f0f: a0 00                 cmp     0, d0
48417f11: c9 05                 bne     0x48417f16
48417f13: cc 97 00              jmp     0x48417faa
48417f16: f8 be 44              movhu   (0x44, sp), d2
48417f19: f8 bf 40              movhu   (0x40, sp), d3
48417f1c: f1 d8                 mov     a2, d0
48417f1e: 85 02                 mov     2, d1
48417f20: dd b5 9a be 03 00 00  call    0x4c0019d5, 0, 0
48417f27: 1a                    exth    d2
48417f28: 1b                    exth    d3
48417f29: e2                    add     d0, d2
48417f2a: 58 20                 mov     (0x20, sp), d0
48417f2c: 85 02                 mov     2, d1
48417f2e: f1 03                 sub     d0, d3
48417f30: 2b fc                 add     -4, d3
48417f32: f1 0e                 sub     d3, d2
48417f34: 2a 04                 add     4, d2
48417f36: 1a                    exth    d2
48417f37: dd 9e 9a be 03 00 00  call    0x4c0019d5, 0, 0
48417f3e: a2                    cmp     d0, d2
48417f3f: c3 60                 ble     0x48417f9f
48417f41: 5c 74                 mov     (0x74, sp), a0
48417f43: 80 01                 mov     1, d0
48417f45: dd 7b 61 01 00 f0 24  call    0x4842e0c0, [d2,d3,a2,a3], 0x24
48417f4c: f8 93 30              movhu   d0, (0x30, sp)
48417f4f: f8 be 44              movhu   (0x44, sp), d2
48417f52: f8 bc 30              movhu   (0x30, sp), d0
48417f55: 85 02                 mov     2, d1
48417f57: 18                    exth    d0
48417f58: 1a                    exth    d2
48417f59: f1 e2                 mov     d0, a2
48417f5b: dd 7a 9a be 03 00 00  call    0x4c0019d5, 0, 0
48417f62: 81                    mov     d0, d1
48417f63: f8 bc 40              movhu   (0x40, sp), d0
48417f66: e6                    add     d1, d2
48417f67: 59 20                 mov     (0x20, sp), d1
48417f69: 18                    exth    d0
48417f6a: f1 04                 sub     d1, d0
48417f6c: 28 fc                 add     -4, d0
48417f6e: a2                    cmp     d0, d2
48417f6f: 9f 01                 mov     1, a3
48417f71: c3 49                 ble     0x48417fba
48417f73: f8 bf 44              movhu   (0x44, sp), d3
48417f76: f8 be 40              movhu   (0x40, sp), d2
48417f79: f1 d8                 mov     a2, d0
48417f7b: 85 02                 mov     2, d1
48417f7d: dd 58 9a be 03 00 00  call    0x4c0019d5, 0, 0
48417f84: 1b                    exth    d3
48417f85: 85 fc                 mov     -4, d1
48417f87: 1a                    exth    d2
48417f88: e3                    add     d0, d3
48417f89: 58 20                 mov     (0x20, sp), d0
48417f8b: f1 02                 sub     d0, d2
48417f8d: e9                    add     d2, d1
48417f8e: 8c                    mov     d3, d0
48417f8f: f1 04                 sub     d1, d0
48417f91: f8 bd 44              movhu   (0x44, sp), d1
48417f94: 28 04                 add     4, d0
48417f96: 19                    exth    d1
48417f97: 18                    exth    d0
48417f98: f1 01                 sub     d0, d1
48417f9a: f8 97 44              movhu   d1, (0x44, sp)
48417f9d: ca 1d                 bra     0x48417fba
48417f9f: f8 bc 44              movhu   (0x44, sp), d0
48417fa2: 18                    exth    d0
48417fa3: f1 08                 sub     d2, d0
48417fa5: f8 93 44              movhu   d0, (0x44, sp)
48417fa8: ca 12                 bra     0x48417fba
48417faa: 9f 01                 mov     1, a3
48417fac: 5c 74                 mov     (0x74, sp), a0
48417fae: 80 01                 mov     1, d0
48417fb0: dd 10 61 01 00 f0 24  call    0x4842e0c0, [d2,d3,a2,a3], 0x24
48417fb7: f8 93 30              movhu   d0, (0x30, sp)
48417fba: f8 b8 70              movbu   (0x70, sp), d0
48417fbd: a0 00                 cmp     0, d0
48417fbf: c8 0d                 beq     0x48417fcc
48417fc1: a0 01                 cmp     1, d0
48417fc3: c8 44                 beq     0x48418007
48417fc5: a0 02                 cmp     2, d0
48417fc7: c8 6c                 beq     0x48418033
48417fc9: cc 9a 00              jmp     0x48418063
48417fcc: 58 74                 mov     (0x74, sp), d0
48417fce: 2d ff 00              mov     0xff, d1
48417fd1: 42 10                 mov     d0, (0x10, sp)
48417fd3: 80 17                 mov     0x17, d0
48417fd5: 42 1c                 mov     d0, (0x1c, sp)
48417fd7: 5c 24                 mov     (0x24, sp), a0
48417fd9: 5d 28                 mov     (0x28, sp), a1
48417fdb: f1 dc                 mov     a3, d0
48417fdd: dd bb d8 00 00 f0 10  call    0x48425898, [d2,d3,a2,a3], 0x10
48417fe4: f8 be 44              movhu   (0x44, sp), d2
48417fe7: f8 bc 30              movhu   (0x30, sp), d0
48417fea: 1a                    exth    d2
48417feb: 18                    exth    d0
48417fec: 85 02                 mov     2, d1
48417fee: dd e7 99 be 03 00 00  call    0x4c0019d5, 0, 0
48417ff5: 28 1c                 add     0x1c, d0
48417ff7: f1 02                 sub     d0, d2
48417ff9: f8 9b 44              movhu   d2, (0x44, sp)
48417ffc: f8 bc 46              movhu   (0x46, sp), d0
48417fff: 18                    exth    d0
48418000: 28 f4                 add     -0xc, d0
48418002: f8 93 46              movhu   d0, (0x46, sp)
48418005: ca 5e                 bra     0x48418063
48418007: 58 74                 mov     (0x74, sp), d0
48418009: 2d ff 00              mov     0xff, d1
4841800c: 42 10                 mov     d0, (0x10, sp)
4841800e: 80 17                 mov     0x17, d0
48418010: 42 1c                 mov     d0, (0x1c, sp)
48418012: 5c 24                 mov     (0x24, sp), a0
48418014: 5d 28                 mov     (0x28, sp), a1
48418016: f1 dc                 mov     a3, d0
48418018: dd 67 d9 00 00 f0 34  call    0x4842597f, [d2,d3,a2,a3], 0x34
4841801f: f8 bc 3c              movhu   (0x3c, sp), d0
48418022: 18                    exth    d0
48418023: 28 e4                 add     -0x1c, d0
48418025: f8 93 44              movhu   d0, (0x44, sp)
48418028: f8 bc 46              movhu   (0x46, sp), d0
4841802b: 18                    exth    d0
4841802c: 28 f4                 add     -0xc, d0
4841802e: f8 93 46              movhu   d0, (0x46, sp)
48418031: ca 32                 bra     0x48418063
48418033: 58 74                 mov     (0x74, sp), d0
48418035: 2d ff 00              mov     0xff, d1
48418038: 42 10                 mov     d0, (0x10, sp)
4841803a: 80 17                 mov     0x17, d0
4841803c: 42 1c                 mov     d0, (0x1c, sp)
4841803e: 5c 24                 mov     (0x24, sp), a0
48418040: 5d 28                 mov     (0x28, sp), a1
48418042: f1 dc                 mov     a3, d0
48418044: dd b1 d9 00 00 f0 10  call    0x484259f5, [d2,d3,a2,a3], 0x10
4841804b: f8 bd 40              movhu   (0x40, sp), d1
4841804e: f8 bc 30              movhu   (0x30, sp), d0
48418051: 19                    exth    d1
48418052: 18                    exth    d0
48418053: f1 01                 sub     d0, d1
48418055: 29 e0                 add     -0x20, d1
48418057: f8 97 44              movhu   d1, (0x44, sp)
4841805a: f8 bc 46              movhu   (0x46, sp), d0
4841805d: 18                    exth    d0
4841805e: 28 f4                 add     -0xc, d0
48418060: f8 93 46              movhu   d0, (0x46, sp)
48418063: 58 6c                 mov     (0x6c, sp), d0
48418065: a0 00                 cmp     0, d0
48418067: c8 37                 beq     0x4841809e
48418069: 3e                    mov     sp, a2
4841806a: 22 48                 add     0x48, a2
4841806c: 5c 2c                 mov     (0x2c, sp), a0
4841806e: 99                    mov     a2, a1
4841806f: 2c c0 00              mov     0xc0, d0
48418072: cd 8a ea f0 2c        call    0x48416afc, [d2,d3,a2,a3], 0x2c
48418077: f8 bc 44              movhu   (0x44, sp), d0
4841807a: 98                    mov     a2, a0
4841807b: 18                    exth    d0
4841807c: 28 ff                 add     -1, d0
4841807e: f8 93 48              movhu   d0, (0x48, sp)
48418081: f8 bc 44              movhu   (0x44, sp), d0
48418084: 18                    exth    d0
48418085: 28 18                 add     0x18, d0
48418087: f8 93 4c              movhu   d0, (0x4c, sp)
4841808a: 80 07                 mov     7, d0
4841808c: dd a5 af 00 00 a0 18  call    0x48423031, [d2,a2], 0x18
48418093: 5c 28                 mov     (0x28, sp), a0
48418095: 58 6c                 mov     (0x6c, sp), d0
48418097: dd 3b bd 00 00 a0 18  call    0x48423dd2, [d2,a2], 0x18
4841809e: df f0 60              ret     [d2,d3,a2,a3], 0x60

WindowProc:
484180a1: cf f0                 movm    [d2,d3,a2,a3], (sp)
484180a3: f8 fe e4              add     -0x1c, sp
484180a6: 83                    mov     d0, d3
484180a7: 46 38                 mov     d1, (0x38, sp)
484180a9: fc c9 01 00 05 00     cmp     0x50001, d1
484180af: c2 05                 bge     0x484180b4
484180b1: cc 00 03              jmp     0x484183b1
484180b4: 58 38                 mov     (0x38, sp), d0
484180b6: fc c8 88 00 06 00     cmp     0x60088, d0
484180bc: c3 05                 ble     0x484180c1
484180be: cc f3 02              jmp     0x484183b1
484180c1: fc dd b0 19 5a 48     mov     0x485a19b0, a1
484180c7: 59 38                 mov     (0x38, sp), d1
484180c9: fc c1 00 00 fb ff     add     0xfffb0000, d1
484180cf: 94                    mov     a1, a0
484180d0: 80 1f                 mov     0x1f, d0
484180d2: f2 04                 and     d1, d0
484180d4: f8 c0 03              asl     3, d0
484180d7: f1 60                 add     d0, a0
484180d9: 70                    mov     (a0), d0
484180da: a4                    cmp     d1, d0
484180db: c8 18                 beq     0x484180f3
484180dd: db                    setlb
484180de: a0 00                 cmp     0, d0
484180e0: c9 05                 bne     0x484180e5
484180e2: cc cf 02              jmp     0x484183b1
484180e5: 20 08                 add     8, a0
484180e7: fc d8 b0 1a 5a 48     cmp     0x485a1ab0, a0
484180ed: c4 03                 bcs     0x484180f0
484180ef: 94                    mov     a1, a0
484180f0: 70                    mov     (a0), d0
484180f1: a4                    cmp     d1, d0
484180f2: d9                    lne
484180f3: f8 20 04              mov     (4, a0), a0
484180f6: f0 f4                 jmp     (a0)
484180f8: 8c                    mov     d3, d0
484180f9: dd 21 58 01 00 00 00  call    0x4842d91a, 0, 0
48418100: 43 14                 mov     a0, (0x14, sp)
48418102: 5e 3c                 mov     (0x3c, sp), a2
48418104: ba 00                 cmp     0, a2
48418106: c8 0e                 beq     0x48418114
48418108: ba 05                 cmp     5, a2
4841810a: c8 0a                 beq     0x48418114
4841810c: ba 03                 cmp     3, a2
4841810e: c8 06                 beq     0x48418114
48418110: ba 04                 cmp     4, a2
48418112: c9 75                 bne     0x48418187
48418114: ba 04                 cmp     4, a2
48418116: c8 20                 beq     0x48418136
48418118: 5f 14                 mov     (0x14, sp), a3
4841811a: 23 24                 add     0x24, a3
4841811c: f0 03                 mov     (a3), a0
4841811e: 70                    mov     (a0), d0
4841811f: a0 ff                 cmp     -1, d0
48418121: c8 20                 beq     0x48418141
48418123: 00                    clr     d0
48418124: 42 10                 mov     d0, (0x10, sp)
48418126: 8c                    mov     d3, d0
48418127: fc cd 02 00 05 00     mov     0x00050002, d1
4841812d: dd 60 12 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418134: ca 0d                 bra     0x48418141
48418136: 5f 14                 mov     (0x14, sp), a3
48418138: 23 24                 add     0x24, a3
4841813a: f0 03                 mov     (a3), a0
4841813c: 70                    mov     (a0), d0
4841813d: a0 ff                 cmp     -1, d0
4841813f: c9 48                 bne     0x48418187
48418141: dd fd 12 01 00 00 10  call    0x4842943e, 0, 0x10
48418148: 82                    mov     d0, d2
48418149: 00                    clr     d0
4841814a: 42 10                 mov     d0, (0x10, sp)
4841814c: 88                    mov     d2, d0
4841814d: fc cd 48 00 06 00     mov     0x00060048, d1
48418153: dd 3a 12 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841815a: a0 ff                 cmp     -1, d0
4841815c: c8 18                 beq     0x48418174
4841815e: 82                    mov     d0, d2
4841815f: 00                    clr     d0
48418160: 42 10                 mov     d0, (0x10, sp)
48418162: 88                    mov     d2, d0
48418163: fc cd 48 00 06 00     mov     0x00060048, d1
48418169: dd 24 12 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418170: a0 ff                 cmp     -1, d0
48418172: c9 ec                 bne     0x4841815e
48418174: 88                    mov     d2, d0
48418175: 4e 10                 mov     d3, (0x10, sp)
48418177: fc cd 46 00 06 00     mov     0x00060046, d1
4841817d: dd 10 12 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418184: f0 03                 mov     (a3), a0
48418186: 68                    mov     d2, (a0)
48418187: 00                    clr     d0
48418188: cd 8f f4 80 18        call    0x48417617, [d2], 0x18
4841818d: 4b 10                 mov     a2, (0x10, sp)
4841818f: 59 38                 mov     (0x38, sp), d1
48418191: 8c                    mov     d3, d0
48418192: dd d7 13 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418199: ba 00                 cmp     0, a2
4841819b: c8 27                 beq     0x484181c2
4841819d: ba 05                 cmp     5, a2
4841819f: c8 23                 beq     0x484181c2
484181a1: ba 03                 cmp     3, a2
484181a3: c8 1f                 beq     0x484181c2
484181a5: ba 04                 cmp     4, a2
484181a7: c9 1b                 bne     0x484181c2
484181a9: 5d 14                 mov     (0x14, sp), a1
484181ab: 21 28                 add     0x28, a1
484181ad: f0 01                 mov     (a1), a0
484181af: 70                    mov     (a0), d0
484181b0: a0 ff                 cmp     -1, d0
484181b2: c8 10                 beq     0x484181c2
484181b4: f0 01                 mov     (a1), a0
484181b6: 70                    mov     (a0), d0
484181b7: 4b 10                 mov     a2, (0x10, sp)
484181b9: 59 38                 mov     (0x38, sp), d1
484181bb: dd d2 11 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484181c2: 00                    clr     d0
484181c3: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
484181c6: 5e 3c                 mov     (0x3c, sp), a2
484181c8: 8c                    mov     d3, d0
484181c9: 4b 10                 mov     a2, (0x10, sp)
484181cb: 59 38                 mov     (0x38, sp), d1
484181cd: dd 9c 13 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484181d4: 8c                    mov     d3, d0
484181d5: dd 45 57 01 00 00 00  call    0x4842d91a, 0, 0
484181dc: 93                    mov     a0, a3
484181dd: ba 00                 cmp     0, a2
484181df: c8 11                 beq     0x484181f0
484181e1: ba 05                 cmp     5, a2
484181e3: c8 0d                 beq     0x484181f0
484181e5: ba 04                 cmp     4, a2
484181e7: c8 11                 beq     0x484181f8
484181e9: ba 03                 cmp     3, a2
484181eb: c8 6a                 beq     0x48418255
484181ed: cc 7d 00              jmp     0x4841826a
484181f0: f8 23 24              mov     (0x24, a3), a0
484181f3: 70                    mov     (a0), d0
484181f4: a0 ff                 cmp     -1, d0
484181f6: c8 74                 beq     0x4841826a
484181f8: 9a 24                 mov     0x24, a2
484181fa: f1 7e                 add     a3, a2
484181fc: f0 02                 mov     (a2), a0
484181fe: 70                    mov     (a0), d0
484181ff: a0 ff                 cmp     -1, d0
48418201: c8 18                 beq     0x48418219
48418203: f8 23 28              mov     (0x28, a3), a0
48418206: 74                    mov     (a0), d1
48418207: f0 02                 mov     (a2), a0
48418209: 70                    mov     (a0), d0
4841820a: 46 10                 mov     d1, (0x10, sp)
4841820c: fc cd 46 00 06 00     mov     0x00060046, d1
48418212: dd 7b 11 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418219: 23 28                 add     0x28, a3
4841821b: f0 03                 mov     (a3), a0
4841821d: 70                    mov     (a0), d0
4841821e: a0 ff                 cmp     -1, d0
48418220: c8 17                 beq     0x48418237
48418222: f0 02                 mov     (a2), a0
48418224: 74                    mov     (a0), d1
48418225: f0 03                 mov     (a3), a0
48418227: 70                    mov     (a0), d0
48418228: 46 10                 mov     d1, (0x10, sp)
4841822a: fc cd 45 00 06 00     mov     0x00060045, d1
48418230: dd 5d 11 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418237: dd 07 12 01 00 00 10  call    0x4842943e, 0, 0x10
4841823e: ac                    cmp     d3, d0
4841823f: c9 0c                 bne     0x4841824b
48418241: f0 02                 mov     (a2), a0
48418243: 70                    mov     (a0), d0
48418244: dd 21 12 01 00 40 14  call    0x48429465, [d3], 0x14
4841824b: f0 06                 mov     (a2), a1
4841824d: 80 ff                 mov     -1, d0
4841824f: 61                    mov     d0, (a1)
48418250: f0 03                 mov     (a3), a0
48418252: 60                    mov     d0, (a0)
48418253: ca 17                 bra     0x4841826a
48418255: dd e9 11 01 00 00 10  call    0x4842943e, 0, 0x10
4841825c: ac                    cmp     d3, d0
4841825d: c9 0d                 bne     0x4841826a
4841825f: f8 23 24              mov     (0x24, a3), a0
48418262: 70                    mov     (a0), d0
48418263: dd 02 12 01 00 40 14  call    0x48429465, [d3], 0x14
4841826a: 00                    clr     d0
4841826b: cd ac f3 80 18        call    0x48417617, [d2], 0x18
48418270: 00                    clr     d0
48418271: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
48418274: 8c                    mov     d3, d0
48418275: dd a5 56 01 00 00 00  call    0x4842d91a, 0, 0
4841827c: f8 24 24              mov     (0x24, a0), a1
4841827f: 5c 3c                 mov     (0x3c, sp), a0
48418281: 00                    clr     d0
48418282: f0 11                 mov     a0, (a1)
48418284: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
48418287: 8c                    mov     d3, d0
48418288: dd 92 56 01 00 00 00  call    0x4842d91a, 0, 0
4841828f: f8 20 24              mov     (0x24, a0), a0
48418292: 70                    mov     (a0), d0
48418293: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
48418296: 8c                    mov     d3, d0
48418297: dd 83 56 01 00 00 00  call    0x4842d91a, 0, 0
4841829e: f8 24 28              mov     (0x28, a0), a1
484182a1: 5c 3c                 mov     (0x3c, sp), a0
484182a3: 00                    clr     d0
484182a4: f0 11                 mov     a0, (a1)
484182a6: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
484182a9: 8c                    mov     d3, d0
484182aa: dd 70 56 01 00 00 00  call    0x4842d91a, 0, 0
484182b1: f8 20 28              mov     (0x28, a0), a0
484182b4: 70                    mov     (a0), d0
484182b5: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
484182b8: 8c                    mov     d3, d0
484182b9: dd 61 56 01 00 00 00  call    0x4842d91a, 0, 0
484182c0: f8 20 24              mov     (0x24, a0), a0
484182c3: 70                    mov     (a0), d0
484182c4: a0 ff                 cmp     -1, d0
484182c6: c9 06                 bne     0x484182cc
484182c8: 00                    clr     d0
484182c9: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
484182cc: 80 01                 mov     1, d0
484182ce: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
484182d1: 8c                    mov     d3, d0
484182d2: dd 48 56 01 00 00 00  call    0x4842d91a, 0, 0
484182d9: 92                    mov     a0, a2
484182da: dd 64 11 01 00 00 10  call    0x4842943e, 0, 0x10
484182e1: 42 14                 mov     d0, (0x14, sp)
484182e3: 22 24                 add     0x24, a2
484182e5: f0 02                 mov     (a2), a0
484182e7: 78                    mov     (a0), d2
484182e8: f0 02                 mov     (a2), a0
484182ea: 70                    mov     (a0), d0
484182eb: dd 7a 11 01 00 40 14  call    0x48429465, [d3], 0x14
484182f2: 5f 3c                 mov     (0x3c, sp), a3
484182f4: 80 ff                 mov     -1, d0
484182f6: 4f 10                 mov     a3, (0x10, sp)
484182f8: 59 38                 mov     (0x38, sp), d1
484182fa: dd 93 10 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418301: dd 3d 11 01 00 00 10  call    0x4842943e, 0, 0x10
48418308: a2                    cmp     d0, d2
48418309: c9 12                 bne     0x4841831b
4841830b: f0 02                 mov     (a2), a0
4841830d: 70                    mov     (a0), d0
4841830e: a0 ff                 cmp     -1, d0
48418310: c8 0b                 beq     0x4841831b
48418312: 58 14                 mov     (0x14, sp), d0
48418314: dd 51 11 01 00 40 14  call    0x48429465, [d3], 0x14
4841831b: 4f 10                 mov     a3, (0x10, sp)
4841831d: 59 38                 mov     (0x38, sp), d1
4841831f: 8c                    mov     d3, d0
48418320: dd 49 12 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418327: 00                    clr     d0
48418328: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
4841832b: 5c 3c                 mov     (0x3c, sp), a0
4841832d: 8c                    mov     d3, d0
4841832e: 43 10                 mov     a0, (0x10, sp)
48418330: 59 38                 mov     (0x38, sp), d1
48418332: dd 37 12 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418339: 00                    clr     d0
4841833a: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
4841833d: 5e 3c                 mov     (0x3c, sp), a2
4841833f: 8c                    mov     d3, d0
48418340: 4b 10                 mov     a2, (0x10, sp)
48418342: 59 38                 mov     (0x38, sp), d1
48418344: dd 25 12 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841834b: 8c                    mov     d3, d0
4841834c: dd ce 55 01 00 00 00  call    0x4842d91a, 0, 0
48418353: 9f 24                 mov     0x24, a3
48418355: f1 73                 add     a0, a3
48418357: f0 07                 mov     (a3), a1
48418359: 71                    mov     (a1), d0
4841835a: a0 ff                 cmp     -1, d0
4841835c: c9 06                 bne     0x48418362
4841835e: 00                    clr     d0
4841835f: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
48418362: ba 15                 cmp     0x15, a2
48418364: c8 06                 beq     0x4841836a
48418366: ba 95                 cmp     0x95, a2
48418368: c9 06                 bne     0x4841836e
4841836a: 00                    clr     d0
4841836b: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
4841836e: f8 00 20              mov     (0x20, a0), d0
48418371: a0 00                 cmp     0, d0
48418373: c9 3a                 bne     0x484183ad
48418375: dd c9 10 01 00 00 10  call    0x4842943e, 0, 0x10
4841837c: f0 03                 mov     (a3), a0
4841837e: 83                    mov     d0, d3
4841837f: 78                    mov     (a0), d2
48418380: 88                    mov     d2, d0
48418381: dd e4 10 01 00 40 14  call    0x48429465, [d3], 0x14
48418388: 4b 10                 mov     a2, (0x10, sp)
4841838a: 88                    mov     d2, d0
4841838b: 59 38                 mov     (0x38, sp), d1
4841838d: dd 00 10 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418394: dd aa 10 01 00 00 10  call    0x4842943e, 0, 0x10
4841839b: a2                    cmp     d0, d2
4841839c: c9 11                 bne     0x484183ad
4841839e: f0 03                 mov     (a3), a0
484183a0: 70                    mov     (a0), d0
484183a1: a0 ff                 cmp     -1, d0
484183a3: c8 0a                 beq     0x484183ad
484183a5: 8c                    mov     d3, d0
484183a6: dd bf 10 01 00 40 14  call    0x48429465, [d3], 0x14
484183ad: 00                    clr     d0
484183ae: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
484183b1: 58 38                 mov     (0x38, sp), d0
484183b3: f8 c4 10              lsr     16, d0
484183b6: f8 e0 0f              and     0x0f, d0
484183b9: 1c                    exthu   d0
484183ba: a0 06                 cmp     6, d0
484183bc: c9 13                 bne     0x484183cf
484183be: 5c 3c                 mov     (0x3c, sp), a0
484183c0: 8c                    mov     d3, d0
484183c1: 43 10                 mov     a0, (0x10, sp)
484183c3: 59 38                 mov     (0x38, sp), d1
484183c5: dd a4 11 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484183cc: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
484183cf: 5f 3c                 mov     (0x3c, sp), a3
484183d1: 8c                    mov     d3, d0
484183d2: 4f 10                 mov     a3, (0x10, sp)
484183d4: 59 38                 mov     (0x38, sp), d1
484183d6: dd 93 11 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484183dd: 42 18                 mov     d0, (0x18, sp)
484183df: 8c                    mov     d3, d0
484183e0: dd 3a 55 01 00 00 00  call    0x4842d91a, 0, 0
484183e7: 92                    mov     a0, a2
484183e8: 22 24                 add     0x24, a2
484183ea: f0 02                 mov     (a2), a0
484183ec: 70                    mov     (a0), d0
484183ed: a0 ff                 cmp     -1, d0
484183ef: c9 07                 bne     0x484183f6
484183f1: 58 18                 mov     (0x18, sp), d0
484183f3: df f0 2c              ret     [d2,d3,a2,a3], 0x2c
484183f6: dd 19 12 01 00 00 10  call    0x4842960f, 0, 0x10
484183fd: ac                    cmp     d3, d0
484183fe: c9 6b                 bne     0x48418469
48418400: dd 34 12 01 00 00 10  call    0x48429634, 0, 0x10
48418407: 59 38                 mov     (0x38, sp), d1
48418409: a4                    cmp     d1, d0
4841840a: c9 5f                 bne     0x48418469
4841840c: dd 4d 12 01 00 00 10  call    0x48429659, 0, 0x10
48418413: f1 9c                 cmp     a3, d0
48418415: c9 54                 bne     0x48418469
48418417: dd 27 10 01 00 00 10  call    0x4842943e, 0, 0x10
4841841e: 42 14                 mov     d0, (0x14, sp)
48418420: f0 02                 mov     (a2), a0
48418422: 78                    mov     (a0), d2
48418423: 88                    mov     d2, d0
48418424: dd 41 10 01 00 40 14  call    0x48429465, [d3], 0x14
4841842b: dd e4 11 01 00 00 10  call    0x4842960f, 0, 0x10
48418432: 83                    mov     d0, d3
48418433: 88                    mov     d2, d0
48418434: dd 4c 12 01 00 40 14  call    0x48429680, [d3], 0x14
4841843b: 4f 10                 mov     a3, (0x10, sp)
4841843d: 88                    mov     d2, d0
4841843e: 59 38                 mov     (0x38, sp), d1
48418440: dd 4d 0f 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418447: dd f7 0f 01 00 00 10  call    0x4842943e, 0, 0x10
4841844e: a2                    cmp     d0, d2
4841844f: c9 1a                 bne     0x48418469
48418451: f0 02                 mov     (a2), a0
48418453: 70                    mov     (a0), d0
48418454: a0 ff                 cmp     -1, d0
48418456: c8 13                 beq     0x48418469
48418458: 8c                    mov     d3, d0
48418459: dd 27 12 01 00 40 14  call    0x48429680, [d3], 0x14
48418460: 58 14                 mov     (0x14, sp), d0
48418462: dd 03 10 01 00 40 14  call    0x48429465, [d3], 0x14
48418469: 58 18                 mov     (0x18, sp), d0
4841846b: df f0 2c              ret     [d2,d3,a2,a3], 0x2c

GetDefaultWindowID:
4841846e: 80 08     mov     8, d0
48418470: de 00 00  retf    0, 0

VwStrBoxProc:
48418473: cf 80                 movm    [d2], (sp)
48418475: f8 fe ec              add     -0x14, sp
48418478: 82                    mov     d0, d2
48418479: fc c9 b2 00 06 00     cmp     0x600b2, d1
4841847f: c8 0c                 beq     0x4841848b
48418481: fc c9 3a 00 06 00     cmp     0x6003a, d1
48418487: c8 23                 beq     0x484184aa
48418489: ca 38                 bra     0x484184c1
4841848b: 5c 28                 mov     (0x28, sp), a0
4841848d: 43 10                 mov     a0, (0x10, sp)
4841848f: dd da 10 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418496: 00                    clr     d0
48418497: 42 10                 mov     d0, (0x10, sp)
48418499: fc cd b4 00 06 00     mov     0x000600b4, d1
4841849f: 88                    mov     d2, d0
484184a0: dd ed 0e 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484184a7: 00                    clr     d0
484184a8: ca 24                 bra     0x484184cc
484184aa: dd 70 54 01 00 00 00  call    0x4842d91a, 0, 0
484184b1: 91                    mov     a0, a1
484184b2: 5c 28                 mov     (0x28, sp), a0
484184b4: f8 25 28              mov     (0x28, a1), a1
484184b7: dd 9a ab be 03 20 04  call    0x4c003051, [a2], 4
484184be: 00                    clr     d0
484184bf: ca 0d                 bra     0x484184cc
484184c1: 5c 28                 mov     (0x28, sp), a0
484184c3: 43 10                 mov     a0, (0x10, sp)
484184c5: dd a4 10 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484184cc: df 80 18              ret     [d2], 0x18

VwLabelProc:
484184cf: cf f0                 movm    [d2,d3,a2,a3], (sp)
484184d1: f8 fe d0              add     -0x30, sp
484184d4: 82                    mov     d0, d2
484184d5: fc c9 b2 00 06 00     cmp     0x600b2, d1
484184db: c8 26                 beq     0x48418501
484184dd: fc c9 af 00 06 00     cmp     0x600af, d1
484184e3: c9 05                 bne     0x484184e8
484184e5: cc 8d 00              jmp     0x48418572
484184e8: fc c9 ae 00 06 00     cmp     0x600ae, d1
484184ee: c9 05                 bne     0x484184f3
484184f0: cc 8e 00              jmp     0x4841857e
484184f3: fc c9 ee 00 06 00     cmp     0x600ee, d1
484184f9: c9 05                 bne     0x484184fe
484184fb: cc 90 00              jmp     0x4841858b
484184fe: cc a6 00              jmp     0x484185a4
48418501: 5c 50                 mov     (0x50, sp), a0
48418503: 3e                    mov     sp, a2
48418504: 43 10                 mov     a0, (0x10, sp)
48418506: dd 63 10 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841850d: 88                    mov     d2, d0
4841850e: dd 0c 54 01 00 00 00  call    0x4842d91a, 0, 0
48418515: 43 20                 mov     a0, (0x20, sp)
48418517: 22 24                 add     0x24, a2
48418519: 88                    mov     d2, d0
4841851a: 98                    mov     a2, a0
4841851b: cd d7 e8 00 14        call    0x48416df2, 0, 0x14
48418520: f8 bc 24              movhu   (0x24, sp), d0
48418523: fc cd af 00 06 00     mov     0x000600af, d1
48418529: 18                    exth    d0
4841852a: 28 02                 add     2, d0
4841852c: f8 93 2c              movhu   d0, (0x2c, sp)
4841852f: f8 bc 26              movhu   (0x26, sp), d0
48418532: 3f                    mov     sp, a3
48418533: 18                    exth    d0
48418534: 40                    inc     d0
48418535: f8 93 2e              movhu   d0, (0x2e, sp)
48418538: 00                    clr     d0
48418539: 42 10                 mov     d0, (0x10, sp)
4841853b: 88                    mov     d2, d0
4841853c: dd 51 0e 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418543: fc cd ae 00 06 00     mov     0x000600ae, d1
48418549: 83                    mov     d0, d3
4841854a: 00                    clr     d0
4841854b: 42 10                 mov     d0, (0x10, sp)
4841854d: 88                    mov     d2, d0
4841854e: dd 3f 0e 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418555: 5c 20                 mov     (0x20, sp), a0
48418557: 23 2c                 add     0x2c, a3
48418559: f8 20 18              mov     (0x18, a0), a0
4841855c: 81                    mov     d0, d1
4841855d: 43 10                 mov     a0, (0x10, sp)
4841855f: 19                    exth    d1
48418560: 9d                    mov     a3, a1
48418561: 98                    mov     a2, a0
48418562: 2c f7 00              mov     0xf7, d0
48418565: 42 1c                 mov     d0, (0x1c, sp)
48418567: 8c                    mov     d3, d0
48418568: dd 30 ce 00 00 f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30
4841856f: 00                    clr     d0
48418570: ca 3f                 bra     0x484185af
48418572: dd a8 53 01 00 00 00  call    0x4842d91a, 0, 0
48418579: f8 00 1c              mov     (0x1c, a0), d0
4841857c: ca 33                 bra     0x484185af
4841857e: dd 9c 53 01 00 00 00  call    0x4842d91a, 0, 0
48418585: f8 60 20              movhu   (0x20, a0), d0
48418588: 18                    exth    d0
48418589: ca 26                 bra     0x484185af
4841858b: dd 8f 53 01 00 00 00  call    0x4842d91a, 0, 0
48418592: f8 60 14              movhu   (0x14, a0), d0
48418595: 18                    exth    d0
48418596: fa c8 d3 00           cmp     0xd3, d0
4841859a: c3 05                 ble     0x4841859f
4841859c: 00                    clr     d0
4841859d: ca 12                 bra     0x484185af
4841859f: 2c ff 00              mov     0xff, d0
484185a2: ca 0d                 bra     0x484185af
484185a4: 5c 50                 mov     (0x50, sp), a0
484185a6: 43 10                 mov     a0, (0x10, sp)
484185a8: dd c1 0f 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484185af: df f0 40              ret     [d2,d3,a2,a3], 0x40

VwEditSwLabelProc:
484185b2: f8 fe ec              add     -0x14, sp
484185b5: fc c9 ee 00 06 00     cmp     0x600ee, d1
484185bb: c9 0e                 bne     0x484185c9
484185bd: dd 5d 53 01 00 00 00  call    0x4842d91a, 0, 0
484185c4: f8 60 24              movhu   (0x24, a0), d0
484185c7: ca 0d                 bra     0x484185d4
484185c9: 5c 24                 mov     (0x24, sp), a0
484185cb: 43 10                 mov     a0, (0x10, sp)
484185cd: dd 9c 0f 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484185d4: df 00 14              ret     0, 0x14

VwBitmapProc:
484185d7: cf a0                 movm    [d2,a2], (sp)
484185d9: f8 fe e8              add     -0x18, sp
484185dc: 82                    mov     d0, d2
484185dd: fc c9 b2 00 06 00     cmp     0x600b2, d1
484185e3: c9 34                 bne     0x48418617
484185e5: 5c 30                 mov     (0x30, sp), a0
484185e7: 9a 0e                 mov     0xe, a2
484185e9: 43 10                 mov     a0, (0x10, sp)
484185eb: dd 7e 0f 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484185f2: 88                    mov     d2, d0
484185f3: dd 27 53 01 00 00 00  call    0x4842d91a, 0, 0
484185fa: f1 72                 add     a0, a2
484185fc: f0 62                 movhu   (a2), d0
484185fe: f8 93 14              movhu   d0, (0x14, sp)
48418601: f8 62 02              movhu   (2, a2), d0
48418604: f8 93 16              movhu   d0, (0x16, sp)
48418607: f8 00 18              mov     (0x18, a0), d0
4841860a: 3c                    mov     sp, a0
4841860b: 20 14                 add     0x14, a0
4841860d: dd 4e b5 00 00 a0 18  call    0x48423b5b, [d2,a2], 0x18
48418614: 00                    clr     d0
48418615: ca 0d                 bra     0x48418622
48418617: 5c 30                 mov     (0x30, sp), a0
48418619: 43 10                 mov     a0, (0x10, sp)
4841861b: dd 4e 0f 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418622: df a0 20              ret     [d2,a2], 0x20

VwUserBitmapProc:
48418625: cf f0                 movm    [d2,d3,a2,a3], (sp)
48418627: f8 fe d4              add     -0x2c, sp
4841862a: 82                    mov     d0, d2
4841862b: fc c9 b2 00 06 00     cmp     0x600b2, d1
48418631: c8 05                 beq     0x48418636
48418633: cc 23 01              jmp     0x48418756
48418636: 5c 4c                 mov     (0x4c, sp), a0
48418638: 9a 18                 mov     0x18, a2
4841863a: 43 10                 mov     a0, (0x10, sp)
4841863c: dd 2d 0f 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418643: 88                    mov     d2, d0
48418644: dd d6 52 01 00 00 00  call    0x4842d91a, 0, 0
4841864b: f1 d2                 mov     a0, d2
4841864d: 90 0e                 mov     0xe, a0
4841864f: f1 68                 add     d2, a0
48418651: f0 60                 movhu   (a0), d0
48418653: 3d                    mov     sp, a1
48418654: f1 d5                 mov     a1, d1
48418656: 29 28                 add     0x28, d1
48418658: 46 20                 mov     d1, (0x20, sp)
4841865a: f8 93 28              movhu   d0, (0x28, sp)
4841865d: f8 60 02              movhu   (2, a0), d0
48418660: f1 6a                 add     d2, a2
48418662: f8 93 2a              movhu   d0, (0x2a, sp)
48418665: 72                    mov     (a2), d0
48418666: 04                    clr     d1
48418667: 46 10                 mov     d1, (0x10, sp)
48418669: fc cd 92 00 06 00     mov     0x00060092, d1
4841866f: dd 11 26 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48418676: f1 e3                 mov     d0, a3
48418678: bf 00                 cmp     0, a3
4841867a: c9 05                 bne     0x4841867f
4841867c: cc cd 00              jmp     0x48418749
4841867f: 72                    mov     (a2), d0
48418680: 04                    clr     d1
48418681: 46 10                 mov     d1, (0x10, sp)
48418683: fc cd 93 00 06 00     mov     0x00060093, d1
48418689: dd f7 25 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48418690: f8 93 24              movhu   d0, (0x24, sp)
48418693: 72                    mov     (a2), d0
48418694: 04                    clr     d1
48418695: 46 10                 mov     d1, (0x10, sp)
48418697: fc cd 94 00 06 00     mov     0x00060094, d1
4841869d: dd e3 25 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
484186a4: 82                    mov     d0, d2
484186a5: 72                    mov     (a2), d0
484186a6: 04                    clr     d1
484186a7: 46 10                 mov     d1, (0x10, sp)
484186a9: fc cd 95 00 06 00     mov     0x00060095, d1
484186af: dd d1 25 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
484186b6: 83                    mov     d0, d3
484186b7: 72                    mov     (a2), d0
484186b8: 04                    clr     d1
484186b9: 46 10                 mov     d1, (0x10, sp)
484186bb: fc cd ad 00 06 00     mov     0x000600ad, d1
484186c1: dd bf 25 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
484186c8: 18                    exth    d0
484186c9: a0 01                 cmp     1, d0
484186cb: c8 08                 beq     0x484186d3
484186cd: a0 08                 cmp     8, d0
484186cf: c8 1e                 beq     0x484186ed
484186d1: ca 46                 bra     0x48418717
484186d3: 2c ff 00              mov     0xff, d0
484186d6: 42 18                 mov     d0, (0x18, sp)
484186d8: 9d                    mov     a3, a1
484186d9: 00                    clr     d0
484186da: 42 1c                 mov     d0, (0x1c, sp)
484186dc: f8 bc 24              movhu   (0x24, sp), d0
484186df: 5c 20                 mov     (0x20, sp), a0
484186e1: 18                    exth    d0
484186e2: 1a                    exth    d2
484186e3: 89                    mov     d2, d1
484186e4: dd ff c1 00 00 f0 30  call    0x484248e3, [d2,d3,a2,a3], 0x30
484186eb: ca 68                 bra     0x48418753
484186ed: af 00                 cmp     0, d3
484186ef: c8 16                 beq     0x48418705
484186f1: 4e 18                 mov     d3, (0x18, sp)
484186f3: f8 bc 24              movhu   (0x24, sp), d0
484186f6: 5c 20                 mov     (0x20, sp), a0
484186f8: 18                    exth    d0
484186f9: 1a                    exth    d2
484186fa: 89                    mov     d2, d1
484186fb: 9d                    mov     a3, a1
484186fc: dd 8d c0 00 00 f0 2c  call    0x48424789, [d2,d3,a2,a3], 0x2c
48418703: ca 50                 bra     0x48418753
48418705: f8 bc 24              movhu   (0x24, sp), d0
48418708: 5c 20                 mov     (0x20, sp), a0
4841870a: 18                    exth    d0
4841870b: 1a                    exth    d2
4841870c: 89                    mov     d2, d1
4841870d: 9d                    mov     a3, a1
4841870e: dd 95 bb 00 00 f0 28  call    0x484242a3, [d2,d3,a2,a3], 0x28
48418715: ca 3e                 bra     0x48418753
48418717: af 00                 cmp     0, d3
48418719: c8 16                 beq     0x4841872f
4841871b: 4e 18                 mov     d3, (0x18, sp)
4841871d: f8 bc 24              movhu   (0x24, sp), d0
48418720: 5c 20                 mov     (0x20, sp), a0
48418722: 18                    exth    d0
48418723: 1a                    exth    d2
48418724: 89                    mov     d2, d1
48418725: 9d                    mov     a3, a1
48418726: dd 9b be 00 00 f0 2c  call    0x484245c1, [d2,d3,a2,a3], 0x2c
4841872d: ca 26                 bra     0x48418753
4841872f: fc cc 84 e4 59 48     mov     0x4859e484, d0
48418735: 42 18                 mov     d0, (0x18, sp)
48418737: f8 bc 24              movhu   (0x24, sp), d0
4841873a: 5c 20                 mov     (0x20, sp), a0
4841873c: 18                    exth    d0
4841873d: 1a                    exth    d2
4841873e: 89                    mov     d2, d1
4841873f: 9d                    mov     a3, a1
48418740: dd 81 be 00 00 f0 2c  call    0x484245c1, [d2,d3,a2,a3], 0x2c
48418747: ca 0c                 bra     0x48418753
48418749: 5c 20                 mov     (0x20, sp), a0
4841874b: 00                    clr     d0
4841874c: dd 0f b4 00 00 a0 18  call    0x48423b5b, [d2,a2], 0x18
48418753: 00                    clr     d0
48418754: ca 0d                 bra     0x48418761
48418756: 5c 4c                 mov     (0x4c, sp), a0
48418758: 43 10                 mov     a0, (0x10, sp)
4841875a: dd 0f 0e 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418761: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
48418764: fc c9 92 00 06 00     cmp     0x60092, d1
4841876a: c8 24                 beq     0x4841878e
4841876c: fc c9 93 00 06 00     cmp     0x60093, d1
48418772: c8 24                 beq     0x48418796
48418774: fc c9 94 00 06 00     cmp     0x60094, d1
4841877a: c8 20                 beq     0x4841879a
4841877c: fc c9 ad 00 06 00     cmp     0x600ad, d1
48418782: c8 1c                 beq     0x4841879e
48418784: fc c9 00 00 05 00     cmp     0x50000, d1
4841878a: c8 18                 beq     0x484187a2
4841878c: ca 1c                 bra     0x484187a8
4841878e: fc cc c4 e4 59 48     mov     0x4859e4c4, d0
48418794: ca 15                 bra     0x484187a9
48418796: 80 18                 mov     0x18, d0
48418798: ca 11                 bra     0x484187a9
4841879a: 80 18                 mov     0x18, d0
4841879c: ca 0d                 bra     0x484187a9
4841879e: 80 08                 mov     8, d0
484187a0: ca 09                 bra     0x484187a9
484187a2: 5c 10                 mov     (0x10, sp), a0
484187a4: f1 50                 add     a0, d0
484187a6: ca 03                 bra     0x484187a9
484187a8: 00                    clr     d0
484187a9: de 00 00              retf    0, 0

VwUserBitmapByNameProc:
484187ac: cf 80                 movm    [d2], (sp)
484187ae: f8 fe e8              add     -0x18, sp
484187b1: 82                    mov     d0, d2
484187b2: fc c9 01 00 05 00     cmp     0x50001, d1
484187b8: c8 0c                 beq     0x484187c4
484187ba: fc c9 b2 00 06 00     cmp     0x600b2, d1
484187c0: c8 12                 beq     0x484187d2
484187c2: ca 3e                 bra     0x48418800
484187c4: 5c 2c                 mov     (0x2c, sp), a0
484187c6: 43 10                 mov     a0, (0x10, sp)
484187c8: dd a1 0d 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484187cf: 00                    clr     d0
484187d0: ca 3b                 bra     0x4841880b
484187d2: 5c 2c                 mov     (0x2c, sp), a0
484187d4: 43 10                 mov     a0, (0x10, sp)
484187d6: dd 93 0d 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484187dd: 88                    mov     d2, d0
484187de: dd 3c 51 01 00 00 00  call    0x4842d91a, 0, 0
484187e5: 20 0e                 add     0xe, a0
484187e7: f0 60                 movhu   (a0), d0
484187e9: f8 93 14              movhu   d0, (0x14, sp)
484187ec: f8 60 02              movhu   (2, a0), d0
484187ef: 3c                    mov     sp, a0
484187f0: f8 93 16              movhu   d0, (0x16, sp)
484187f3: 20 14                 add     0x14, a0
484187f5: 00                    clr     d0
484187f6: dd 65 b3 00 00 a0 18  call    0x48423b5b, [d2,a2], 0x18
484187fd: 00                    clr     d0
484187fe: ca 0d                 bra     0x4841880b
48418800: 5c 2c                 mov     (0x2c, sp), a0
48418802: 43 10                 mov     a0, (0x10, sp)
48418804: dd 65 0d 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841880b: df 80 1c              ret     [d2], 0x1c

VwBitmapFileProc:
4841880e: cf b0                 movm    [d2,a2,a3], (sp)
48418810: fa fe 98 fb           add     -0x468, sp
48418814: 82                    mov     d0, d2
48418815: fc c9 b2 00 06 00     cmp     0x600b2, d1
4841881b: c8 10                 beq     0x4841882b
4841881d: fc c9 e5 00 06 00     cmp     0x600e5, d1
48418823: c9 05                 bne     0x48418828
48418825: cc 92 00              jmp     0x484188b7
48418828: cc 86 01              jmp     0x484189ae
4841882b: fa b0 84 04           mov     (0x484, sp), a0
4841882f: 43 10                 mov     a0, (0x10, sp)
48418831: dd 38 0d 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418838: 88                    mov     d2, d0
48418839: dd e1 50 01 00 00 00  call    0x4842d91a, 0, 0
48418840: 92                    mov     a0, a2
48418841: 22 18                 add     0x18, a2
48418843: 72                    mov     (a2), d0
48418844: 04                    clr     d1
48418845: 46 10                 mov     d1, (0x10, sp)
48418847: fc cd 92 00 06 00     mov     0x00060092, d1
4841884d: dd 33 24 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48418854: f1 e3                 mov     d0, a3
48418856: bf 00                 cmp     0, a3
48418858: c8 24                 beq     0x4841887c
4841885a: 3c                    mov     sp, a0
4841885b: 20 24                 add     0x24, a0
4841885d: 88                    mov     d2, d0
4841885e: cd 94 e5 00 14        call    0x48416df2, 0, 0x14
48418863: f8 bc 24              movhu   (0x24, sp), d0
48418866: 3c                    mov     sp, a0
48418867: f8 93 2c              movhu   d0, (0x2c, sp)
4841886a: f8 bc 26              movhu   (0x26, sp), d0
4841886d: 20 2c                 add     0x2c, a0
4841886f: f8 93 2e              movhu   d0, (0x2e, sp)
48418872: 9d                    mov     a3, a1
48418873: dd 31 c2 00 00 30 18  call    0x48424aa4, [a2,a3], 0x18
4841887a: ca 39                 bra     0x484188b3
4841887c: 72                    mov     (a2), d0
4841887d: 04                    clr     d1
4841887e: 46 10                 mov     d1, (0x10, sp)
48418880: fc cd e6 00 06 00     mov     0x000600e6, d1
48418886: dd fa 23 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841888d: f1 e2                 mov     d0, a2
4841888f: ba 00                 cmp     0, a2
48418891: c8 22                 beq     0x484188b3
48418893: 3c                    mov     sp, a0
48418894: 20 24                 add     0x24, a0
48418896: 88                    mov     d2, d0
48418897: cd 5b e5 00 14        call    0x48416df2, 0, 0x14
4841889c: f8 bc 24              movhu   (0x24, sp), d0
4841889f: 3c                    mov     sp, a0
484188a0: f8 93 2c              movhu   d0, (0x2c, sp)
484188a3: f8 bd 26              movhu   (0x26, sp), d1
484188a6: 20 2c                 add     0x2c, a0
484188a8: f8 97 2e              movhu   d1, (0x2e, sp)
484188ab: 99                    mov     a2, a1
484188ac: dd 16 c6 00 00 30 18  call    0x48424ec2, [a2,a3], 0x18
484188b3: 00                    clr     d0
484188b4: cc 07 01              jmp     0x484189bb
484188b7: dd 63 50 01 00 00 00  call    0x4842d91a, 0, 0
484188be: 92                    mov     a0, a2
484188bf: 22 18                 add     0x18, a2
484188c1: 72                    mov     (a2), d0
484188c2: 04                    clr     d1
484188c3: 46 10                 mov     d1, (0x10, sp)
484188c5: fc cd 92 00 06 00     mov     0x00060092, d1
484188cb: dd b5 23 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
484188d2: a0 00                 cmp     0, d0
484188d4: c8 74                 beq     0x48418948
484188d6: 3c                    mov     sp, a0
484188d7: f1 d1                 mov     a0, d1
484188d9: 29 1c                 add     0x1c, d1
484188db: 46 18                 mov     d1, (0x18, sp)
484188dd: f1 e0                 mov     d0, a0
484188df: 3d                    mov     sp, a1
484188e0: 21 30                 add     0x30, a1
484188e2: 3e                    mov     sp, a2
484188e3: f1 d8                 mov     a2, d0
484188e5: 28 40                 add     0x40, d0
484188e7: f1 d9                 mov     a2, d1
484188e9: 29 68                 add     0x68, d1
484188eb: dd fb 94 00 00 f0 24  call    0x48421de6, [d2,d3,a2,a3], 0x24
484188f2: a0 00                 cmp     0, d0
484188f4: c9 05                 bne     0x484188f9
484188f6: cc b5 00              jmp     0x484189ab
484188f9: 58 44                 mov     (0x44, sp), d0
484188fb: f8 93 20              movhu   d0, (0x20, sp)
484188fe: 58 48                 mov     (0x48, sp), d0
48418900: f8 93 22              movhu   d0, (0x22, sp)
48418903: f8 bc 20              movhu   (0x20, sp), d0
48418906: 18                    exth    d0
48418907: a0 00                 cmp     0, d0
48418909: c1 05                 bgt     0x4841890e
4841890b: cc a0 00              jmp     0x484189ab
4841890e: f8 bc 22              movhu   (0x22, sp), d0
48418911: 18                    exth    d0
48418912: a0 00                 cmp     0, d0
48418914: c1 05                 bgt     0x48418919
48418916: cc 95 00              jmp     0x484189ab
48418919: 3e                    mov     sp, a2
4841891a: 22 24                 add     0x24, a2
4841891c: 88                    mov     d2, d0
4841891d: 98                    mov     a2, a0
4841891e: cd d4 e4 00 14        call    0x48416df2, 0, 0x14
48418923: f8 bd 24              movhu   (0x24, sp), d1
48418926: f8 bc 20              movhu   (0x20, sp), d0
48418929: 19                    exth    d1
4841892a: 18                    exth    d0
4841892b: e4                    add     d1, d0
4841892c: 28 ff                 add     -1, d0
4841892e: f8 93 28              movhu   d0, (0x28, sp)
48418931: f8 bd 26              movhu   (0x26, sp), d1
48418934: f8 bc 22              movhu   (0x22, sp), d0
48418937: 19                    exth    d1
48418938: 18                    exth    d0
48418939: e4                    add     d1, d0
4841893a: 28 ff                 add     -1, d0
4841893c: f8 93 2a              movhu   d0, (0x2a, sp)
4841893f: 98                    mov     a2, a0
48418940: 88                    mov     d2, d0
48418941: cd c8 e4 a0 18        call    0x48416e09, [d2,a2], 0x18
48418946: ca 65                 bra     0x484189ab
48418948: 72                    mov     (a2), d0
48418949: 04                    clr     d1
4841894a: 46 10                 mov     d1, (0x10, sp)
4841894c: fc cd e6 00 06 00     mov     0x000600e6, d1
48418952: dd 2e 23 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48418959: a0 00                 cmp     0, d0
4841895b: c8 50                 beq     0x484189ab
4841895d: 3d                    mov     sp, a1
4841895e: f1 e0                 mov     d0, a0
48418960: 21 20                 add     0x20, a1
48418962: 3e                    mov     sp, a2
48418963: f1 d8                 mov     a2, d0
48418965: 28 22                 add     0x22, d0
48418967: dd 00 c9 00 00 f0 10  call    0x48425267, [d2,d3,a2,a3], 0x10
4841896e: f8 bc 20              movhu   (0x20, sp), d0
48418971: 18                    exth    d0
48418972: a0 00                 cmp     0, d0
48418974: c3 37                 ble     0x484189ab
48418976: f8 bc 22              movhu   (0x22, sp), d0
48418979: 18                    exth    d0
4841897a: a0 00                 cmp     0, d0
4841897c: c3 2f                 ble     0x484189ab
4841897e: 3e                    mov     sp, a2
4841897f: 22 24                 add     0x24, a2
48418981: 88                    mov     d2, d0
48418982: 98                    mov     a2, a0
48418983: cd 6f e4 00 14        call    0x48416df2, 0, 0x14
48418988: f8 bd 24              movhu   (0x24, sp), d1
4841898b: f8 bc 20              movhu   (0x20, sp), d0
4841898e: 19                    exth    d1
4841898f: 18                    exth    d0
48418990: e4                    add     d1, d0
48418991: 28 ff                 add     -1, d0
48418993: f8 93 28              movhu   d0, (0x28, sp)
48418996: f8 bd 26              movhu   (0x26, sp), d1
48418999: f8 bc 22              movhu   (0x22, sp), d0
4841899c: 19                    exth    d1
4841899d: 18                    exth    d0
4841899e: e4                    add     d1, d0
4841899f: 28 ff                 add     -1, d0
484189a1: f8 93 2a              movhu   d0, (0x2a, sp)
484189a4: 98                    mov     a2, a0
484189a5: 88                    mov     d2, d0
484189a6: cd 63 e4 a0 18        call    0x48416e09, [d2,a2], 0x18
484189ab: 00                    clr     d0
484189ac: ca 0f                 bra     0x484189bb
484189ae: fa b0 84 04           mov     (0x484, sp), a0
484189b2: 43 10                 mov     a0, (0x10, sp)
484189b4: dd b5 0b 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484189bb: fa fe 68 04           add     0x468, sp
484189bf: df b0 0c              ret     [d2,a2,a3], 0xc
484189c2: cf 80                 movm    [d2], (sp)
484189c4: fa fe 08 ff           add     -0xf8, sp
484189c8: fc dd 04 e7 59 48     mov     0x4859e704, a1
484189ce: 3c                    mov     sp, a0
484189cf: 2e 0a ff              mov     -0xf6, d2
484189d2: db                    setlb
484189d3: f0 41                 movbu   (a1), d0
484189d5: 45                    inc     a1
484189d6: f0 50                 movbu   d0, (a0)
484189d8: 41                    inc     a0
484189d9: 48                    inc     d2
484189da: d9                    lne
484189db: fc c9 92 00 06 00     cmp     0x60092, d1
484189e1: c9 07                 bne     0x484189e8
484189e3: 3c                    mov     sp, a0
484189e4: f1 d0                 mov     a0, d0
484189e6: ca 03                 bra     0x484189e9
484189e8: 00                    clr     d0
484189e9: de 80 fc              retf    [d2], 0xfc

VwIconProc:
484189ec: cf b0                 movm    [d2,a2,a3], (sp)
484189ee: f8 fe dc              add     -0x24, sp
484189f1: 82                    mov     d0, d2
484189f2: fc c9 b2 00 06 00     cmp     0x600b2, d1
484189f8: c9 77                 bne     0x48418a6f
484189fa: 5c 40                 mov     (0x40, sp), a0
484189fc: 3e                    mov     sp, a2
484189fd: 43 10                 mov     a0, (0x10, sp)
484189ff: dd 6a 0b 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418a06: 88                    mov     d2, d0
48418a07: dd 13 4f 01 00 00 00  call    0x4842d91a, 0, 0
48418a0e: 43 14                 mov     a0, (0x14, sp)
48418a10: 22 18                 add     0x18, a2
48418a12: 98                    mov     a2, a0
48418a13: 88                    mov     d2, d0
48418a14: cd de e3 00 14        call    0x48416df2, 0, 0x14
48418a19: f8 bc 18              movhu   (0x18, sp), d0
48418a1c: 98                    mov     a2, a0
48418a1d: 18                    exth    d0
48418a1e: 28 02                 add     2, d0
48418a20: f8 93 20              movhu   d0, (0x20, sp)
48418a23: f8 bc 1a              movhu   (0x1a, sp), d0
48418a26: 85 18                 mov     0x18, d1
48418a28: 18                    exth    d0
48418a29: 28 02                 add     2, d0
48418a2b: f8 93 22              movhu   d0, (0x22, sp)
48418a2e: f8 bc 20              movhu   (0x20, sp), d0
48418a31: 3f                    mov     sp, a3
48418a32: 18                    exth    d0
48418a33: 28 fe                 add     -2, d0
48418a35: f8 93 18              movhu   d0, (0x18, sp)
48418a38: f8 bc 20              movhu   (0x20, sp), d0
48418a3b: 23 20                 add     0x20, a3
48418a3d: 18                    exth    d0
48418a3e: 28 19                 add     0x19, d0
48418a40: f8 93 1c              movhu   d0, (0x1c, sp)
48418a43: f8 bc 22              movhu   (0x22, sp), d0
48418a46: 18                    exth    d0
48418a47: 28 fe                 add     -2, d0
48418a49: f8 93 1a              movhu   d0, (0x1a, sp)
48418a4c: f8 bc 22              movhu   (0x22, sp), d0
48418a4f: 18                    exth    d0
48418a50: 28 19                 add     0x19, d0
48418a52: f8 93 1e              movhu   d0, (0x1e, sp)
48418a55: 2c c0 00              mov     0xc0, d0
48418a58: dd 4e d7 00 00 e0 20  call    0x484261a6, [d2,d3,a2], 0x20
48418a5f: 5c 14                 mov     (0x14, sp), a0
48418a61: f8 00 18              mov     (0x18, a0), d0
48418a64: 9c                    mov     a3, a0
48418a65: dd 6d b3 00 00 a0 18  call    0x48423dd2, [d2,a2], 0x18
48418a6c: 00                    clr     d0
48418a6d: ca 0d                 bra     0x48418a7a
48418a6f: 5c 40                 mov     (0x40, sp), a0
48418a71: 43 10                 mov     a0, (0x10, sp)
48418a73: dd f6 0a 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418a7a: df b0 30              ret     [d2,a2,a3], 0x30

VwLineProc:
48418a7d: cf b0                 movm    [d2,a2,a3], (sp)
48418a7f: f8 fe dc              add     -0x24, sp
48418a82: 82                    mov     d0, d2
48418a83: fc c9 b2 00 06 00     cmp     0x600b2, d1
48418a89: c8 26                 beq     0x48418aaf
48418a8b: fc c9 b0 00 06 00     cmp     0x600b0, d1
48418a91: c9 05                 bne     0x48418a96
48418a93: cc 9c 00              jmp     0x48418b2f
48418a96: fc c9 ee 00 06 00     cmp     0x600ee, d1
48418a9c: c9 05                 bne     0x48418aa1
48418a9e: cc 9e 00              jmp     0x48418b3c
48418aa1: fc c9 ef 00 06 00     cmp     0x600ef, d1
48418aa7: c9 05                 bne     0x48418aac
48418aa9: cc b5 00              jmp     0x48418b5e
48418aac: cc c7 00              jmp     0x48418b73
48418aaf: 5c 40                 mov     (0x40, sp), a0
48418ab1: 43 10                 mov     a0, (0x10, sp)
48418ab3: dd b6 0a 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418aba: 88                    mov     d2, d0
48418abb: dd 5f 4e 01 00 00 00  call    0x4842d91a, 0, 0
48418ac2: 92                    mov     a0, a2
48418ac3: 88                    mov     d2, d0
48418ac4: 3c                    mov     sp, a0
48418ac5: 20 14                 add     0x14, a0
48418ac7: cd 2b e3 00 14        call    0x48416df2, 0, 0x14
48418acc: f8 42 1a              movbu   (0x1a, a2), d0
48418acf: a0 01                 cmp     1, d0
48418ad1: c9 22                 bne     0x48418af3
48418ad3: f8 bc 14              movhu   (0x14, sp), d0
48418ad6: 3f                    mov     sp, a3
48418ad7: 23 1c                 add     0x1c, a3
48418ad9: f8 93 1c              movhu   d0, (0x1c, sp)
48418adc: f8 bc 16              movhu   (0x16, sp), d0
48418adf: 3e                    mov     sp, a2
48418ae0: f8 93 1e              movhu   d0, (0x1e, sp)
48418ae3: f8 bc 18              movhu   (0x18, sp), d0
48418ae6: 22 20                 add     0x20, a2
48418ae8: f8 93 20              movhu   d0, (0x20, sp)
48418aeb: f8 bc 1a              movhu   (0x1a, sp), d0
48418aee: f8 93 22              movhu   d0, (0x22, sp)
48418af1: ca 20                 bra     0x48418b11
48418af3: f8 bc 14              movhu   (0x14, sp), d0
48418af6: 3f                    mov     sp, a3
48418af7: 23 1c                 add     0x1c, a3
48418af9: f8 93 1c              movhu   d0, (0x1c, sp)
48418afc: f8 bc 1a              movhu   (0x1a, sp), d0
48418aff: 3e                    mov     sp, a2
48418b00: f8 93 1e              movhu   d0, (0x1e, sp)
48418b03: f8 bc 18              movhu   (0x18, sp), d0
48418b06: 22 20                 add     0x20, a2
48418b08: f8 93 20              movhu   d0, (0x20, sp)
48418b0b: f8 bc 16              movhu   (0x16, sp), d0
48418b0e: f8 93 22              movhu   d0, (0x22, sp)
48418b11: 00                    clr     d0
48418b12: 42 10                 mov     d0, (0x10, sp)
48418b14: fc cd b0 00 06 00     mov     0x000600b0, d1
48418b1a: 88                    mov     d2, d0
48418b1b: dd 72 08 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418b22: 18                    exth    d0
48418b23: 99                    mov     a2, a1
48418b24: 9c                    mov     a3, a0
48418b25: dd 74 9d 00 00 b0 20  call    0x48422899, [d2,a2,a3], 0x20
48418b2c: 00                    clr     d0
48418b2d: ca 51                 bra     0x48418b7e
48418b2f: dd eb 4d 01 00 00 00  call    0x4842d91a, 0, 0
48418b36: f8 60 18              movhu   (0x18, a0), d0
48418b39: 18                    exth    d0
48418b3a: ca 44                 bra     0x48418b7e
48418b3c: dd de 4d 01 00 00 00  call    0x4842d91a, 0, 0
48418b43: 20 0e                 add     0xe, a0
48418b45: f8 60 06              movhu   (6, a0), d0
48418b48: 2d c8 00              mov     0xc8, d1
48418b4b: 18                    exth    d0
48418b4c: a4                    cmp     d1, d0
48418b4d: c3 0c                 ble     0x48418b59
48418b4f: f8 60 02              movhu   (2, a0), d0
48418b52: 18                    exth    d0
48418b53: a4                    cmp     d1, d0
48418b54: c3 05                 ble     0x48418b59
48418b56: 00                    clr     d0
48418b57: ca 27                 bra     0x48418b7e
48418b59: 2c ff 00              mov     0xff, d0
48418b5c: ca 22                 bra     0x48418b7e
48418b5e: 5e 40                 mov     (0x40, sp), a2
48418b60: 4b 10                 mov     a2, (0x10, sp)
48418b62: dd 07 0a 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418b69: 98                    mov     a2, a0
48418b6a: 88                    mov     d2, d0
48418b6b: cd 6c dd b0 1c        call    0x484168d7, [d2,a2,a3], 0x1c
48418b70: 00                    clr     d0
48418b71: ca 0d                 bra     0x48418b7e
48418b73: 5c 40                 mov     (0x40, sp), a0
48418b75: 43 10                 mov     a0, (0x10, sp)
48418b77: dd f2 09 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418b7e: df b0 30              ret     [d2,a2,a3], 0x30

VwEditSwLineProc:
48418b81: f8 fe ec              add     -0x14, sp
48418b84: fc c9 ee 00 06 00     cmp     0x600ee, d1
48418b8a: c9 0e                 bne     0x48418b98
48418b8c: dd 8e 4d 01 00 00 00  call    0x4842d91a, 0, 0
48418b93: f8 60 1c              movhu   (0x1c, a0), d0
48418b96: ca 0d                 bra     0x48418ba3
48418b98: 5c 24                 mov     (0x24, sp), a0
48418b9a: 43 10                 mov     a0, (0x10, sp)
48418b9c: dd cd 09 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418ba3: df 00 14              ret     0, 0x14

VwFrameProc:
48418ba6: cf f0                 movm    [d2,d3,a2,a3], (sp)
48418ba8: f8 fe e0              add     -0x20, sp
48418bab: 83                    mov     d0, d3
48418bac: 86                    mov     d1, d2
48418bad: fc ca b2 00 06 00     cmp     0x600b2, d2
48418bb3: c8 0c                 beq     0x48418bbf
48418bb5: fc ca a3 00 06 00     cmp     0x600a3, d2
48418bbb: c8 59                 beq     0x48418c14
48418bbd: ca 64                 bra     0x48418c21
48418bbf: dd 4a 48 01 00 00 0c  call    0x4842d409, 0, 0xc
48418bc6: a0 00                 cmp     0, d0
48418bc8: c9 06                 bne     0x48418bce
48418bca: 80 01                 mov     1, d0
48418bcc: ca 60                 bra     0x48418c2c
48418bce: 5c 40                 mov     (0x40, sp), a0
48418bd0: 8c                    mov     d3, d0
48418bd1: 43 10                 mov     a0, (0x10, sp)
48418bd3: 89                    mov     d2, d1
48418bd4: dd 95 09 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418bdb: 3f                    mov     sp, a3
48418bdc: 23 18                 add     0x18, a3
48418bde: 8c                    mov     d3, d0
48418bdf: 9c                    mov     a3, a0
48418be0: cd 12 e2 00 14        call    0x48416df2, 0, 0x14
48418be5: 8c                    mov     d3, d0
48418be6: dd 34 4d 01 00 00 00  call    0x4842d91a, 0, 0
48418bed: 92                    mov     a0, a2
48418bee: 00                    clr     d0
48418bef: 42 10                 mov     d0, (0x10, sp)
48418bf1: 8c                    mov     d3, d0
48418bf2: fc cd a3 00 06 00     mov     0x000600a3, d1
48418bf8: dd 95 07 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418bff: f8 66 18              movhu   (0x18, a2), d1
48418c02: f8 6a 1a              movhu   (0x1a, a2), d2
48418c05: 18                    exth    d0
48418c06: 1a                    exth    d2
48418c07: 42 14                 mov     d0, (0x14, sp)
48418c09: 84                    mov     d1, d0
48418c0a: 89                    mov     d2, d1
48418c0b: 9c                    mov     a3, a0
48418c0c: cd b0 00 f0 28        call    0x48418cbc, [d2,d3,a2,a3], 0x28
48418c11: 00                    clr     d0
48418c12: ca 1a                 bra     0x48418c2c
48418c14: dd 06 4d 01 00 00 00  call    0x4842d91a, 0, 0
48418c1b: f8 60 1c              movhu   (0x1c, a0), d0
48418c1e: 18                    exth    d0
48418c1f: ca 0d                 bra     0x48418c2c
48418c21: 5c 40                 mov     (0x40, sp), a0
48418c23: 43 10                 mov     a0, (0x10, sp)
48418c25: dd 44 09 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418c2c: df f0 30              ret     [d2,d3,a2,a3], 0x30

GetClientFrame:
48418c2f: cf 30                 movm    [a2,a3], (sp)
48418c31: f8 fe e0              add     -0x20, sp
48418c34: 93                    mov     a0, a3
48418c35: dd e5 4c 01 00 00 00  call    0x4842d91a, 0, 0
48418c3c: 9a 0e                 mov     0xe, a2
48418c3e: f1 72                 add     a0, a2
48418c40: 3d                    mov     sp, a1
48418c41: 21 18                 add     0x18, a1
48418c43: 85 fc                 mov     -4, d1
48418c45: db                    setlb
48418c46: f0 62                 movhu   (a2), d0
48418c48: 22 02                 add     2, a2
48418c4a: f0 71                 movhu   d0, (a1)
48418c4c: 21 02                 add     2, a1
48418c4e: 44                    inc     d1
48418c4f: d9                    lne
48418c50: f8 64 1a              movhu   (0x1a, a0), d1
48418c53: f8 60 18              movhu   (0x18, a0), d0
48418c56: 19                    exth    d1
48418c57: 3c                    mov     sp, a0
48418c58: 20 18                 add     0x18, a0
48418c5a: 9d                    mov     a3, a1
48418c5b: cd 0a 00 f0 10        call    0x48418c65, [d2,d3,a2,a3], 0x10
48418c60: df 30 28              ret     [a2,a3], 0x28

GetClientFrame2:
48418c63: cf f0     movm    [d2,d3,a2,a3], (sp)
48418c65: f1 e6     mov     d1, a2
48418c67: 83        mov     d0, d3
48418c68: 97        mov     a1, a3
48418c69: 08        clr     d2
48418c6a: 85 fc     mov     -4, d1
48418c6c: db        setlb
48418c6d: f0 60     movhu   (a0), d0
48418c6f: 20 02     add     2, a0
48418c71: f0 71     movhu   d0, (a1)
48418c73: 21 02     add     2, a1
48418c75: 44        inc     d1
48418c76: d9        lne
48418c77: 1f        exthu   d3
48418c78: af 01     cmp     1, d3
48418c7a: c8 07     beq     0x48418c81
48418c7c: ab        cmp     d2, d3
48418c7d: c8 07     beq     0x48418c84
48418c7f: ca 05     bra     0x48418c84
48418c81: f1 da     mov     a2, d2
48418c83: 1a        exth    d2
48418c84: aa 00     cmp     0, d2
48418c86: c8 2e     beq     0x48418cb4
48418c88: 04        clr     d1
48418c89: a6        cmp     d1, d2
48418c8a: c3 2a     ble     0x48418cb4
48418c8c: 9a 02     mov     2, a2
48418c8e: f1 7e     add     a3, a2
48418c90: 95 06     mov     6, a1
48418c92: f1 7d     add     a3, a1
48418c94: 9c        mov     a3, a0
48418c95: 50        inc4    a0
48418c96: db        setlb
48418c97: f0 62     movhu   (a2), d0
48418c99: 44        inc     d1
48418c9a: 18        exth    d0
48418c9b: 40        inc     d0
48418c9c: f0 72     movhu   d0, (a2)
48418c9e: f0 61     movhu   (a1), d0
48418ca0: 18        exth    d0
48418ca1: 28 ff     add     -1, d0
48418ca3: f0 71     movhu   d0, (a1)
48418ca5: f0 63     movhu   (a3), d0
48418ca7: 18        exth    d0
48418ca8: 40        inc     d0
48418ca9: f0 73     movhu   d0, (a3)
48418cab: f0 60     movhu   (a0), d0
48418cad: 18        exth    d0
48418cae: 28 ff     add     -1, d0
48418cb0: f0 70     movhu   d0, (a0)
48418cb2: a9        cmp     d2, d1
48418cb3: d0        llt
48418cb4: de f0 10  retf    [d2,d3,a2,a3], 0x10

DrawDesignFrame:
48418cb7: cf f0                 movm    [d2,d3,a2,a3], (sp)
48418cb9: f8 fe e8              add     -0x18, sp
48418cbc: 87                    mov     d1, d3
48418cbd: 82                    mov     d0, d2
48418cbe: 91                    mov     a0, a1
48418cbf: 3c                    mov     sp, a0
48418cc0: 20 10                 add     0x10, a0
48418cc2: 80 fc                 mov     -4, d0
48418cc4: db                    setlb
48418cc5: f0 65                 movhu   (a1), d1
48418cc7: 21 02                 add     2, a1
48418cc9: f0 74                 movhu   d1, (a0)
48418ccb: 20 02                 add     2, a0
48418ccd: 40                    inc     d0
48418cce: d9                    lne
48418ccf: 1e                    exthu   d2
48418cd0: aa 00                 cmp     0, d2
48418cd2: c8 44                 beq     0x48418d16
48418cd4: aa 01                 cmp     1, d2
48418cd6: c9 40                 bne     0x48418d16
48418cd8: 08                    clr     d2
48418cd9: 1b                    exth    d3
48418cda: ab                    cmp     d2, d3
48418cdb: c3 3b                 ble     0x48418d16
48418cdd: f8 bc 3c              movhu   (0x3c, sp), d0
48418ce0: 3f                    mov     sp, a3
48418ce1: 23 10                 add     0x10, a3
48418ce3: 18                    exth    d0
48418ce4: f1 e2                 mov     d0, a2
48418ce6: 9c                    mov     a3, a0
48418ce7: f1 d8                 mov     a2, d0
48418ce9: dd bb a4 00 00 a0 18  call    0x484231a4, [d2,a2], 0x18
48418cf0: f8 bc 12              movhu   (0x12, sp), d0
48418cf3: 48                    inc     d2
48418cf4: 18                    exth    d0
48418cf5: 40                    inc     d0
48418cf6: f8 93 12              movhu   d0, (0x12, sp)
48418cf9: f8 bc 16              movhu   (0x16, sp), d0
48418cfc: 18                    exth    d0
48418cfd: 28 ff                 add     -1, d0
48418cff: f8 93 16              movhu   d0, (0x16, sp)
48418d02: f8 bc 10              movhu   (0x10, sp), d0
48418d05: 18                    exth    d0
48418d06: 40                    inc     d0
48418d07: f8 93 10              movhu   d0, (0x10, sp)
48418d0a: f8 bc 14              movhu   (0x14, sp), d0
48418d0d: 18                    exth    d0
48418d0e: 28 ff                 add     -1, d0
48418d10: f8 93 14              movhu   d0, (0x14, sp)
48418d13: ae                    cmp     d3, d2
48418d14: c0 d2                 blt     0x48418ce6
48418d16: df f0 28              ret     [d2,d3,a2,a3], 0x28

VwJpegFileProc:
48418d19: cf b0                 movm    [d2,a2,a3], (sp)
48418d1b: fa fe 98 fb           add     -0x468, sp
48418d1f: 82                    mov     d0, d2
48418d20: fc c9 b2 00 06 00     cmp     0x600b2, d1
48418d26: c8 23                 beq     0x48418d49
48418d28: fc c9 e7 00 06 00     cmp     0x600e7, d1
48418d2e: c8 5f                 beq     0x48418d8d
48418d30: fc c9 3a 00 05 00     cmp     0x5003a, d1
48418d36: c9 05                 bne     0x48418d3b
48418d38: cc d3 00              jmp     0x48418e0b
48418d3b: fc c9 e5 00 06 00     cmp     0x600e5, d1
48418d41: c9 05                 bne     0x48418d46
48418d43: cc 06 01              jmp     0x48418e49
48418d46: cc f8 01              jmp     0x48418f3e
48418d49: fa b0 84 04           mov     (0x484, sp), a0
48418d4d: 43 10                 mov     a0, (0x10, sp)
48418d4f: dd 1a 08 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418d56: 88                    mov     d2, d0
48418d57: dd c3 4b 01 00 00 00  call    0x4842d91a, 0, 0
48418d5e: f8 00 1c              mov     (0x1c, a0), d0
48418d61: a0 00                 cmp     0, d0
48418d63: c8 15                 beq     0x48418d78
48418d65: 4a 10                 mov     d2, (0x10, sp)
48418d67: 80 ff                 mov     -1, d0
48418d69: fc cd 3a 00 05 00     mov     0x0005003a, d1
48418d6f: dd 31 0b 01 00 80 1c  call    0x484298a0, [d2], 0x1c
48418d76: ca 13                 bra     0x48418d89
48418d78: 00                    clr     d0
48418d79: 42 10                 mov     d0, (0x10, sp)
48418d7b: fc cd e7 00 06 00     mov     0x000600e7, d1
48418d81: 88                    mov     d2, d0
48418d82: dd 0b 06 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418d89: 00                    clr     d0
48418d8a: cc c1 01              jmp     0x48418f4b
48418d8d: dd 8d 4b 01 00 00 00  call    0x4842d91a, 0, 0
48418d94: 92                    mov     a0, a2
48418d95: 22 18                 add     0x18, a2
48418d97: 72                    mov     (a2), d0
48418d98: 04                    clr     d1
48418d99: 46 10                 mov     d1, (0x10, sp)
48418d9b: fc cd e6 00 06 00     mov     0x000600e6, d1
48418da1: dd df 1e 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48418da8: f1 e3                 mov     d0, a3
48418daa: bf 00                 cmp     0, a3
48418dac: c8 24                 beq     0x48418dd0
48418dae: 3c                    mov     sp, a0
48418daf: 20 24                 add     0x24, a0
48418db1: 88                    mov     d2, d0
48418db2: cd 40 e0 00 14        call    0x48416df2, 0, 0x14
48418db7: f8 bc 24              movhu   (0x24, sp), d0
48418dba: 3c                    mov     sp, a0
48418dbb: f8 93 2c              movhu   d0, (0x2c, sp)
48418dbe: f8 bc 26              movhu   (0x26, sp), d0
48418dc1: 20 2c                 add     0x2c, a0
48418dc3: f8 93 2e              movhu   d0, (0x2e, sp)
48418dc6: 9d                    mov     a3, a1
48418dc7: dd fb c0 00 00 30 18  call    0x48424ec2, [a2,a3], 0x18
48418dce: ca 39                 bra     0x48418e07
48418dd0: 72                    mov     (a2), d0
48418dd1: 04                    clr     d1
48418dd2: 46 10                 mov     d1, (0x10, sp)
48418dd4: fc cd 92 00 06 00     mov     0x00060092, d1
48418dda: dd a6 1e 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48418de1: f1 e2                 mov     d0, a2
48418de3: ba 00                 cmp     0, a2
48418de5: c8 22                 beq     0x48418e07
48418de7: 3c                    mov     sp, a0
48418de8: 20 24                 add     0x24, a0
48418dea: 88                    mov     d2, d0
48418deb: cd 07 e0 00 14        call    0x48416df2, 0, 0x14
48418df0: f8 bd 24              movhu   (0x24, sp), d1
48418df3: 3c                    mov     sp, a0
48418df4: f8 97 2c              movhu   d1, (0x2c, sp)
48418df7: f8 bc 26              movhu   (0x26, sp), d0
48418dfa: 20 2c                 add     0x2c, a0
48418dfc: f8 93 2e              movhu   d0, (0x2e, sp)
48418dff: 99                    mov     a2, a1
48418e00: dd a4 bc 00 00 30 18  call    0x48424aa4, [a2,a3], 0x18
48418e07: 00                    clr     d0
48418e08: cc 43 01              jmp     0x48418f4b
48418e0b: fa b2 84 04           mov     (0x484, sp), a2
48418e0f: 4b 10                 mov     a2, (0x10, sp)
48418e11: dd 58 07 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418e18: f1 aa                 cmp     d2, a2
48418e1a: c9 2b                 bne     0x48418e45
48418e1c: 80 01                 mov     1, d0
48418e1e: dd bc 97 00 00 80 10  call    0x484225da, [d2], 0x10
48418e25: dd d9 96 00 00 00 0c  call    0x484224fe, 0, 0xc
48418e2c: 00                    clr     d0
48418e2d: dd ad 97 00 00 80 10  call    0x484225da, [d2], 0x10
48418e34: 00                    clr     d0
48418e35: 42 10                 mov     d0, (0x10, sp)
48418e37: fc cd e7 00 06 00     mov     0x000600e7, d1
48418e3d: 88                    mov     d2, d0
48418e3e: dd 4f 05 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418e45: 00                    clr     d0
48418e46: cc 05 01              jmp     0x48418f4b
48418e49: dd d1 4a 01 00 00 00  call    0x4842d91a, 0, 0
48418e50: 92                    mov     a0, a2
48418e51: 22 18                 add     0x18, a2
48418e53: 72                    mov     (a2), d0
48418e54: 04                    clr     d1
48418e55: 46 10                 mov     d1, (0x10, sp)
48418e57: fc cd e6 00 06 00     mov     0x000600e6, d1
48418e5d: dd 23 1e 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48418e64: a0 00                 cmp     0, d0
48418e66: c8 59                 beq     0x48418ebf
48418e68: 3d                    mov     sp, a1
48418e69: f1 e0                 mov     d0, a0
48418e6b: 21 20                 add     0x20, a1
48418e6d: 3e                    mov     sp, a2
48418e6e: f1 d8                 mov     a2, d0
48418e70: 28 22                 add     0x22, d0
48418e72: dd f5 c3 00 00 f0 10  call    0x48425267, [d2,d3,a2,a3], 0x10
48418e79: f8 bc 20              movhu   (0x20, sp), d0
48418e7c: 18                    exth    d0
48418e7d: a0 00                 cmp     0, d0
48418e7f: c1 05                 bgt     0x48418e84
48418e81: cc ba 00              jmp     0x48418f3b
48418e84: f8 bc 22              movhu   (0x22, sp), d0
48418e87: 18                    exth    d0
48418e88: a0 00                 cmp     0, d0
48418e8a: c1 05                 bgt     0x48418e8f
48418e8c: cc af 00              jmp     0x48418f3b
48418e8f: 3e                    mov     sp, a2
48418e90: 22 24                 add     0x24, a2
48418e92: 88                    mov     d2, d0
48418e93: 98                    mov     a2, a0
48418e94: cd 5e df 00 14        call    0x48416df2, 0, 0x14
48418e99: f8 bd 24              movhu   (0x24, sp), d1
48418e9c: f8 bc 20              movhu   (0x20, sp), d0
48418e9f: 19                    exth    d1
48418ea0: 18                    exth    d0
48418ea1: e4                    add     d1, d0
48418ea2: 28 ff                 add     -1, d0
48418ea4: f8 93 28              movhu   d0, (0x28, sp)
48418ea7: f8 bd 26              movhu   (0x26, sp), d1
48418eaa: f8 bc 22              movhu   (0x22, sp), d0
48418ead: 19                    exth    d1
48418eae: 18                    exth    d0
48418eaf: e4                    add     d1, d0
48418eb0: 28 ff                 add     -1, d0
48418eb2: f8 93 2a              movhu   d0, (0x2a, sp)
48418eb5: 98                    mov     a2, a0
48418eb6: 88                    mov     d2, d0
48418eb7: cd 52 df a0 18        call    0x48416e09, [d2,a2], 0x18
48418ebc: cc 7f 00              jmp     0x48418f3b
48418ebf: 72                    mov     (a2), d0
48418ec0: 04                    clr     d1
48418ec1: 46 10                 mov     d1, (0x10, sp)
48418ec3: fc cd 92 00 06 00     mov     0x00060092, d1
48418ec9: dd b7 1d 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48418ed0: a0 00                 cmp     0, d0
48418ed2: c8 69                 beq     0x48418f3b
48418ed4: 3c                    mov     sp, a0
48418ed5: f1 d1                 mov     a0, d1
48418ed7: 29 1c                 add     0x1c, d1
48418ed9: 46 18                 mov     d1, (0x18, sp)
48418edb: f1 e0                 mov     d0, a0
48418edd: 3d                    mov     sp, a1
48418ede: 21 30                 add     0x30, a1
48418ee0: 3e                    mov     sp, a2
48418ee1: f1 d8                 mov     a2, d0
48418ee3: 28 40                 add     0x40, d0
48418ee5: f1 d9                 mov     a2, d1
48418ee7: 29 68                 add     0x68, d1
48418ee9: dd fd 8e 00 00 f0 24  call    0x48421de6, [d2,d3,a2,a3], 0x24
48418ef0: a0 00                 cmp     0, d0
48418ef2: c8 49                 beq     0x48418f3b
48418ef4: 58 44                 mov     (0x44, sp), d0
48418ef6: f8 93 20              movhu   d0, (0x20, sp)
48418ef9: 58 48                 mov     (0x48, sp), d0
48418efb: f8 93 22              movhu   d0, (0x22, sp)
48418efe: f8 bc 20              movhu   (0x20, sp), d0
48418f01: 18                    exth    d0
48418f02: a0 00                 cmp     0, d0
48418f04: c3 37                 ble     0x48418f3b
48418f06: f8 bc 22              movhu   (0x22, sp), d0
48418f09: 18                    exth    d0
48418f0a: a0 00                 cmp     0, d0
48418f0c: c3 2f                 ble     0x48418f3b
48418f0e: 3e                    mov     sp, a2
48418f0f: 22 24                 add     0x24, a2
48418f11: 88                    mov     d2, d0
48418f12: 98                    mov     a2, a0
48418f13: cd df de 00 14        call    0x48416df2, 0, 0x14
48418f18: f8 bd 24              movhu   (0x24, sp), d1
48418f1b: f8 bc 20              movhu   (0x20, sp), d0
48418f1e: 19                    exth    d1
48418f1f: 18                    exth    d0
48418f20: e4                    add     d1, d0
48418f21: 28 ff                 add     -1, d0
48418f23: f8 93 28              movhu   d0, (0x28, sp)
48418f26: f8 bd 26              movhu   (0x26, sp), d1
48418f29: f8 bc 22              movhu   (0x22, sp), d0
48418f2c: 19                    exth    d1
48418f2d: 18                    exth    d0
48418f2e: e4                    add     d1, d0
48418f2f: 28 ff                 add     -1, d0
48418f31: f8 93 2a              movhu   d0, (0x2a, sp)
48418f34: 98                    mov     a2, a0
48418f35: 88                    mov     d2, d0
48418f36: cd d3 de a0 18        call    0x48416e09, [d2,a2], 0x18
48418f3b: 00                    clr     d0
48418f3c: ca 0f                 bra     0x48418f4b
48418f3e: fa b0 84 04           mov     (0x484, sp), a0
48418f42: 43 10                 mov     a0, (0x10, sp)
48418f44: dd 25 06 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418f4b: fa fe 68 04           add     0x468, sp
48418f4f: df b0 0c              ret     [d2,a2,a3], 0xc
48418f52: fc c9 e6 00 06 00     cmp     0x600e6, d1
48418f58: c9 0a                 bne     0x48418f62
48418f5a: fc cc fc e7 59 48     mov     0x4859e7fc, d0
48418f60: ca 03                 bra     0x48418f63
48418f62: 00                    clr     d0
48418f63: de 00 00              retf    0, 0

PsParaBoxProc:
48418f66: cf f0                 movm    [d2,d3,a2,a3], (sp)
48418f68: f8 fe bc              add     -0x44, sp
48418f6b: 82                    mov     d0, d2
48418f6c: fc c9 b4 00 06 00     cmp     0x600b4, d1
48418f72: c8 26                 beq     0x48418f98
48418f74: fc c9 3a 00 06 00     cmp     0x6003a, d1
48418f7a: c9 05                 bne     0x48418f7f
48418f7c: cc e3 00              jmp     0x4841905f
48418f7f: fc c9 af 00 06 00     cmp     0x600af, d1
48418f85: c9 05                 bne     0x48418f8a
48418f87: cc df 00              jmp     0x48419066
48418f8a: fc c9 ae 00 06 00     cmp     0x600ae, d1
48418f90: c9 05                 bne     0x48418f95
48418f92: cc e0 00              jmp     0x48419072
48418f95: cc ea 00              jmp     0x4841907f
48418f98: 5f 64                 mov     (0x64, sp), a3
48418f9a: 4f 10                 mov     a3, (0x10, sp)
48418f9c: dd cd 05 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48418fa3: 3c                    mov     sp, a0
48418fa4: f1 d0                 mov     a0, d0
48418fa6: 28 38                 add     0x38, d0
48418fa8: 42 24                 mov     d0, (0x24, sp)
48418faa: 88                    mov     d2, d0
48418fab: 5c 24                 mov     (0x24, sp), a0
48418fad: cd 38 db 00 14        call    0x48416ae5, 0, 0x14
48418fb2: 3c                    mov     sp, a0
48418fb3: f1 d0                 mov     a0, d0
48418fb5: 28 40                 add     0x40, d0
48418fb7: 42 28                 mov     d0, (0x28, sp)
48418fb9: 5c 24                 mov     (0x24, sp), a0
48418fbb: f1 e1                 mov     d0, a1
48418fbd: cd 76 de f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
48418fc2: 88                    mov     d2, d0
48418fc3: dd 57 49 01 00 00 00  call    0x4842d91a, 0, 0
48418fca: 43 2c                 mov     a0, (0x2c, sp)
48418fcc: 00                    clr     d0
48418fcd: 42 10                 mov     d0, (0x10, sp)
48418fcf: 88                    mov     d2, d0
48418fd0: fc cd af 00 06 00     mov     0x000600af, d1
48418fd6: dd b7 03 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418fdd: 42 30                 mov     d0, (0x30, sp)
48418fdf: 00                    clr     d0
48418fe0: 42 10                 mov     d0, (0x10, sp)
48418fe2: 88                    mov     d2, d0
48418fe3: fc cd a3 00 06 00     mov     0x000600a3, d1
48418fe9: dd a4 03 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48418ff0: 83                    mov     d0, d3
48418ff1: 00                    clr     d0
48418ff2: 42 10                 mov     d0, (0x10, sp)
48418ff4: fc cd ae 00 06 00     mov     0x000600ae, d1
48418ffa: 88                    mov     d2, d0
48418ffb: dd 92 03 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419002: f8 93 34              movhu   d0, (0x34, sp)
48419005: 2c 00 01              mov     0x100, d0
48419008: cd 22 d6 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841900d: 92                    mov     a0, a2
4841900e: bf 00                 cmp     0, a3
48419010: c9 21                 bne     0x48419031
48419012: 88                    mov     d2, d0
48419013: 43 10                 mov     a0, (0x10, sp)
48419015: fc cd 3a 00 06 00     mov     0x0006003a, d1
4841901b: dd 72 03 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419022: f0 42                 movbu   (a2), d0
48419024: a0 00                 cmp     0, d0
48419026: c9 13                 bne     0x48419039
48419028: 98                    mov     a2, a0
48419029: cd b5 d6 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841902e: 00                    clr     d0
4841902f: ca 5b                 bra     0x4841908a
48419031: 9d                    mov     a3, a1
48419032: dd 1f a0 be 03 20 04  call    0x4c003051, [a2], 4
48419039: 1b                    exth    d3
4841903a: 4b 10                 mov     a2, (0x10, sp)
4841903c: 4e 1c                 mov     d3, (0x1c, sp)
4841903e: 5c 2c                 mov     (0x2c, sp), a0
48419040: f8 40 26              movbu   (0x26, a0), d0
48419043: 42 20                 mov     d0, (0x20, sp)
48419045: 5c 24                 mov     (0x24, sp), a0
48419047: f8 bd 34              movhu   (0x34, sp), d1
4841904a: 5d 28                 mov     (0x28, sp), a1
4841904c: 58 30                 mov     (0x30, sp), d0
4841904e: 19                    exth    d1
4841904f: dd 75 ca 00 00 a0 28  call    0x48425ac4, [d2,a2], 0x28
48419056: 98                    mov     a2, a0
48419057: cd 87 d6 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841905c: 00                    clr     d0
4841905d: ca 2d                 bra     0x4841908a
4841905f: 5c 64                 mov     (0x64, sp), a0
48419061: 00                    clr     d0
48419062: f0 50                 movbu   d0, (a0)
48419064: ca 26                 bra     0x4841908a
48419066: dd b4 48 01 00 00 00  call    0x4842d91a, 0, 0
4841906d: f8 00 20              mov     (0x20, a0), d0
48419070: ca 1a                 bra     0x4841908a
48419072: dd a8 48 01 00 00 00  call    0x4842d91a, 0, 0
48419079: f8 60 24              movhu   (0x24, a0), d0
4841907c: 18                    exth    d0
4841907d: ca 0d                 bra     0x4841908a
4841907f: 5c 64                 mov     (0x64, sp), a0
48419081: 43 10                 mov     a0, (0x10, sp)
48419083: dd e6 04 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841908a: df f0 54              ret     [d2,d3,a2,a3], 0x54

AcMmmBoxProc:
4841908d: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841908f: f8 fe dc              add     -0x24, sp
48419092: 83                    mov     d0, d3
48419093: 86                    mov     d1, d2
48419094: fc ca 01 00 05 00     cmp     0x50001, d2
4841909a: c8 20                 beq     0x484190ba
4841909c: fc ca 3a 00 06 00     cmp     0x6003a, d2
484190a2: c8 48                 beq     0x484190ea
484190a4: fc ca 09 00 05 00     cmp     0x50009, d2
484190aa: c8 6c                 beq     0x48419116
484190ac: fc ca 14 00 05 00     cmp     0x50014, d2
484190b2: c9 05                 bne     0x484190b7
484190b4: cc a6 00              jmp     0x4841915a
484190b7: cc 0b 01              jmp     0x484191c2
484190ba: dd 60 48 01 00 00 00  call    0x4842d91a, 0, 0
484190c1: f8 00 28              mov     (0x28, a0), d0
484190c4: 04                    clr     d1
484190c5: 46 10                 mov     d1, (0x10, sp)
484190c7: fc cd bc 00 06 00     mov     0x000600bc, d1
484190cd: dd b3 1b 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
484190d4: cd 3b 33 80 18        call    0x4841c40f, [d2], 0x18
484190d9: 5c 44                 mov     (0x44, sp), a0
484190db: 89                    mov     d2, d1
484190dc: 43 10                 mov     a0, (0x10, sp)
484190de: 8c                    mov     d3, d0
484190df: dd 8a 04 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484190e6: 00                    clr     d0
484190e7: df f0 34              ret     [d2,d3,a2,a3], 0x34
484190ea: dd 30 48 01 00 00 00  call    0x4842d91a, 0, 0
484190f1: f8 24 2c              mov     (0x2c, a0), a1
484190f4: fc cd bb 00 06 00     mov     0x000600bb, d1
484190fa: f0 61                 movhu   (a1), d0
484190fc: f8 93 1c              movhu   d0, (0x1c, sp)
484190ff: 5e 44                 mov     (0x44, sp), a2
48419101: 4b 20                 mov     a2, (0x20, sp)
48419103: f8 00 28              mov     (0x28, a0), d0
48419106: 3c                    mov     sp, a0
48419107: 20 14                 add     0x14, a0
48419109: 43 10                 mov     a0, (0x10, sp)
4841910b: dd 75 1b 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48419112: 00                    clr     d0
48419113: df f0 34              ret     [d2,d3,a2,a3], 0x34
48419116: 5c 44                 mov     (0x44, sp), a0
48419118: 43 10                 mov     a0, (0x10, sp)
4841911a: dd 4f 04 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419121: 8c                    mov     d3, d0
48419122: dd f8 47 01 00 00 00  call    0x4842d91a, 0, 0
48419129: 92                    mov     a0, a2
4841912a: 22 28                 add     0x28, a2
4841912c: 72                    mov     (a2), d0
4841912d: 04                    clr     d1
4841912e: 46 10                 mov     d1, (0x10, sp)
48419130: fc cd bc 00 06 00     mov     0x000600bc, d1
48419136: dd 4a 1b 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841913d: 82                    mov     d0, d2
4841913e: 72                    mov     (a2), d0
4841913f: 04                    clr     d1
48419140: 46 10                 mov     d1, (0x10, sp)
48419142: fc cd bd 00 06 00     mov     0x000600bd, d1
48419148: dd 38 1b 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841914f: 81                    mov     d0, d1
48419150: 88                    mov     d2, d0
48419151: cd e3 31 e0 20        call    0x4841c334, [d2,d3,a2], 0x20
48419156: 00                    clr     d0
48419157: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841915a: 5f 44                 mov     (0x44, sp), a3
4841915c: 9a 28                 mov     0x28, a2
4841915e: 4f 10                 mov     a3, (0x10, sp)
48419160: dd 09 04 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419167: 8c                    mov     d3, d0
48419168: dd b2 47 01 00 00 00  call    0x4842d91a, 0, 0
4841916f: f1 d2                 mov     a0, d2
48419171: f1 6a                 add     d2, a2
48419173: 72                    mov     (a2), d0
48419174: 4f 10                 mov     a3, (0x10, sp)
48419176: fc cd ba 00 06 00     mov     0x000600ba, d1
4841917c: dd 04 1b 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48419183: a0 00                 cmp     0, d0
48419185: c8 3a                 beq     0x484191bf
48419187: 72                    mov     (a2), d0
48419188: 4f 10                 mov     a3, (0x10, sp)
4841918a: fc cd b9 00 06 00     mov     0x000600b9, d1
48419190: dd f0 1a 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48419197: 72                    mov     (a2), d0
48419198: 4f 10                 mov     a3, (0x10, sp)
4841919a: fc cd be 00 06 00     mov     0x000600be, d1
484191a0: dd e0 1a 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
484191a7: f1 e8                 mov     d2, a0
484191a9: f8 20 2c              mov     (0x2c, a0), a0
484191ac: fc cd b4 00 06 00     mov     0x000600b4, d1
484191b2: f0 70                 movhu   d0, (a0)
484191b4: 00                    clr     d0
484191b5: 42 10                 mov     d0, (0x10, sp)
484191b7: 8c                    mov     d3, d0
484191b8: dd d5 01 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484191bf: 00                    clr     d0
484191c0: ca 0d                 bra     0x484191cd
484191c2: 5c 44                 mov     (0x44, sp), a0
484191c4: 43 10                 mov     a0, (0x10, sp)
484191c6: dd a3 03 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484191cd: df f0 34              ret     [d2,d3,a2,a3], 0x34

AcRamBoxProc:
484191d0: cf f0                 movm    [d2,d3,a2,a3], (sp)
484191d2: f8 fe d4              add     -0x2c, sp
484191d5: 83                    mov     d0, d3
484191d6: fc c9 3a 00 06 00     cmp     0x6003a, d1
484191dc: c8 20                 beq     0x484191fc
484191de: fc c9 09 00 05 00     cmp     0x50009, d1
484191e4: c8 58                 beq     0x4841923c
484191e6: fc c9 98 00 06 00     cmp     0x60098, d1
484191ec: c8 70                 beq     0x4841925c
484191ee: fc c9 15 00 05 00     cmp     0x50015, d1
484191f4: c9 05                 bne     0x484191f9
484191f6: cc 9e 00              jmp     0x48419294
484191f9: cc f8 00              jmp     0x484192f1
484191fc: dd 1e 47 01 00 00 00  call    0x4842d91a, 0, 0
48419203: 92                    mov     a0, a2
48419204: 9f 28                 mov     0x28, a3
48419206: f1 7b                 add     a2, a3
48419208: 73                    mov     (a3), d0
48419209: 04                    clr     d1
4841920a: 46 10                 mov     d1, (0x10, sp)
4841920c: fc cd 42 00 06 00     mov     0x00060042, d1
48419212: dd 6e 1a 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48419219: 42 14                 mov     d0, (0x14, sp)
4841921b: f8 22 2c              mov     (0x2c, a2), a0
4841921e: fc cd 44 00 06 00     mov     0x00060044, d1
48419224: 70                    mov     (a0), d0
48419225: 3c                    mov     sp, a0
48419226: 42 24                 mov     d0, (0x24, sp)
48419228: 5d 4c                 mov     (0x4c, sp), a1
4841922a: 20 14                 add     0x14, a0
4841922c: 47 28                 mov     a1, (0x28, sp)
4841922e: 73                    mov     (a3), d0
4841922f: 43 10                 mov     a0, (0x10, sp)
48419231: dd 4f 1a 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48419238: 00                    clr     d0
48419239: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841923c: 5c 4c                 mov     (0x4c, sp), a0
4841923e: 43 10                 mov     a0, (0x10, sp)
48419240: dd 29 03 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419247: 00                    clr     d0
48419248: 42 10                 mov     d0, (0x10, sp)
4841924a: fc cd 98 00 06 00     mov     0x00060098, d1
48419250: 8c                    mov     d3, d0
48419251: dd 3c 01 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419258: 00                    clr     d0
48419259: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841925c: dd be 46 01 00 00 00  call    0x4842d91a, 0, 0
48419263: 92                    mov     a0, a2
48419264: 22 28                 add     0x28, a2
48419266: 72                    mov     (a2), d0
48419267: 04                    clr     d1
48419268: 46 10                 mov     d1, (0x10, sp)
4841926a: fc cd 42 00 06 00     mov     0x00060042, d1
48419270: dd 10 1a 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
48419277: f1 e3                 mov     d0, a3
48419279: 72                    mov     (a2), d0
4841927a: 04                    clr     d1
4841927b: 46 10                 mov     d1, (0x10, sp)
4841927d: fc cd 43 00 06 00     mov     0x00060043, d1
48419283: dd fd 19 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841928a: 1c                    exthu   d0
4841928b: 9c                    mov     a3, a0
4841928c: cd 8e 36 a0 1c        call    0x4841c91a, [d2,a2], 0x1c
48419291: 00                    clr     d0
48419292: ca 6a                 bra     0x484192fc
48419294: 5e 4c                 mov     (0x4c, sp), a2
48419296: 8a 28                 mov     0x28, d2
48419298: 4b 10                 mov     a2, (0x10, sp)
4841929a: dd cf 02 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484192a1: 8c                    mov     d3, d0
484192a2: dd 78 46 01 00 00 00  call    0x4842d91a, 0, 0
484192a9: 93                    mov     a0, a3
484192aa: f1 5e                 add     a3, d2
484192ac: f1 e8                 mov     d2, a0
484192ae: 70                    mov     (a0), d0
484192af: 04                    clr     d1
484192b0: 46 10                 mov     d1, (0x10, sp)
484192b2: fc cd 42 00 06 00     mov     0x00060042, d1
484192b8: dd c8 19 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
484192bf: 76                    mov     (a2), d1
484192c0: a4                    cmp     d1, d0
484192c1: c9 2d                 bne     0x484192ee
484192c3: f8 22 10              mov     (0x10, a2), a0
484192c6: f8 27 2c              mov     (0x2c, a3), a1
484192c9: fc cd 78 00 06 00     mov     0x00060078, d1
484192cf: f0 11                 mov     a0, (a1)
484192d1: f1 e9                 mov     d2, a1
484192d3: 71                    mov     (a1), d0
484192d4: 43 10                 mov     a0, (0x10, sp)
484192d6: dd aa 19 01 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
484192dd: 00                    clr     d0
484192de: 42 10                 mov     d0, (0x10, sp)
484192e0: fc cd b4 00 06 00     mov     0x000600b4, d1
484192e6: 8c                    mov     d3, d0
484192e7: dd a6 00 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484192ee: 00                    clr     d0
484192ef: ca 0d                 bra     0x484192fc
484192f1: 5c 4c                 mov     (0x4c, sp), a0
484192f3: 43 10                 mov     a0, (0x10, sp)
484192f5: dd 74 02 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484192fc: df f0 3c              ret     [d2,d3,a2,a3], 0x3c

AcTempoBoxProc:
484192ff: cf e0                 movm    [d2,d3,a2], (sp)
48419301: f8 fe ec              add     -0x14, sp
48419304: 83                    mov     d0, d3
48419305: 86                    mov     d1, d2
48419306: fc ca 01 00 05 00     cmp     0x50001, d2
4841930c: c8 1c                 beq     0x48419328
4841930e: fc ca b2 00 06 00     cmp     0x600b2, d2
48419314: c8 32                 beq     0x48419346
48419316: fc ca 3a 00 06 00     cmp     0x6003a, d2
4841931c: c8 49                 beq     0x48419365
4841931e: fc ca 14 00 05 00     cmp     0x50014, d2
48419324: c8 4d                 beq     0x48419371
48419326: ca 62                 bra     0x48419388
48419328: 5e 30                 mov     (0x30, sp), a2
4841932a: 4b 10                 mov     a2, (0x10, sp)
4841932c: cd 6f 00 a0 24        call    0x4841939b, [d2,a2], 0x24
48419331: 80 01                 mov     1, d0
48419333: cd aa ea 00 14        call    0x48417ddd, 0, 0x14
48419338: 4b 10                 mov     a2, (0x10, sp)
4841933a: 89                    mov     d2, d1
4841933b: 8c                    mov     d3, d0
4841933c: dd 2d 02 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419343: 00                    clr     d0
48419344: ca 4f                 bra     0x48419393
48419346: 5c 30                 mov     (0x30, sp), a0
48419348: 43 10                 mov     a0, (0x10, sp)
4841934a: dd 1f 02 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419351: 00                    clr     d0
48419352: 42 10                 mov     d0, (0x10, sp)
48419354: fc cd b4 00 06 00     mov     0x000600b4, d1
4841935a: 8c                    mov     d3, d0
4841935b: dd 32 00 01 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419362: 00                    clr     d0
48419363: ca 30                 bra     0x48419393
48419365: 5c 30                 mov     (0x30, sp), a0
48419367: 43 10                 mov     a0, (0x10, sp)
48419369: cd 32 00 a0 24        call    0x4841939b, [d2,a2], 0x24
4841936e: 00                    clr     d0
4841936f: ca 24                 bra     0x48419393
48419371: 5e 30                 mov     (0x30, sp), a2
48419373: 4b 10                 mov     a2, (0x10, sp)
48419375: dd f4 01 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841937c: 4b 10                 mov     a2, (0x10, sp)
4841937e: 89                    mov     d2, d1
4841937f: 8c                    mov     d3, d0
48419380: cd 1b 00 a0 24        call    0x4841939b, [d2,a2], 0x24
48419385: 00                    clr     d0
48419386: ca 0d                 bra     0x48419393
48419388: 5c 30                 mov     (0x30, sp), a0
4841938a: 43 10                 mov     a0, (0x10, sp)
4841938c: dd dd 01 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419393: df e0 20              ret     [d2,d3,a2], 0x20
48419396: cf a0                 movm    [d2,a2], (sp)
48419398: f8 fe e4              add     -0x1c, sp
4841939b: fc c9 01 00 05 00     cmp     0x50001, d1
484193a1: c8 18                 beq     0x484193b9
484193a3: fc c9 3a 00 06 00     cmp     0x6003a, d1
484193a9: c8 2e                 beq     0x484193d7
484193ab: fc c9 14 00 05 00     cmp     0x50014, d1
484193b1: c9 05                 bne     0x484193b6
484193b3: cc c1 00              jmp     0x48419474
484193b6: cc e8 00              jmp     0x4841949e
484193b9: 80 04                 mov     4, d0
484193bb: cd 54 30 80 18        call    0x4841c40f, [d2], 0x18
484193c0: 2c 20 20              mov     0x2020, d0
484193c3: cd 4c 30 80 18        call    0x4841c40f, [d2], 0x18
484193c8: fc cc 00 c0 00 00     mov     0x0000c000, d0
484193ce: cd 41 30 80 18        call    0x4841c40f, [d2], 0x18
484193d3: 00                    clr     d0
484193d4: df a0 24              ret     [d2,a2], 0x24
484193d7: 80 78                 mov     0x78, d0
484193d9: 42 14                 mov     d0, (0x14, sp)
484193db: 00                    clr     d0
484193dc: 42 18                 mov     d0, (0x18, sp)
484193de: 80 04                 mov     4, d0
484193e0: 3c                    mov     sp, a0
484193e1: 20 14                 add     0x14, a0
484193e3: dd 65 b5 bf 03 e0 24  call    0x4c014948, [d2,d3,a2], 0x24
484193ea: 2c 20 20              mov     0x2020, d0
484193ed: 3c                    mov     sp, a0
484193ee: 20 18                 add     0x18, a0
484193f0: dd 58 b5 bf 03 e0 24  call    0x4c014948, [d2,d3,a2], 0x24
484193f7: dd 7e cd 01 00 00 10  call    0x48436175, 0, 0x10
484193fe: 14                    extbu   d0
484193ff: a0 00                 cmp     0, d0
48419401: c8 3e                 beq     0x4841943f
48419403: 58 18                 mov     (0x18, sp), d0
48419405: f8 e0 ff              and     0xff, d0
48419408: 14                    extbu   d0
48419409: a0 00                 cmp     0, d0
4841940b: c9 23                 bne     0x4841942e
4841940d: 5d 34                 mov     (0x34, sp), a1
4841940f: fc cc 84 f0 59 48     mov     0x4859f084, d0
48419415: 47 08                 mov     a1, (8, sp)
48419417: 42 0c                 mov     d0, (0xc, sp)
48419419: 58 14                 mov     (0x14, sp), d0
4841941b: 85 03                 mov     3, d1
4841941d: e0                    add     d0, d0
4841941e: 08                    clr     d2
4841941f: f2 fa                 mov     d2, mdr
48419421: f2 74                 divu    d1, d0
48419423: 42 10                 mov     d0, (0x10, sp)
48419425: dd 23 86 be 03 20 20  call    0x4c001a48, [a2], 0x20
4841942c: ca 45                 bra     0x48419471
4841942e: fc dd 8c f0 59 48     mov     0x4859f08c, a1
48419434: 5c 34                 mov     (0x34, sp), a0
48419436: dd 1b 9c be 03 20 04  call    0x4c003051, [a2], 4
4841943d: ca 34                 bra     0x48419471
4841943f: 58 18                 mov     (0x18, sp), d0
48419441: f8 e0 ff              and     0xff, d0
48419444: 14                    extbu   d0
48419445: a0 00                 cmp     0, d0
48419447: c9 1b                 bne     0x48419462
48419449: 5d 34                 mov     (0x34, sp), a1
4841944b: fc cc 94 f0 59 48     mov     0x4859f094, d0
48419451: 47 08                 mov     a1, (8, sp)
48419453: 42 0c                 mov     d0, (0xc, sp)
48419455: 58 14                 mov     (0x14, sp), d0
48419457: 42 10                 mov     d0, (0x10, sp)
48419459: dd ef 85 be 03 20 20  call    0x4c001a48, [a2], 0x20
48419460: ca 11                 bra     0x48419471
48419462: fc dd 9c f0 59 48     mov     0x4859f09c, a1
48419468: 5c 34                 mov     (0x34, sp), a0
4841946a: dd e7 9b be 03 20 04  call    0x4c003051, [a2], 4
48419471: 00                    clr     d0
48419472: ca 2d                 bra     0x4841949f
48419474: 5c 34                 mov     (0x34, sp), a0
48419476: 74                    mov     (a0), d1
48419477: a5 04                 cmp     4, d1
48419479: c8 12                 beq     0x4841948b
4841947b: 74                    mov     (a0), d1
4841947c: fa c9 20 20           cmp     0x2020, d1
48419480: c8 0b                 beq     0x4841948b
48419482: 74                    mov     (a0), d1
48419483: fc c9 00 c0 00 00     cmp     0xc000, d1
48419489: c9 12                 bne     0x4841949b
4841948b: 04                    clr     d1
4841948c: 46 10                 mov     d1, (0x10, sp)
4841948e: fc cd b4 00 06 00     mov     0x000600b4, d1
48419494: dd f9 fe 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841949b: 00                    clr     d0
4841949c: ca 03                 bra     0x4841949f
4841949e: 00                    clr     d0
4841949f: df a0 24              ret     [d2,a2], 0x24

PsRadioBoxProc:
484194a2: cf f0                 movm    [d2,d3,a2,a3], (sp)
484194a4: f8 fe b8              add     -0x48, sp
484194a7: 83                    mov     d0, d3
484194a8: 86                    mov     d1, d2
484194a9: fc ca 05 00 05 00     cmp     0x50005, d2
484194af: c2 05                 bge     0x484194b4
484194b1: cc c2 03              jmp     0x48419873
484194b4: fc ca b4 00 06 00     cmp     0x600b4, d2
484194ba: c3 05                 ble     0x484194bf
484194bc: cc b7 03              jmp     0x48419873
484194bf: fc dd b0 1a 5a 48     mov     0x485a1ab0, a1
484194c5: 80 0f                 mov     0xf, d0
484194c7: fc cd fc ff fa ff     mov     0xfffafffc, d1
484194cd: e9                    add     d2, d1
484194ce: f2 04                 and     d1, d0
484194d0: f8 c0 03              asl     3, d0
484194d3: 94                    mov     a1, a0
484194d4: f1 60                 add     d0, a0
484194d6: 70                    mov     (a0), d0
484194d7: a4                    cmp     d1, d0
484194d8: c8 18                 beq     0x484194f0
484194da: db                    setlb
484194db: a0 00                 cmp     0, d0
484194dd: c9 05                 bne     0x484194e2
484194df: cc 94 03              jmp     0x48419873
484194e2: 20 08                 add     8, a0
484194e4: fc d8 30 1b 5a 48     cmp     0x485a1b30, a0
484194ea: c4 03                 bcs     0x484194ed
484194ec: 94                    mov     a1, a0
484194ed: 70                    mov     (a0), d0
484194ee: a4                    cmp     d1, d0
484194ef: d9                    lne
484194f0: f8 20 04              mov     (4, a0), a0
484194f3: f0 f4                 jmp     (a0)
484194f5: 5c 68                 mov     (0x68, sp), a0
484194f7: 8c                    mov     d3, d0
484194f8: 43 10                 mov     a0, (0x10, sp)
484194fa: 89                    mov     d2, d1
484194fb: dd 6e 00 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419502: 8c                    mov     d3, d0
48419503: dd 17 44 01 00 00 00  call    0x4842d91a, 0, 0
4841950a: 92                    mov     a0, a2
4841950b: 22 28                 add     0x28, a2
4841950d: f0 62                 movhu   (a2), d0
4841950f: 3c                    mov     sp, a0
48419510: 20 3c                 add     0x3c, a0
48419512: cd 15 e6 00 10        call    0x48417b27, 0, 0x10
48419517: f8 bc 3e              movhu   (0x3e, sp), d0
4841951a: 18                    exth    d0
4841951b: fa c8 ef 00           cmp     0xef, d0
4841951f: c8 09                 beq     0x48419528
48419521: f0 62                 movhu   (a2), d0
48419523: cd fd 42 f0 48        call    0x4841d820, [d2,d3,a2,a3], 0x48
48419528: 00                    clr     d0
48419529: 42 10                 mov     d0, (0x10, sp)
4841952b: 8c                    mov     d3, d0
4841952c: fc cd b4 00 06 00     mov     0x000600b4, d1
48419532: dd 5b fe 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419539: 00                    clr     d0
4841953a: 42 10                 mov     d0, (0x10, sp)
4841953c: fc cd b3 00 06 00     mov     0x000600b3, d1
48419542: 8c                    mov     d3, d0
48419543: dd 4a fe 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841954a: 00                    clr     d0
4841954b: df f0 58              ret     [d2,d3,a2,a3], 0x58
4841954e: 5f 68                 mov     (0x68, sp), a3
48419550: 8c                    mov     d3, d0
48419551: 4f 10                 mov     a3, (0x10, sp)
48419553: 89                    mov     d2, d1
48419554: dd 15 00 01 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841955b: 3c                    mov     sp, a0
4841955c: f1 d0                 mov     a0, d0
4841955e: 28 40                 add     0x40, d0
48419560: 42 28                 mov     d0, (0x28, sp)
48419562: 8c                    mov     d3, d0
48419563: 5c 28                 mov     (0x28, sp), a0
48419565: cd 80 d5 00 14        call    0x48416ae5, 0, 0x14
4841956a: 3c                    mov     sp, a0
4841956b: f1 d0                 mov     a0, d0
4841956d: 28 3c                 add     0x3c, d0
4841956f: 42 30                 mov     d0, (0x30, sp)
48419571: 5c 28                 mov     (0x28, sp), a0
48419573: f1 e1                 mov     d0, a1
48419575: cd be d8 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841957a: 8c                    mov     d3, d0
4841957b: dd 9f 43 01 00 00 00  call    0x4842d91a, 0, 0
48419582: 43 34                 mov     a0, (0x34, sp)
48419584: 00                    clr     d0
48419585: 42 10                 mov     d0, (0x10, sp)
48419587: 8c                    mov     d3, d0
48419588: fc cd af 00 06 00     mov     0x000600af, d1
4841958e: dd ff fd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419595: 42 2c                 mov     d0, (0x2c, sp)
48419597: 00                    clr     d0
48419598: 42 10                 mov     d0, (0x10, sp)
4841959a: 8c                    mov     d3, d0
4841959b: fc cd a3 00 06 00     mov     0x000600a3, d1
484195a1: dd ec fd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484195a8: 82                    mov     d0, d2
484195a9: 00                    clr     d0
484195aa: 42 10                 mov     d0, (0x10, sp)
484195ac: fc cd ae 00 06 00     mov     0x000600ae, d1
484195b2: 8c                    mov     d3, d0
484195b3: dd da fd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484195ba: f8 93 38              movhu   d0, (0x38, sp)
484195bd: 2c 00 01              mov     0x100, d0
484195c0: cd 6a d0 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
484195c5: 92                    mov     a0, a2
484195c6: bf 00                 cmp     0, a3
484195c8: c9 22                 bne     0x484195ea
484195ca: 8c                    mov     d3, d0
484195cb: 4b 10                 mov     a2, (0x10, sp)
484195cd: fc cd 3a 00 06 00     mov     0x0006003a, d1
484195d3: dd ba fd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484195da: f0 42                 movbu   (a2), d0
484195dc: a0 00                 cmp     0, d0
484195de: c9 15                 bne     0x484195f3
484195e0: 98                    mov     a2, a0
484195e1: cd fd d0 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
484195e6: 00                    clr     d0
484195e7: df f0 58              ret     [d2,d3,a2,a3], 0x58
484195ea: 98                    mov     a2, a0
484195eb: 9d                    mov     a3, a1
484195ec: dd 65 9a be 03 20 04  call    0x4c003051, [a2], 4
484195f3: cd d9 e0 00 00        call    0x484176cc, 0, 0
484195f8: ac                    cmp     d3, d0
484195f9: c9 25                 bne     0x4841961e
484195fb: 1a                    exth    d2
484195fc: 4b 10                 mov     a2, (0x10, sp)
484195fe: 4a 1c                 mov     d2, (0x1c, sp)
48419600: 5c 34                 mov     (0x34, sp), a0
48419602: f8 40 26              movbu   (0x26, a0), d0
48419605: 42 20                 mov     d0, (0x20, sp)
48419607: 80 01                 mov     1, d0
48419609: 42 24                 mov     d0, (0x24, sp)
4841960b: f8 bd 38              movhu   (0x38, sp), d1
4841960e: 5c 28                 mov     (0x28, sp), a0
48419610: 5d 30                 mov     (0x30, sp), a1
48419612: 58 2c                 mov     (0x2c, sp), d0
48419614: 19                    exth    d1
48419615: dd 08 c5 00 00 f0 48  call    0x48425b1d, [d2,d3,a2,a3], 0x48
4841961c: ca 22                 bra     0x4841963e
4841961e: 1a                    exth    d2
4841961f: 4b 10                 mov     a2, (0x10, sp)
48419621: 4a 1c                 mov     d2, (0x1c, sp)
48419623: 5c 34                 mov     (0x34, sp), a0
48419625: f8 40 26              movbu   (0x26, a0), d0
48419628: 42 20                 mov     d0, (0x20, sp)
4841962a: 00                    clr     d0
4841962b: 42 24                 mov     d0, (0x24, sp)
4841962d: f8 bd 38              movhu   (0x38, sp), d1
48419630: 5c 28                 mov     (0x28, sp), a0
48419632: 5d 30                 mov     (0x30, sp), a1
48419634: 58 2c                 mov     (0x2c, sp), d0
48419636: 19                    exth    d1
48419637: dd e6 c4 00 00 f0 48  call    0x48425b1d, [d2,d3,a2,a3], 0x48
4841963e: 98                    mov     a2, a0
4841963f: cd 9f d0 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
48419644: 00                    clr     d0
48419645: df f0 58              ret     [d2,d3,a2,a3], 0x58
48419648: 8c                    mov     d3, d0
48419649: dd d1 42 01 00 00 00  call    0x4842d91a, 0, 0
48419650: 92                    mov     a0, a2
48419651: cd 7b e0 00 00        call    0x484176cc, 0, 0
48419656: ac                    cmp     d3, d0
48419657: c9 26                 bne     0x4841967d
48419659: 00                    clr     d0
4841965a: 42 10                 mov     d0, (0x10, sp)
4841965c: 8c                    mov     d3, d0
4841965d: fc cd 4b 00 06 00     mov     0x0006004b, d1
48419663: dd 2a fd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841966a: 00                    clr     d0
4841966b: 42 10                 mov     d0, (0x10, sp)
4841966d: fc cd b4 00 06 00     mov     0x000600b4, d1
48419673: 8c                    mov     d3, d0
48419674: dd 19 fd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841967b: ca 16                 bra     0x48419691
4841967d: f8 22 2c              mov     (0x2c, a2), a0
48419680: fc cd 4b 00 06 00     mov     0x0006004b, d1
48419686: 70                    mov     (a0), d0
48419687: 42 10                 mov     d0, (0x10, sp)
48419689: 8c                    mov     d3, d0
4841968a: dd 03 fd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419691: 00                    clr     d0
48419692: df f0 58              ret     [d2,d3,a2,a3], 0x58
48419695: 5c 68                 mov     (0x68, sp), a0
48419697: 8c                    mov     d3, d0
48419698: 43 10                 mov     a0, (0x10, sp)
4841969a: 89                    mov     d2, d1
4841969b: dd ce fe 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484196a2: cd 2a e0 00 00        call    0x484176cc, 0, 0
484196a7: ac                    cmp     d3, d0
484196a8: c9 15                 bne     0x484196bd
484196aa: 00                    clr     d0
484196ab: 42 10                 mov     d0, (0x10, sp)
484196ad: fc cd b3 00 06 00     mov     0x000600b3, d1
484196b3: 8c                    mov     d3, d0
484196b4: dd d9 fc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484196bb: ca 23                 bra     0x484196de
484196bd: 8c                    mov     d3, d0
484196be: dd 5c 42 01 00 00 00  call    0x4842d91a, 0, 0
484196c5: f8 20 2c              mov     (0x2c, a0), a0
484196c8: 70                    mov     (a0), d0
484196c9: a0 01                 cmp     1, d0
484196cb: c9 13                 bne     0x484196de
484196cd: 00                    clr     d0
484196ce: 42 10                 mov     d0, (0x10, sp)
484196d0: fc cd b3 00 06 00     mov     0x000600b3, d1
484196d6: 8c                    mov     d3, d0
484196d7: dd b6 fc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484196de: 00                    clr     d0
484196df: df f0 58              ret     [d2,d3,a2,a3], 0x58
484196e2: 8c                    mov     d3, d0
484196e3: dd 37 42 01 00 00 00  call    0x4842d91a, 0, 0
484196ea: 5e 68                 mov     (0x68, sp), a2
484196ec: 93                    mov     a0, a3
484196ed: 4b 10                 mov     a2, (0x10, sp)
484196ef: 8c                    mov     d3, d0
484196f0: fc cd 51 00 06 00     mov     0x00060051, d1
484196f6: dd 97 fc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484196fd: a0 00                 cmp     0, d0
484196ff: c8 20                 beq     0x4841971f
48419701: f8 63 1c              movhu   (0x1c, a3), d0
48419704: 18                    exth    d0
48419705: a0 ff                 cmp     -1, d0
48419707: c8 18                 beq     0x4841971f
48419709: 80 01                 mov     1, d0
4841970b: 42 10                 mov     d0, (0x10, sp)
4841970d: fc cd 4a 00 06 00     mov     0x0006004a, d1
48419713: 8c                    mov     d3, d0
48419714: dd 79 fc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841971b: 00                    clr     d0
4841971c: df f0 58              ret     [d2,d3,a2,a3], 0x58
4841971f: 4b 10                 mov     a2, (0x10, sp)
48419721: 89                    mov     d2, d1
48419722: 8c                    mov     d3, d0
48419723: dd 46 fe 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841972a: df f0 58              ret     [d2,d3,a2,a3], 0x58
4841972d: 5e 68                 mov     (0x68, sp), a2
4841972f: 8c                    mov     d3, d0
48419730: 4b 10                 mov     a2, (0x10, sp)
48419732: 89                    mov     d2, d1
48419733: dd 36 fe 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841973a: 8c                    mov     d3, d0
4841973b: dd df 41 01 00 00 00  call    0x4842d91a, 0, 0
48419742: f8 60 1c              movhu   (0x1c, a0), d0
48419745: 18                    exth    d0
48419746: f1 98                 cmp     a2, d0
48419748: c9 1b                 bne     0x48419763
4841974a: f8 20 2c              mov     (0x2c, a0), a0
4841974d: 70                    mov     (a0), d0
4841974e: a0 00                 cmp     0, d0
48419750: c8 13                 beq     0x48419763
48419752: 00                    clr     d0
48419753: 42 10                 mov     d0, (0x10, sp)
48419755: fc cd 4a 00 06 00     mov     0x0006004a, d1
4841975b: 8c                    mov     d3, d0
4841975c: dd 31 fc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419763: 00                    clr     d0
48419764: df f0 58              ret     [d2,d3,a2,a3], 0x58
48419767: 5e 68                 mov     (0x68, sp), a2
48419769: 8c                    mov     d3, d0
4841976a: 4b 10                 mov     a2, (0x10, sp)
4841976c: 89                    mov     d2, d1
4841976d: dd fc fd 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419774: 8c                    mov     d3, d0
48419775: dd a5 41 01 00 00 00  call    0x4842d91a, 0, 0
4841977c: 95 1c                 mov     0x1c, a1
4841977e: f1 71                 add     a0, a1
48419780: f0 61                 movhu   (a1), d0
48419782: 18                    exth    d0
48419783: a0 ff                 cmp     -1, d0
48419785: c8 2e                 beq     0x484197b3
48419787: f0 65                 movhu   (a1), d1
48419789: f1 d8                 mov     a2, d0
4841978b: 19                    exth    d1
4841978c: f8 c4 10              lsr     16, d0
4841978f: fa e0 ff ff           and     0xffff, d0
48419793: 1c                    exthu   d0
48419794: a1                    cmp     d0, d1
48419795: c9 1e                 bne     0x484197b3
48419797: f8 64 30              movhu   (0x30, a0), d1
4841979a: f1 d8                 mov     a2, d0
4841979c: 19                    exth    d1
4841979d: 1c                    exthu   d0
4841979e: a1                    cmp     d0, d1
4841979f: c9 14                 bne     0x484197b3
484197a1: 80 01                 mov     1, d0
484197a3: 42 10                 mov     d0, (0x10, sp)
484197a5: fc cd 4a 00 06 00     mov     0x0006004a, d1
484197ab: 8c                    mov     d3, d0
484197ac: dd e1 fb 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484197b3: 00                    clr     d0
484197b4: df f0 58              ret     [d2,d3,a2,a3], 0x58
484197b7: 8c                    mov     d3, d0
484197b8: dd 62 41 01 00 00 00  call    0x4842d91a, 0, 0
484197bf: 93                    mov     a0, a3
484197c0: 80 2c                 mov     0x2c, d0
484197c2: f1 5c                 add     a3, d0
484197c4: 42 28                 mov     d0, (0x28, sp)
484197c6: f1 e0                 mov     d0, a0
484197c8: f0 00                 mov     (a0), a0
484197ca: 70                    mov     (a0), d0
484197cb: 5c 68                 mov     (0x68, sp), a0
484197cd: f1 90                 cmp     a0, d0
484197cf: c8 52                 beq     0x48419821
484197d1: f1 d2                 mov     a0, d2
484197d3: aa 01                 cmp     1, d2
484197d5: c9 36                 bne     0x4841980b
484197d7: 9a 1c                 mov     0x1c, a2
484197d9: f1 7e                 add     a3, a2
484197db: f0 62                 movhu   (a2), d0
484197dd: fc cd 13 00 05 00     mov     0x00050013, d1
484197e3: 18                    exth    d0
484197e4: 42 10                 mov     d0, (0x10, sp)
484197e6: 80 ff                 mov     -1, d0
484197e8: dd a5 fb 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484197ef: f0 66                 movhu   (a2), d1
484197f1: f8 63 30              movhu   (0x30, a3), d0
484197f4: 1d                    exthu   d1
484197f5: f8 c1 10              asl     16, d1
484197f8: 1c                    exthu   d0
484197f9: e1                    add     d0, d1
484197fa: 46 10                 mov     d1, (0x10, sp)
484197fc: 80 ff                 mov     -1, d0
484197fe: fc cd 21 00 05 00     mov     0x00050021, d1
48419804: dd 89 fb 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841980b: 5c 28                 mov     (0x28, sp), a0
4841980d: 00                    clr     d0
4841980e: f0 00                 mov     (a0), a0
48419810: fc cd b3 00 06 00     mov     0x000600b3, d1
48419816: 68                    mov     d2, (a0)
48419817: 42 10                 mov     d0, (0x10, sp)
48419819: 8c                    mov     d3, d0
4841981a: dd 73 fb 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419821: 00                    clr     d0
48419822: ca 5e                 bra     0x48419880
48419824: 5c 68                 mov     (0x68, sp), a0
48419826: 00                    clr     d0
48419827: f0 50                 movbu   d0, (a0)
48419829: ca 57                 bra     0x48419880
4841982b: 8c                    mov     d3, d0
4841982c: dd ee 40 01 00 00 00  call    0x4842d91a, 0, 0
48419833: f8 00 20              mov     (0x20, a0), d0
48419836: ca 4a                 bra     0x48419880
48419838: 8c                    mov     d3, d0
48419839: dd e1 40 01 00 00 00  call    0x4842d91a, 0, 0
48419840: f8 60 24              movhu   (0x24, a0), d0
48419843: 18                    exth    d0
48419844: ca 3c                 bra     0x48419880
48419846: 8c                    mov     d3, d0
48419847: dd d3 40 01 00 00 00  call    0x4842d91a, 0, 0
4841984e: 92                    mov     a0, a2
4841984f: 5c 68                 mov     (0x68, sp), a0
48419851: fc cc 24 00 0d 00     mov     0x000d0024, d0
48419857: 43 10                 mov     a0, (0x10, sp)
48419859: fc cd 29 00 06 00     mov     0x00060029, d1
4841985f: dd 2e fb 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419866: f8 66 28              movhu   (0x28, a2), d1
48419869: a1                    cmp     d0, d1
4841986a: c9 06                 bne     0x48419870
4841986c: 80 01                 mov     1, d0
4841986e: ca 12                 bra     0x48419880
48419870: 00                    clr     d0
48419871: ca 0f                 bra     0x48419880
48419873: 5c 68                 mov     (0x68, sp), a0
48419875: 89                    mov     d2, d1
48419876: 43 10                 mov     a0, (0x10, sp)
48419878: 8c                    mov     d3, d0
48419879: dd f0 fc 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419880: df f0 58              ret     [d2,d3,a2,a3], 0x58

AcStrRadioBoxProc:
48419883: cf 20                 movm    [a2], (sp)
48419885: f8 fe ec              add     -0x14, sp
48419888: fc c9 3a 00 06 00     cmp     0x6003a, d1
4841988e: c9 18                 bne     0x484198a6
48419890: dd 8a 40 01 00 00 00  call    0x4842d91a, 0, 0
48419897: f8 24 34              mov     (0x34, a0), a1
4841989a: 5c 28                 mov     (0x28, sp), a0
4841989c: dd b5 97 be 03 20 04  call    0x4c003051, [a2], 4
484198a3: 00                    clr     d0
484198a4: ca 0d                 bra     0x484198b1
484198a6: 5c 28                 mov     (0x28, sp), a0
484198a8: 43 10                 mov     a0, (0x10, sp)
484198aa: dd bf fc 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
484198b1: df 20 18              ret     [a2], 0x18

PsListBoxProc:
484198b4: cf f0                 movm    [d2,d3,a2,a3], (sp)
484198b6: f8 fe 98              add     -0x68, sp
484198b9: 42 80                 mov     d0, (0x80, sp)
484198bb: fc c9 24 00 05 00     cmp     0x50024, d1
484198c1: c2 05                 bge     0x484198c6
484198c3: cc 61 05              jmp     0x48419e24
484198c6: fc c9 b4 00 06 00     cmp     0x600b4, d1
484198cc: c3 05                 ble     0x484198d1
484198ce: cc 56 05              jmp     0x48419e24
484198d1: 80 0f                 mov     0xf, d0
484198d3: fc ce dd ff fa ff     mov     0xfffaffdd, d2
484198d9: e6                    add     d1, d2
484198da: f2 08                 and     d2, d0
484198dc: f8 c0 03              asl     3, d0
484198df: f1 e0                 mov     d0, a0
484198e1: fc de 30 1b 5a 48     mov     0x485a1b30, a2
484198e7: f1 78                 add     a2, a0
484198e9: 70                    mov     (a0), d0
484198ea: a8                    cmp     d2, d0
484198eb: c8 18                 beq     0x48419903
484198ed: db                    setlb
484198ee: a0 00                 cmp     0, d0
484198f0: c9 05                 bne     0x484198f5
484198f2: cc 32 05              jmp     0x48419e24
484198f5: 20 08                 add     8, a0
484198f7: fc d8 b0 1b 5a 48     cmp     0x485a1bb0, a0
484198fd: c4 03                 bcs     0x48419900
484198ff: 98                    mov     a2, a0
48419900: 70                    mov     (a0), d0
48419901: a8                    cmp     d2, d0
48419902: d9                    lne
48419903: f8 20 04              mov     (4, a0), a0
48419906: f0 f4                 jmp     (a0)
48419908: 5c 88                 mov     (0x88, sp), a0
4841990a: 43 10                 mov     a0, (0x10, sp)
4841990c: 58 80                 mov     (0x80, sp), d0
4841990e: dd 5b fc 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419915: 58 80                 mov     (0x80, sp), d0
48419917: dd 03 40 01 00 00 00  call    0x4842d91a, 0, 0
4841991e: 20 2c                 add     0x2c, a0
48419920: f0 04                 mov     (a0), a1
48419922: f0 00                 mov     (a0), a0
48419924: f0 69                 movhu   (a1), d2
48419926: 80 ff                 mov     -1, d0
48419928: f0 70                 movhu   d0, (a0)
4841992a: 1a                    exth    d2
4841992b: 00                    clr     d0
4841992c: 42 10                 mov     d0, (0x10, sp)
4841992e: 58 80                 mov     (0x80, sp), d0
48419930: fc cd b4 00 06 00     mov     0x000600b4, d1
48419936: dd 57 fa 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841993d: 4a 10                 mov     d2, (0x10, sp)
4841993f: 58 80                 mov     (0x80, sp), d0
48419941: fc cd b3 00 06 00     mov     0x000600b3, d1
48419947: dd 46 fa 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841994e: 00                    clr     d0
4841994f: df f0 78              ret     [d2,d3,a2,a3], 0x78
48419952: 5e 88                 mov     (0x88, sp), a2
48419954: 4b 10                 mov     a2, (0x10, sp)
48419956: 58 80                 mov     (0x80, sp), d0
48419958: dd 11 fc 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841995f: ba 00                 cmp     0, a2
48419961: c9 1f                 bne     0x48419980
48419963: 2c 00 02              mov     0x200, d0
48419966: cd c4 cc b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841996b: 43 2c                 mov     a0, (0x2c, sp)
4841996d: 43 10                 mov     a0, (0x10, sp)
4841996f: 58 80                 mov     (0x80, sp), d0
48419971: fc cd 3a 00 06 00     mov     0x0006003a, d1
48419977: dd 16 fa 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841997e: ca 1a                 bra     0x48419998
48419980: 98                    mov     a2, a0
48419981: dd 76 99 be 03 00 00  call    0x4c0032f7, 0, 0
48419988: 40                    inc     d0
48419989: cd a1 cc b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841998e: 43 2c                 mov     a0, (0x2c, sp)
48419990: 99                    mov     a2, a1
48419991: dd c0 96 be 03 20 04  call    0x4c003051, [a2], 4
48419998: 58 80                 mov     (0x80, sp), d0
4841999a: dd 80 3f 01 00 00 00  call    0x4842d91a, 0, 0
484199a1: 43 54                 mov     a0, (0x54, sp)
484199a3: 00                    clr     d0
484199a4: 42 10                 mov     d0, (0x10, sp)
484199a6: 58 80                 mov     (0x80, sp), d0
484199a8: fc cd af 00 06 00     mov     0x000600af, d1
484199ae: dd df f9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484199b5: 42 50                 mov     d0, (0x50, sp)
484199b7: 00                    clr     d0
484199b8: 42 10                 mov     d0, (0x10, sp)
484199ba: 58 80                 mov     (0x80, sp), d0
484199bc: fc cd a3 00 06 00     mov     0x000600a3, d1
484199c2: dd cb f9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484199c9: fc cd ae 00 06 00     mov     0x000600ae, d1
484199cf: f1 e2                 mov     d0, a2
484199d1: 00                    clr     d0
484199d2: 42 10                 mov     d0, (0x10, sp)
484199d4: 58 80                 mov     (0x80, sp), d0
484199d6: dd b7 f9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
484199dd: 3c                    mov     sp, a0
484199de: 83                    mov     d0, d3
484199df: f1 d0                 mov     a0, d0
484199e1: 28 5c                 add     0x5c, d0
484199e3: 42 40                 mov     d0, (0x40, sp)
484199e5: 58 80                 mov     (0x80, sp), d0
484199e7: 5c 40                 mov     (0x40, sp), a0
484199e9: cd fc d0 00 14        call    0x48416ae5, 0, 0x14
484199ee: f8 bc 62              movhu   (0x62, sp), d0
484199f1: f8 be 5e              movhu   (0x5e, sp), d2
484199f4: 59 54                 mov     (0x54, sp), d1
484199f6: 18                    exth    d0
484199f7: 1a                    exth    d2
484199f8: 29 28                 add     0x28, d1
484199fa: 46 4c                 mov     d1, (0x4c, sp)
484199fc: f1 e4                 mov     d1, a0
484199fe: f0 64                 movhu   (a0), d1
48419a00: f1 08                 sub     d2, d0
48419a02: dd d3 7f be 03 00 00  call    0x4c0019d5, 0, 0
48419a09: 81                    mov     d0, d1
48419a0a: f8 bc 5c              movhu   (0x5c, sp), d0
48419a0d: 19                    exth    d1
48419a0e: 18                    exth    d0
48419a0f: 40                    inc     d0
48419a10: f8 93 5c              movhu   d0, (0x5c, sp)
48419a13: f8 bc 60              movhu   (0x60, sp), d0
48419a16: 08                    clr     d2
48419a17: 18                    exth    d0
48419a18: 28 ff                 add     -1, d0
48419a1a: f8 93 60              movhu   d0, (0x60, sp)
48419a1d: f8 bc 5e              movhu   (0x5e, sp), d0
48419a20: 46 48                 mov     d1, (0x48, sp)
48419a22: 18                    exth    d0
48419a23: e4                    add     d1, d0
48419a24: 40                    inc     d0
48419a25: f8 93 62              movhu   d0, (0x62, sp)
48419a28: 00                    clr     d0
48419a29: 42 30                 mov     d0, (0x30, sp)
48419a2b: 5c 4c                 mov     (0x4c, sp), a0
48419a2d: f0 60                 movhu   (a0), d0
48419a2f: a8                    cmp     d2, d0
48419a30: c1 05                 bgt     0x48419a35
48419a32: cc cc 00              jmp     0x48419afe
48419a35: 58 54                 mov     (0x54, sp), d0
48419a37: 3c                    mov     sp, a0
48419a38: 1b                    exth    d3
48419a39: 4e 44                 mov     d3, (0x44, sp)
48419a3b: 28 26                 add     0x26, d0
48419a3d: 42 38                 mov     d0, (0x38, sp)
48419a3f: f1 d0                 mov     a0, d0
48419a41: 28 64                 add     0x64, d0
48419a43: 42 34                 mov     d0, (0x34, sp)
48419a45: f1 d8                 mov     a2, d0
48419a47: 18                    exth    d0
48419a48: 42 3c                 mov     d0, (0x3c, sp)
48419a4a: 5c 2c                 mov     (0x2c, sp), a0
48419a4c: 89                    mov     d2, d1
48419a4d: 1d                    exthu   d1
48419a4e: 5b 2c                 mov     (0x2c, sp), d3
48419a50: f4                    movbu   (d1, a0), d0
48419a51: 04                    clr     d1
48419a52: e7                    add     d1, d3
48419a53: a0 00                 cmp     0, d0
48419a55: c8 1f                 beq     0x48419a74
48419a57: db                    setlb
48419a58: 5c 2c                 mov     (0x2c, sp), a0
48419a5a: f4                    movbu   (d1, a0), d0
48419a5b: 04                    clr     d1
48419a5c: a0 7c                 cmp     0x7c, d0
48419a5e: c9 0b                 bne     0x48419a69
48419a60: 5c 2c                 mov     (0x2c, sp), a0
48419a62: 1e                    exthu   d2
48419a63: 48                    inc     d2
48419a64: 00                    clr     d0
48419a65: f4                    movbu   d0, (d1, a0)
48419a66: 44                    inc     d1
48419a67: ca 0d                 bra     0x48419a74
48419a69: 5c 2c                 mov     (0x2c, sp), a0
48419a6b: 1e                    exthu   d2
48419a6c: 48                    inc     d2
48419a6d: 89                    mov     d2, d1
48419a6e: 1d                    exthu   d1
48419a6f: f4                    movbu   (d1, a0), d0
48419a70: 04                    clr     d1
48419a71: a0 00                 cmp     0, d0
48419a73: d9                    lne
48419a74: 5c 40                 mov     (0x40, sp), a0
48419a76: 5d 34                 mov     (0x34, sp), a1
48419a78: cd bb d3 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
48419a7d: 5c 54                 mov     (0x54, sp), a0
48419a7f: 59 30                 mov     (0x30, sp), d1
48419a81: f8 20 2c              mov     (0x2c, a0), a0
48419a84: f0 60                 movhu   (a0), d0
48419a86: 18                    exth    d0
48419a87: a4                    cmp     d1, d0
48419a88: c9 34                 bne     0x48419abc
48419a8a: 5f 40                 mov     (0x40, sp), a3
48419a8c: 5e 34                 mov     (0x34, sp), a2
48419a8e: 4e 10                 mov     d3, (0x10, sp)
48419a90: 58 44                 mov     (0x44, sp), d0
48419a92: 42 28                 mov     d0, (0x28, sp)
48419a94: 58 3c                 mov     (0x3c, sp), d0
48419a96: 42 1c                 mov     d0, (0x1c, sp)
48419a98: 5c 38                 mov     (0x38, sp), a0
48419a9a: f0 40                 movbu   (a0), d0
48419a9c: 42 20                 mov     d0, (0x20, sp)
48419a9e: cd 2e dc 00 00        call    0x484176cc, 0, 0
48419aa3: 5b 80                 mov     (0x80, sp), d3
48419aa5: 04                    clr     d1
48419aa6: ac                    cmp     d3, d0
48419aa7: c9 04                 bne     0x48419aab
48419aa9: 85 01                 mov     1, d1
48419aab: 46 24                 mov     d1, (0x24, sp)
48419aad: 58 50                 mov     (0x50, sp), d0
48419aaf: 59 28                 mov     (0x28, sp), d1
48419ab1: 99                    mov     a2, a1
48419ab2: 9c                    mov     a3, a0
48419ab3: dd 6a c0 00 00 f0 48  call    0x48425b1d, [d2,d3,a2,a3], 0x48
48419aba: ca 20                 bra     0x48419ada
48419abc: 4e 10                 mov     d3, (0x10, sp)
48419abe: 58 3c                 mov     (0x3c, sp), d0
48419ac0: 42 1c                 mov     d0, (0x1c, sp)
48419ac2: 5c 38                 mov     (0x38, sp), a0
48419ac4: f0 40                 movbu   (a0), d0
48419ac6: 42 20                 mov     d0, (0x20, sp)
48419ac8: 00                    clr     d0
48419ac9: 42 24                 mov     d0, (0x24, sp)
48419acb: 5c 40                 mov     (0x40, sp), a0
48419acd: 5d 34                 mov     (0x34, sp), a1
48419acf: 58 50                 mov     (0x50, sp), d0
48419ad1: 59 44                 mov     (0x44, sp), d1
48419ad3: dd 4a c0 00 00 f0 48  call    0x48425b1d, [d2,d3,a2,a3], 0x48
48419ada: 59 48                 mov     (0x48, sp), d1
48419adc: 58 30                 mov     (0x30, sp), d0
48419ade: 5c 4c                 mov     (0x4c, sp), a0
48419ae0: 40                    inc     d0
48419ae1: 1c                    exthu   d0
48419ae2: 42 30                 mov     d0, (0x30, sp)
48419ae4: f8 bc 5e              movhu   (0x5e, sp), d0
48419ae7: 18                    exth    d0
48419ae8: e4                    add     d1, d0
48419ae9: f8 93 5e              movhu   d0, (0x5e, sp)
48419aec: f8 bc 62              movhu   (0x62, sp), d0
48419aef: 18                    exth    d0
48419af0: e4                    add     d1, d0
48419af1: f8 93 62              movhu   d0, (0x62, sp)
48419af4: f0 60                 movhu   (a0), d0
48419af6: 59 30                 mov     (0x30, sp), d1
48419af8: a1                    cmp     d0, d1
48419af9: c2 05                 bge     0x48419afe
48419afb: cc 4f ff              jmp     0x48419a4a
48419afe: 5c 2c                 mov     (0x2c, sp), a0
48419b00: cd de cb f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
48419b05: 00                    clr     d0
48419b06: df f0 78              ret     [d2,d3,a2,a3], 0x78
48419b09: 58 80                 mov     (0x80, sp), d0
48419b0b: dd 0f 3e 01 00 00 00  call    0x4842d91a, 0, 0
48419b12: 43 34                 mov     a0, (0x34, sp)
48419b14: 2c 00 02              mov     0x200, d0
48419b17: cd 13 cb b0 28        call    0x4841662a, [d2,a2,a3], 0x28
48419b1c: 00                    clr     d0
48419b1d: 42 10                 mov     d0, (0x10, sp)
48419b1f: 58 80                 mov     (0x80, sp), d0
48419b21: fc cd af 00 06 00     mov     0x000600af, d1
48419b27: 92                    mov     a0, a2
48419b28: dd 65 f8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419b2f: 42 38                 mov     d0, (0x38, sp)
48419b31: 00                    clr     d0
48419b32: 42 10                 mov     d0, (0x10, sp)
48419b34: 58 80                 mov     (0x80, sp), d0
48419b36: fc cd a3 00 06 00     mov     0x000600a3, d1
48419b3c: dd 51 f8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419b43: f8 93 58              movhu   d0, (0x58, sp)
48419b46: 00                    clr     d0
48419b47: 42 10                 mov     d0, (0x10, sp)
48419b49: 58 80                 mov     (0x80, sp), d0
48419b4b: fc cd ae 00 06 00     mov     0x000600ae, d1
48419b51: dd 3c f8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419b58: f8 93 5a              movhu   d0, (0x5a, sp)
48419b5b: 58 34                 mov     (0x34, sp), d0
48419b5d: 28 2c                 add     0x2c, d0
48419b5f: 42 2c                 mov     d0, (0x2c, sp)
48419b61: f1 e0                 mov     d0, a0
48419b63: f0 00                 mov     (a0), a0
48419b65: f0 60                 movhu   (a0), d0
48419b67: 18                    exth    d0
48419b68: f1 e0                 mov     d0, a0
48419b6a: 58 88                 mov     (0x88, sp), d0
48419b6c: f1 a0                 cmp     d0, a0
48419b6e: c9 05                 bne     0x48419b73
48419b70: cc 16 02              jmp     0x48419d86
48419b73: 5c 2c                 mov     (0x2c, sp), a0
48419b75: f0 00                 mov     (a0), a0
48419b77: f0 60                 movhu   (a0), d0
48419b79: 18                    exth    d0
48419b7a: a0 ff                 cmp     -1, d0
48419b7c: c9 05                 bne     0x48419b81
48419b7e: cc ed 00              jmp     0x48419c6b
48419b81: 3c                    mov     sp, a0
48419b82: f1 d0                 mov     a0, d0
48419b84: 28 5c                 add     0x5c, d0
48419b86: 42 30                 mov     d0, (0x30, sp)
48419b88: 58 80                 mov     (0x80, sp), d0
48419b8a: 5c 30                 mov     (0x30, sp), a0
48419b8c: cd 59 cf 00 14        call    0x48416ae5, 0, 0x14
48419b91: f8 bc 62              movhu   (0x62, sp), d0
48419b94: f8 be 5e              movhu   (0x5e, sp), d2
48419b97: 5c 34                 mov     (0x34, sp), a0
48419b99: 18                    exth    d0
48419b9a: 1a                    exth    d2
48419b9b: f8 64 28              movhu   (0x28, a0), d1
48419b9e: f1 08                 sub     d2, d0
48419ba0: dd 35 7e be 03 00 00  call    0x4c0019d5, 0, 0
48419ba7: 5c 2c                 mov     (0x2c, sp), a0
48419ba9: f8 bd 5e              movhu   (0x5e, sp), d1
48419bac: f0 00                 mov     (a0), a0
48419bae: 82                    mov     d0, d2
48419baf: f0 60                 movhu   (a0), d0
48419bb1: 1a                    exth    d2
48419bb2: 18                    exth    d0
48419bb3: 19                    exth    d1
48419bb4: cb                    nop
48419bb5: cb                    nop
48419bb6: f2 48                 mul     d2, d0
48419bb8: e4                    add     d1, d0
48419bb9: 40                    inc     d0
48419bba: f8 93 5e              movhu   d0, (0x5e, sp)
48419bbd: f8 bc 5c              movhu   (0x5c, sp), d0
48419bc0: 3f                    mov     sp, a3
48419bc1: 18                    exth    d0
48419bc2: 40                    inc     d0
48419bc3: f8 93 5c              movhu   d0, (0x5c, sp)
48419bc6: f8 bc 60              movhu   (0x60, sp), d0
48419bc9: 23 64                 add     0x64, a3
48419bcb: 18                    exth    d0
48419bcc: 28 ff                 add     -1, d0
48419bce: f8 93 60              movhu   d0, (0x60, sp)
48419bd1: f8 bc 5e              movhu   (0x5e, sp), d0
48419bd4: 9d                    mov     a3, a1
48419bd5: 18                    exth    d0
48419bd6: e8                    add     d2, d0
48419bd7: 28 ff                 add     -1, d0
48419bd9: f8 93 62              movhu   d0, (0x62, sp)
48419bdc: 5c 30                 mov     (0x30, sp), a0
48419bde: cd 55 d2 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
48419be3: 4b 10                 mov     a2, (0x10, sp)
48419be5: 58 80                 mov     (0x80, sp), d0
48419be7: fc cd 3a 00 06 00     mov     0x0006003a, d1
48419bed: dd a0 f7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419bf4: 5c 2c                 mov     (0x2c, sp), a0
48419bf6: 08                    clr     d2
48419bf7: f0 00                 mov     (a0), a0
48419bf9: 0c                    clr     d3
48419bfa: f0 64                 movhu   (a0), d1
48419bfc: 19                    exth    d1
48419bfd: a9                    cmp     d2, d1
48419bfe: c0 32                 blt     0x48419c30
48419c00: 89                    mov     d2, d1
48419c01: 1d                    exthu   d1
48419c02: f1 d8                 mov     a2, d0
48419c04: e4                    add     d1, d0
48419c05: 42 28                 mov     d0, (0x28, sp)
48419c07: f4                    movbu   (d1, a2), d0
48419c08: 06 a0 00              movbu   d1, (0x00a0)
48419c0b: c8 19                 beq     0x48419c24
48419c0d: db                    setlb
48419c0e: f4                    movbu   (d1, a2), d0
48419c0f: 06 a0 7c              movbu   d1, (0x7ca0)
48419c12: c9 09                 bne     0x48419c1b
48419c14: 00                    clr     d0
48419c15: f4                    movbu   d0, (d1, a2)
48419c16: 46 1e                 mov     d1, (0x1e, sp)
48419c18: 48                    inc     d2
48419c19: ca 0b                 bra     0x48419c24
48419c1b: 1e                    exthu   d2
48419c1c: 48                    inc     d2
48419c1d: 89                    mov     d2, d1
48419c1e: 1d                    exthu   d1
48419c1f: f4                    movbu   (d1, a2), d0
48419c20: 06 a0 00              movbu   d1, (0x00a0)
48419c23: d9                    lne
48419c24: 5c 2c                 mov     (0x2c, sp), a0
48419c26: 4c                    inc     d3
48419c27: f0 00                 mov     (a0), a0
48419c29: 1f                    exthu   d3
48419c2a: f0 60                 movhu   (a0), d0
48419c2c: 18                    exth    d0
48419c2d: a3                    cmp     d0, d3
48419c2e: c3 d2                 ble     0x48419c00
48419c30: 58 28                 mov     (0x28, sp), d0
48419c32: 9d                    mov     a3, a1
48419c33: 42 10                 mov     d0, (0x10, sp)
48419c35: f8 be 58              movhu   (0x58, sp), d2
48419c38: 1a                    exth    d2
48419c39: 4a 1c                 mov     d2, (0x1c, sp)
48419c3b: 5c 34                 mov     (0x34, sp), a0
48419c3d: f8 40 26              movbu   (0x26, a0), d0
48419c40: 42 20                 mov     d0, (0x20, sp)
48419c42: 00                    clr     d0
48419c43: 42 24                 mov     d0, (0x24, sp)
48419c45: f8 bd 5a              movhu   (0x5a, sp), d1
48419c48: 5c 30                 mov     (0x30, sp), a0
48419c4a: 58 38                 mov     (0x38, sp), d0
48419c4c: 19                    exth    d1
48419c4d: dd d0 be 00 00 f0 48  call    0x48425b1d, [d2,d3,a2,a3], 0x48
48419c54: cd 78 da 00 00        call    0x484176cc, 0, 0
48419c59: 59 80                 mov     (0x80, sp), d1
48419c5b: a4                    cmp     d1, d0
48419c5c: c8 0f                 beq     0x48419c6b
48419c5e: 4a 14                 mov     d2, (0x14, sp)
48419c60: 5c 30                 mov     (0x30, sp), a0
48419c62: 80 01                 mov     1, d0
48419c64: 85 02                 mov     2, d1
48419c66: cd 56 f0 f0 28        call    0x48418cbc, [d2,d3,a2,a3], 0x28
48419c6b: 5c 2c                 mov     (0x2c, sp), a0
48419c6d: 58 88                 mov     (0x88, sp), d0
48419c6f: f0 00                 mov     (a0), a0
48419c71: 3f                    mov     sp, a3
48419c72: f0 70                 movhu   d0, (a0)
48419c74: 3c                    mov     sp, a0
48419c75: f1 d0                 mov     a0, d0
48419c77: 28 5c                 add     0x5c, d0
48419c79: 42 30                 mov     d0, (0x30, sp)
48419c7b: 58 80                 mov     (0x80, sp), d0
48419c7d: 5c 30                 mov     (0x30, sp), a0
48419c7f: cd 66 ce 00 14        call    0x48416ae5, 0, 0x14
48419c84: f8 bc 62              movhu   (0x62, sp), d0
48419c87: f8 be 5e              movhu   (0x5e, sp), d2
48419c8a: 5c 34                 mov     (0x34, sp), a0
48419c8c: 18                    exth    d0
48419c8d: 1a                    exth    d2
48419c8e: f8 64 28              movhu   (0x28, a0), d1
48419c91: f1 08                 sub     d2, d0
48419c93: dd 42 7d be 03 00 00  call    0x4c0019d5, 0, 0
48419c9a: 5c 2c                 mov     (0x2c, sp), a0
48419c9c: f8 bd 5e              movhu   (0x5e, sp), d1
48419c9f: f0 00                 mov     (a0), a0
48419ca1: 82                    mov     d0, d2
48419ca2: f0 60                 movhu   (a0), d0
48419ca4: 1a                    exth    d2
48419ca5: 18                    exth    d0
48419ca6: 19                    exth    d1
48419ca7: cb                    nop
48419ca8: cb                    nop
48419ca9: f2 48                 mul     d2, d0
48419cab: e4                    add     d1, d0
48419cac: 40                    inc     d0
48419cad: f8 93 5e              movhu   d0, (0x5e, sp)
48419cb0: f8 bc 5c              movhu   (0x5c, sp), d0
48419cb3: 23 64                 add     0x64, a3

AcListBoxProc:
48419e34: cf b0                 movm    [d2,a2,a3], (sp)
48419e36: f8 fe ec              add     -0x14, sp
48419e39: 82                    mov     d0, d2
48419e3a: fc c9 01 00 05 00     cmp     0x50001, d1
48419e40: c8 3c                 beq     0x48419e7c
48419e42: fc c9 11 00 05 00     cmp     0x50011, d1
48419e48: c9 05                 bne     0x48419e4d
48419e4a: cc ab 00              jmp     0x48419ef5
48419e4d: fc c9 0f 00 05 00     cmp     0x5000f, d1
48419e53: c9 05                 bne     0x48419e58
48419e55: cc a0 00              jmp     0x48419ef5
48419e58: fc c9 12 00 05 00     cmp     0x50012, d1
48419e5e: c9 05                 bne     0x48419e63
48419e60: cc 48 01              jmp     0x48419fa8
48419e63: fc c9 10 00 05 00     cmp     0x50010, d1
48419e69: c9 05                 bne     0x48419e6e
48419e6b: cc 3d 01              jmp     0x48419fa8
48419e6e: fc c9 3a 00 06 00     cmp     0x6003a, d1
48419e74: c9 05                 bne     0x48419e79
48419e76: cc e3 01              jmp     0x4841a059
48419e79: cc f6 01              jmp     0x4841a06f
48419e7c: 5c 30                 mov     (0x30, sp), a0
48419e7e: 43 10                 mov     a0, (0x10, sp)
48419e80: dd e9 f6 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419e87: 88                    mov     d2, d0
48419e88: dd 92 3a 01 00 00 00  call    0x4842d91a, 0, 0
48419e8f: 92                    mov     a0, a2
48419e90: f8 02 34              mov     (0x34, a2), d0
48419e93: a0 00                 cmp     0, d0
48419e95: c8 5c                 beq     0x48419ef1
48419e97: cd 69 d7 00 00        call    0x48417600, 0, 0
48419e9c: a0 00                 cmp     0, d0
48419e9e: c8 28                 beq     0x48419ec6
48419ea0: 22 1c                 add     0x1c, a2
48419ea2: f0 62                 movhu   (a2), d0
48419ea4: fc cd 10 00 05 00     mov     0x00050010, d1
48419eaa: 18                    exth    d0
48419eab: 42 10                 mov     d0, (0x10, sp)
48419ead: 88                    mov     d2, d0
48419eae: cd 2a d8 00 0c        call    0x484176d8, 0, 0xc
48419eb3: f0 62                 movhu   (a2), d0
48419eb5: fc cd 0f 00 05 00     mov     0x0005000f, d1
48419ebb: 18                    exth    d0
48419ebc: 42 10                 mov     d0, (0x10, sp)
48419ebe: 88                    mov     d2, d0
48419ebf: cd 38 d8 00 0c        call    0x484176f7, 0, 0xc
48419ec4: ca 26                 bra     0x48419eea
48419ec6: 22 1c                 add     0x1c, a2
48419ec8: f0 62                 movhu   (a2), d0
48419eca: fc cd 0f 00 05 00     mov     0x0005000f, d1
48419ed0: 18                    exth    d0
48419ed1: 42 10                 mov     d0, (0x10, sp)
48419ed3: 88                    mov     d2, d0
48419ed4: cd 04 d8 00 0c        call    0x484176d8, 0, 0xc
48419ed9: f0 62                 movhu   (a2), d0
48419edb: fc cd 10 00 05 00     mov     0x00050010, d1
48419ee1: 18                    exth    d0
48419ee2: 42 10                 mov     d0, (0x10, sp)
48419ee4: 88                    mov     d2, d0
48419ee5: cd 12 d8 00 0c        call    0x484176f7, 0, 0xc
48419eea: 80 01                 mov     1, d0
48419eec: cd 2b d7 80 18        call    0x48417617, [d2], 0x18
48419ef1: 00                    clr     d0
48419ef2: df b0 20              ret     [d2,a2,a3], 0x20
48419ef5: 5e 30                 mov     (0x30, sp), a2
48419ef7: 4b 10                 mov     a2, (0x10, sp)
48419ef9: dd 70 f6 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419f00: 4b 10                 mov     a2, (0x10, sp)
48419f02: 88                    mov     d2, d0
48419f03: fc cd 4d 00 06 00     mov     0x0006004d, d1
48419f09: dd 84 f4 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419f10: a0 00                 cmp     0, d0
48419f12: c9 05                 bne     0x48419f17
48419f14: cc 90 00              jmp     0x48419fa4
48419f17: 88                    mov     d2, d0
48419f18: dd 02 3a 01 00 00 00  call    0x4842d91a, 0, 0
48419f1f: 93                    mov     a0, a3
48419f20: 00                    clr     d0
48419f21: 42 10                 mov     d0, (0x10, sp)
48419f23: 88                    mov     d2, d0
48419f24: fc cd 84 00 06 00     mov     0x00060084, d1
48419f2a: dd 63 f4 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419f31: 18                    exth    d0
48419f32: 85 ff                 mov     -1, d1
48419f34: e1                    add     d0, d1
48419f35: 46 10                 mov     d1, (0x10, sp)
48419f37: 88                    mov     d2, d0
48419f38: fc cd 4a 00 06 00     mov     0x0006004a, d1
48419f3e: dd 4f f4 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419f45: 4b 10                 mov     a2, (0x10, sp)
48419f47: 88                    mov     d2, d0
48419f48: fc cd 11 00 05 00     mov     0x00050011, d1
48419f4e: cd f2 d7 f0 2c        call    0x48417740, [d2,d3,a2,a3], 0x2c
48419f53: f8 03 34              mov     (0x34, a3), d0
48419f56: a0 00                 cmp     0, d0
48419f58: c8 4c                 beq     0x48419fa4
48419f5a: cd a6 d6 00 00        call    0x48417600, 0, 0
48419f5f: a0 00                 cmp     0, d0
48419f61: c8 20                 beq     0x48419f81
48419f63: 4b 10                 mov     a2, (0x10, sp)
48419f65: 88                    mov     d2, d0
48419f66: fc cd 10 00 05 00     mov     0x00050010, d1
48419f6c: cd 6c d7 00 0c        call    0x484176d8, 0, 0xc
48419f71: 4b 10                 mov     a2, (0x10, sp)
48419f73: fc cd 0f 00 05 00     mov     0x0005000f, d1
48419f79: 88                    mov     d2, d0
48419f7a: cd 7d d7 00 0c        call    0x484176f7, 0, 0xc
48419f7f: ca 1e                 bra     0x48419f9d
48419f81: 4b 10                 mov     a2, (0x10, sp)
48419f83: 88                    mov     d2, d0
48419f84: fc cd 0f 00 05 00     mov     0x0005000f, d1
48419f8a: cd 4e d7 00 0c        call    0x484176d8, 0, 0xc
48419f8f: 4b 10                 mov     a2, (0x10, sp)
48419f91: fc cd 10 00 05 00     mov     0x00050010, d1
48419f97: 88                    mov     d2, d0
48419f98: cd 5f d7 00 0c        call    0x484176f7, 0, 0xc
48419f9d: 80 01                 mov     1, d0
48419f9f: cd 78 d6 80 18        call    0x48417617, [d2], 0x18
48419fa4: 00                    clr     d0
48419fa5: df b0 20              ret     [d2,a2,a3], 0x20
48419fa8: 5e 30                 mov     (0x30, sp), a2
48419faa: 4b 10                 mov     a2, (0x10, sp)
48419fac: dd bd f5 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
48419fb3: 4b 10                 mov     a2, (0x10, sp)
48419fb5: 88                    mov     d2, d0
48419fb6: fc cd 4d 00 06 00     mov     0x0006004d, d1
48419fbc: dd d1 f3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419fc3: a0 00                 cmp     0, d0
48419fc5: c9 05                 bne     0x48419fca
48419fc7: cc 8f 00              jmp     0x4841a056
48419fca: 88                    mov     d2, d0
48419fcb: dd 4f 39 01 00 00 00  call    0x4842d91a, 0, 0
48419fd2: 93                    mov     a0, a3
48419fd3: 00                    clr     d0
48419fd4: 42 10                 mov     d0, (0x10, sp)
48419fd6: 88                    mov     d2, d0
48419fd7: fc cd 84 00 06 00     mov     0x00060084, d1
48419fdd: dd b0 f3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419fe4: 81                    mov     d0, d1
48419fe5: 19                    exth    d1
48419fe6: 44                    inc     d1
48419fe7: 46 10                 mov     d1, (0x10, sp)
48419fe9: 88                    mov     d2, d0
48419fea: fc cd 4a 00 06 00     mov     0x0006004a, d1
48419ff0: dd 9d f3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
48419ff7: 4b 10                 mov     a2, (0x10, sp)
48419ff9: 88                    mov     d2, d0
48419ffa: fc cd 12 00 05 00     mov     0x00050012, d1
4841a000: cd 40 d7 f0 2c        call    0x48417740, [d2,d3,a2,a3], 0x2c
4841a005: f8 03 34              mov     (0x34, a3), d0
4841a008: a0 00                 cmp     0, d0
4841a00a: c8 4c                 beq     0x4841a056
4841a00c: cd f4 d5 00 00        call    0x48417600, 0, 0
4841a011: a0 00                 cmp     0, d0
4841a013: c8 20                 beq     0x4841a033
4841a015: 4b 10                 mov     a2, (0x10, sp)
4841a017: 88                    mov     d2, d0
4841a018: fc cd 10 00 05 00     mov     0x00050010, d1
4841a01e: cd ba d6 00 0c        call    0x484176d8, 0, 0xc
4841a023: 4b 10                 mov     a2, (0x10, sp)
4841a025: fc cd 0f 00 05 00     mov     0x0005000f, d1
4841a02b: 88                    mov     d2, d0
4841a02c: cd cb d6 00 0c        call    0x484176f7, 0, 0xc
4841a031: ca 1e                 bra     0x4841a04f
4841a033: 4b 10                 mov     a2, (0x10, sp)
4841a035: 88                    mov     d2, d0
4841a036: fc cd 0f 00 05 00     mov     0x0005000f, d1
4841a03c: cd 9c d6 00 0c        call    0x484176d8, 0, 0xc
4841a041: 4b 10                 mov     a2, (0x10, sp)
4841a043: fc cd 10 00 05 00     mov     0x00050010, d1
4841a049: 88                    mov     d2, d0
4841a04a: cd ad d6 00 0c        call    0x484176f7, 0, 0xc
4841a04f: 80 01                 mov     1, d0
4841a051: cd c6 d5 80 18        call    0x48417617, [d2], 0x18
4841a056: 00                    clr     d0
4841a057: ca 23                 bra     0x4841a07a
4841a059: dd c1 38 01 00 00 00  call    0x4842d91a, 0, 0
4841a060: f8 24 30              mov     (0x30, a0), a1
4841a063: 5c 30                 mov     (0x30, sp), a0
4841a065: dd ec 8f be 03 20 04  call    0x4c003051, [a2], 4
4841a06c: 00                    clr     d0
4841a06d: ca 0d                 bra     0x4841a07a
4841a06f: 5c 30                 mov     (0x30, sp), a0
4841a071: 43 10                 mov     a0, (0x10, sp)
4841a073: dd f6 f4 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841a07a: df b0 20              ret     [d2,a2,a3], 0x20

PsGridBoxProc:
4841a07d: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841a07f: fa fe 64 fe           add     -0x19c, sp
4841a083: fa 91 b4 01           mov     d100, (0x1b4, sp)
4841a087: fa 95 b8 01           mov     d100, (0x1b8, sp)
4841a08b: fc c9 01 00 05 00     cmp     0x50001, d1
4841a091: c2 05                 bge     0x4841a096
4841a093: cc 69 0d              jmp     0x4841adfc
4841a096: fa b4 b8 01           mov     (0x1b8, sp), d0
4841a09a: fc c8 b4 00 06 00     cmp     0x600b4, d0
4841a0a0: c3 05                 ble     0x4841a0a5
4841a0a2: cc 5a 0d              jmp     0x4841adfc
4841a0a5: fa b5 b8 01           mov     (0x1b8, sp), d1
4841a0a9: fc dd b0 1b 5a 48     mov     0x485a1bb0, a1
4841a0af: fc c1 00 00 fb ff     add     0xfffb0000, d1
4841a0b5: 80 1f                 mov     0x1f, d0
4841a0b7: f2 04                 and     d1, d0
4841a0b9: f8 c0 03              asl     3, d0
4841a0bc: f1 e0                 mov     d0, a0
4841a0be: f1 74                 add     a1, a0
4841a0c0: 70                    mov     (a0), d0
4841a0c1: a4                    cmp     d1, d0
4841a0c2: c8 18                 beq     0x4841a0da
4841a0c4: db                    setlb
4841a0c5: a0 00                 cmp     0, d0
4841a0c7: c9 05                 bne     0x4841a0cc
4841a0c9: cc 33 0d              jmp     0x4841adfc
4841a0cc: 20 08                 add     8, a0
4841a0ce: fc d8 b0 1c 5a 48     cmp     0x485a1cb0, a0
4841a0d4: c4 03                 bcs     0x4841a0d7
4841a0d6: 94                    mov     a1, a0
4841a0d7: 70                    mov     (a0), d0
4841a0d8: a4                    cmp     d1, d0
4841a0d9: d9                    lne
4841a0da: f8 20 04              mov     (4, a0), a0
4841a0dd: f0 f4                 jmp     (a0)
4841a0df: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a0e3: dd 37 38 01 00 00 00  call    0x4842d91a, 0, 0
4841a0ea: f8 64 2a              movhu   (0x2a, a0), d1
4841a0ed: f1 d2                 mov     a0, d2
4841a0ef: 44                    inc     d1
4841a0f0: 84                    mov     d1, d0
4841a0f1: e4                    add     d1, d0
4841a0f2: cd 38 c5 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841a0f7: f1 e9                 mov     d2, a1
4841a0f9: f8 25 38              mov     (0x38, a1), a1
4841a0fc: 9a 28                 mov     0x28, a2
4841a0fe: f0 11                 mov     a0, (a1)
4841a100: f1 6a                 add     d2, a2
4841a102: f0 62                 movhu   (a2), d0
4841a104: 9f 3c                 mov     0x3c, a3
4841a106: 81                    mov     d0, d1
4841a107: 44                    inc     d1
4841a108: 84                    mov     d1, d0
4841a109: e4                    add     d1, d0
4841a10a: cd 20 c5 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841a10f: f1 6b                 add     d2, a3
4841a111: f0 07                 mov     (a3), a1
4841a113: f0 11                 mov     a0, (a1)
4841a115: f0 62                 movhu   (a2), d0
4841a117: 40                    inc     d0
4841a118: e0                    add     d0, d0
4841a119: cd 11 c5 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841a11e: f1 e9                 mov     d2, a1
4841a120: f8 25 40              mov     (0x40, a1), a1
4841a123: 2c ff 7f              mov     0x7fff, d0
4841a126: f0 11                 mov     a0, (a1)
4841a128: f0 03                 mov     (a3), a0
4841a12a: f0 00                 mov     (a0), a0
4841a12c: f0 70                 movhu   d0, (a0)
4841a12e: fa b0 bc 01           mov     (0x1bc, sp), a0
4841a132: 43 10                 mov     a0, (0x10, sp)
4841a134: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a138: fa b5 b8 01           mov     (0x1b8, sp), d1
4841a13c: dd 2d f4 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841a143: 00                    clr     d0
4841a144: cc cd 0c              jmp     0x4841ae11
4841a147: fa b0 bc 01           mov     (0x1bc, sp), a0
4841a14b: 9a 38                 mov     0x38, a2
4841a14d: 43 10                 mov     a0, (0x10, sp)
4841a14f: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a153: fa b5 b8 01           mov     (0x1b8, sp), d1
4841a157: dd 12 f4 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841a15e: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a162: dd b8 37 01 00 00 00  call    0x4842d91a, 0, 0
4841a169: 93                    mov     a0, a3
4841a16a: f1 7e                 add     a3, a2
4841a16c: f0 02                 mov     (a2), a0
4841a16e: 70                    mov     (a0), d0
4841a16f: a0 00                 cmp     0, d0
4841a171: c8 0f                 beq     0x4841a180
4841a173: f0 02                 mov     (a2), a0
4841a175: f0 00                 mov     (a0), a0
4841a177: cd 67 c5 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841a17c: f0 02                 mov     (a2), a0
4841a17e: 00                    clr     d0
4841a17f: 60                    mov     d0, (a0)
4841a180: 9a 3c                 mov     0x3c, a2
4841a182: f1 7e                 add     a3, a2
4841a184: f0 02                 mov     (a2), a0
4841a186: 70                    mov     (a0), d0
4841a187: a0 00                 cmp     0, d0
4841a189: c8 0f                 beq     0x4841a198
4841a18b: f0 02                 mov     (a2), a0
4841a18d: f0 00                 mov     (a0), a0
4841a18f: cd 4f c5 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841a194: f0 02                 mov     (a2), a0
4841a196: 00                    clr     d0
4841a197: 60                    mov     d0, (a0)
4841a198: 23 40                 add     0x40, a3
4841a19a: f0 03                 mov     (a3), a0
4841a19c: 70                    mov     (a0), d0
4841a19d: a0 00                 cmp     0, d0
4841a19f: c8 10                 beq     0x4841a1af
4841a1a1: f0 07                 mov     (a3), a1
4841a1a3: 71                    mov     (a1), d0
4841a1a4: f1 e0                 mov     d0, a0
4841a1a6: cd 38 c5 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841a1ab: f0 03                 mov     (a3), a0
4841a1ad: 00                    clr     d0
4841a1ae: 60                    mov     d0, (a0)
4841a1af: 00                    clr     d0
4841a1b0: cc 61 0c              jmp     0x4841ae11
4841a1b3: 3f                    mov     sp, a3
4841a1b4: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a1b8: dd 62 37 01 00 00 00  call    0x4842d91a, 0, 0
4841a1bf: 43 38                 mov     a0, (0x38, sp)
4841a1c1: 23 6c                 add     0x6c, a3
4841a1c3: 00                    clr     d0
4841a1c4: 42 10                 mov     d0, (0x10, sp)
4841a1c6: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a1ca: fc cd af 00 06 00     mov     0x000600af, d1
4841a1d0: dd bd f1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841a1d7: 42 40                 mov     d0, (0x40, sp)
4841a1d9: 4f 3c                 mov     a3, (0x3c, sp)
4841a1db: 4f 10                 mov     a3, (0x10, sp)
4841a1dd: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a1e1: fc cd 7e 00 06 00     mov     0x0006007e, d1
4841a1e7: dd a6 f1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841a1ee: f0 47                 movbu   (a3), d1
4841a1f0: 00                    clr     d0
4841a1f1: 0c                    clr     d3
4841a1f2: 08                    clr     d2
4841a1f3: a1                    cmp     d0, d1
4841a1f4: c8 14                 beq     0x4841a208
4841a1f6: db                    setlb
4841a1f7: f4                    movbu   (d2, a3), d1
4841a1f8: 1b                    exth    d3
4841a1f9: a5 7c                 cmp     0x7c, d1
4841a1fb: c9 04                 bne     0x4841a1ff
4841a1fd: 1b                    exth    d3
4841a1fe: 4c                    inc     d3
4841a1ff: 1c                    exthu   d0
4841a200: 40                    inc     d0
4841a201: 82                    mov     d0, d2
4841a202: 1e                    exthu   d2
4841a203: f4                    movbu   (d2, a3), d1
4841a204: 1b                    exth    d3
4841a205: a5 00                 cmp     0, d1
4841a207: d9                    lne
4841a208: 3c                    mov     sp, a0
4841a209: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a20d: fa d0 6c 01           add     0x16c, a0
4841a211: cd d4 c8 00 14        call    0x48416ae5, 0, 0x14
4841a216: fa bc 70 01           movhu   (0x170, sp), d0
4841a21a: fa bd 6c 01           movhu   (0x16c, sp), d1
4841a21e: 18                    exth    d0
4841a21f: 19                    exth    d1
4841a220: f1 04                 sub     d1, d0
4841a222: 28 ff                 add     -1, d0
4841a224: f8 93 60              movhu   d0, (0x60, sp)
4841a227: 9c                    mov     a3, a0
4841a228: dd cf 90 be 03 00 00  call    0x4c0032f7, 0, 0
4841a22f: 1b                    exth    d3
4841a230: 81                    mov     d0, d1
4841a231: fa bc 6c 01           movhu   (0x16c, sp), d0
4841a235: f1 0d                 sub     d3, d1
4841a237: 5b 38                 mov     (0x38, sp), d3
4841a239: 08                    clr     d2
4841a23a: 2b 38                 add     0x38, d3
4841a23c: 4e 28                 mov     d3, (0x28, sp)
4841a23e: f1 ec                 mov     d3, a0
4841a240: f0 00                 mov     (a0), a0
4841a242: 9a 01                 mov     1, a2
4841a244: f0 00                 mov     (a0), a0
4841a246: 8f 01                 mov     1, d3
4841a248: f0 70                 movhu   d0, (a0)
4841a24a: 58 38                 mov     (0x38, sp), d0
4841a24c: 28 2a                 add     0x2a, d0
4841a24e: 42 2c                 mov     d0, (0x2c, sp)
4841a250: f1 e0                 mov     d0, a0
4841a252: f0 60                 movhu   (a0), d0
4841a254: ac                    cmp     d3, d0
4841a255: c0 74                 blt     0x4841a2c9
4841a257: f8 bc 60              movhu   (0x60, sp), d0
4841a25a: 19                    exth    d1
4841a25b: 18                    exth    d0
4841a25c: 42 34                 mov     d0, (0x34, sp)
4841a25e: 46 30                 mov     d1, (0x30, sp)
4841a260: 89                    mov     d2, d1
4841a261: 1d                    exthu   d1
4841a262: f4                    movbu   (d1, a3), d0
4841a263: 07 9c f1              movhu   d1, (0xf19c)
4841a266: 64                    mov     d1, (a0)
4841a267: a0 00                 cmp     0, d0
4841a269: c8 19                 beq     0x4841a282
4841a26b: db                    setlb
4841a26c: f4                    movbu   (d1, a3), d0
4841a26d: 07 a0 7c              movhu   d1, (0x7ca0)
4841a270: c9 09                 bne     0x4841a279
4841a272: 00                    clr     d0
4841a273: f4                    movbu   d0, (d1, a3)
4841a274: 47 1e                 mov     a1, (0x1e, sp)
4841a276: 48                    inc     d2
4841a277: ca 0b                 bra     0x4841a282
4841a279: 1e                    exthu   d2
4841a27a: 48                    inc     d2
4841a27b: 89                    mov     d2, d1
4841a27c: 1d                    exthu   d1
4841a27d: f4                    movbu   (d1, a3), d0
4841a27e: 07 a0 00              movhu   d1, (0x00a0)
4841a281: d9                    lne
4841a282: dd 75 90 be 03 00 00  call    0x4c0032f7, 0, 0
4841a289: 5c 28                 mov     (0x28, sp), a0
4841a28b: 81                    mov     d0, d1
4841a28c: f0 00                 mov     (a0), a0
4841a28e: 70                    mov     (a0), d0
4841a28f: 5c 28                 mov     (0x28, sp), a0
4841a291: f0 00                 mov     (a0), a0
4841a293: f0 04                 mov     (a0), a1
4841a295: f1 ec                 mov     d3, a0
4841a297: f1 70                 add     a0, a0
4841a299: f1 60                 add     d0, a0
4841a29b: f8 60 fe              movhu   (-2, a0), d0
4841a29e: 4a 64                 mov     d2, (0x64, sp)
4841a2a0: 5a 34                 mov     (0x34, sp), d2
4841a2a2: 18                    exth    d0
4841a2a3: f1 e0                 mov     d0, a0
4841a2a5: f1 d8                 mov     a2, d0
4841a2a7: 1c                    exthu   d0
4841a2a8: cb                    nop
4841a2a9: cb                    nop
4841a2aa: f2 59                 mulu    d2, d1
4841a2ac: 5a 30                 mov     (0x30, sp), d2
4841a2ae: 4e 68                 mov     d3, (0x68, sp)
4841a2b0: e0                    add     d0, d0
4841a2b1: 0c                    clr     d3
4841a2b2: f2 fe                 mov     d3, mdr
4841a2b4: f2 79                 divu    d2, d1
4841a2b6: 5b 68                 mov     (0x68, sp), d3
4841a2b8: 5a 64                 mov     (0x64, sp), d2
4841a2ba: f1 51                 add     a0, d1
4841a2bc: f4                    movhu   d1, (d0, a1)
4841a2bd: d1                    lgt
4841a2be: 5c 2c                 mov     (0x2c, sp), a0
4841a2c0: 4c                    inc     d3
4841a2c1: f0 60                 movhu   (a0), d0
4841a2c3: f1 ee                 mov     d3, a2
4841a2c5: 1f                    exthu   d3
4841a2c6: a3                    cmp     d0, d3
4841a2c7: c3 99                 ble     0x4841a260
4841a2c9: 58 3c                 mov     (0x3c, sp), d0
4841a2cb: fc cd 7f 00 06 00     mov     0x0006007f, d1
4841a2d1: 42 10                 mov     d0, (0x10, sp)
4841a2d3: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a2d7: dd b6 f0 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841a2de: 58 40                 mov     (0x40, sp), d0
4841a2e0: dd 80 3c 01 00 00 00  call    0x4842df60, 0, 0
4841a2e7: f8 93 62              movhu   d0, (0x62, sp)
4841a2ea: 00                    clr     d0
4841a2eb: f8 93 60              movhu   d0, (0x60, sp)
4841a2ee: 58 38                 mov     (0x38, sp), d0
4841a2f0: 0c                    clr     d3
4841a2f1: 28 28                 add     0x28, d0
4841a2f3: 42 34                 mov     d0, (0x34, sp)
4841a2f5: f1 e0                 mov     d0, a0
4841a2f7: f0 60                 movhu   (a0), d0
4841a2f9: 8a 01                 mov     1, d2
4841a2fb: a8                    cmp     d2, d0
4841a2fc: 9a 01                 mov     1, a2
4841a2fe: c2 05                 bge     0x4841a303
4841a300: cc c0 00              jmp     0x4841a3c0
4841a303: 58 38                 mov     (0x38, sp), d0
4841a305: 28 3c                 add     0x3c, d0
4841a307: 42 2c                 mov     d0, (0x2c, sp)
4841a309: f8 bc 62              movhu   (0x62, sp), d0
4841a30c: 18                    exth    d0
4841a30d: 54                    asl2    d0
4841a30e: 42 30                 mov     d0, (0x30, sp)
4841a310: 8d                    mov     d3, d1
4841a311: 1d                    exthu   d1
4841a312: f1 dc                 mov     a3, d0
4841a314: e4                    add     d1, d0
4841a315: 42 28                 mov     d0, (0x28, sp)
4841a317: f4                    movbu   (d1, a3), d0
4841a318: 07 a0 00              movhu   d1, (0x00a0)
4841a31b: c8 19                 beq     0x4841a334
4841a31d: db                    setlb
4841a31e: f4                    movbu   (d1, a3), d0
4841a31f: 07 a0 7c              movhu   d1, (0x7ca0)
4841a322: c9 09                 bne     0x4841a32b
4841a324: 00                    clr     d0
4841a325: f4                    movbu   d0, (d1, a3)
4841a326: 47 1f                 mov     a1, (0x1f, sp)
4841a328: 4c                    inc     d3
4841a329: ca 0b                 bra     0x4841a334
4841a32b: 1f                    exthu   d3
4841a32c: 4c                    inc     d3
4841a32d: 8d                    mov     d3, d1
4841a32e: 1d                    exthu   d1
4841a32f: f4                    movbu   (d1, a3), d0
4841a330: 07 a0 00              movhu   d1, (0x00a0)
4841a333: d9                    lne
4841a334: 5c 28                 mov     (0x28, sp), a0
4841a336: f0 40                 movbu   (a0), d0
4841a338: a0 00                 cmp     0, d0
4841a33a: c8 08                 beq     0x4841a342
4841a33c: a0 2d                 cmp     0x2d, d0
4841a33e: c8 15                 beq     0x4841a353
4841a340: ca 26                 bra     0x4841a366
4841a342: 5c 38                 mov     (0x38, sp), a0
4841a344: f8 20 40              mov     (0x40, a0), a0
4841a347: 70                    mov     (a0), d0
4841a348: 98                    mov     a2, a0
4841a349: f1 70                 add     a0, a0
4841a34b: f1 60                 add     d0, a0
4841a34d: 00                    clr     d0
4841a34e: f8 70 fe              movhu   d0, (-2, a0)
4841a351: ca 25                 bra     0x4841a376
4841a353: 5c 38                 mov     (0x38, sp), a0
4841a355: 80 01                 mov     1, d0
4841a357: f8 20 40              mov     (0x40, a0), a0
4841a35a: f0 04                 mov     (a0), a1
4841a35c: 98                    mov     a2, a0
4841a35d: f1 70                 add     a0, a0
4841a35f: f1 71                 add     a0, a1
4841a361: f8 71 fe              movhu   d0, (-2, a1)
4841a364: ca 12                 bra     0x4841a376
4841a366: 5c 38                 mov     (0x38, sp), a0
4841a368: f8 20 40              mov     (0x40, a0), a0
4841a36b: 70                    mov     (a0), d0
4841a36c: 98                    mov     a2, a0
4841a36d: f1 70                 add     a0, a0
4841a36f: f1 60                 add     d0, a0
4841a371: 80 02                 mov     2, d0
4841a373: f8 70 fe              movhu   d0, (-2, a0)
4841a376: 5c 28                 mov     (0x28, sp), a0
4841a378: f0 40                 movbu   (a0), d0
4841a37a: a0 2d                 cmp     0x2d, d0
4841a37c: c8 11                 beq     0x4841a38d
4841a37e: 5d 2c                 mov     (0x2c, sp), a1
4841a380: 59 30                 mov     (0x30, sp), d1
4841a382: f0 01                 mov     (a1), a0
4841a384: 1e                    exthu   d2
4841a385: f0 00                 mov     (a0), a0
4841a387: 88                    mov     d2, d0
4841a388: e0                    add     d0, d0
4841a389: f4                    movhu   d1, (d0, a0)
4841a38a: d0                    llt
4841a38b: ca 10                 bra     0x4841a39b
4841a38d: 5d 2c                 mov     (0x2c, sp), a1
4841a38f: f8 bd 62              movhu   (0x62, sp), d1
4841a392: f0 01                 mov     (a1), a0
4841a394: 1e                    exthu   d2
4841a395: f0 00                 mov     (a0), a0
4841a397: 88                    mov     d2, d0
4841a398: e0                    add     d0, d0
4841a399: f4                    movhu   d1, (d0, a0)
4841a39a: d0                    llt
4841a39b: f0 01                 mov     (a1), a0
4841a39d: f0 04                 mov     (a0), a1
4841a39f: f1 e8                 mov     d2, a0
4841a3a1: f1 70                 add     a0, a0
4841a3a3: f1 d0                 mov     a0, d0
4841a3a5: f4                    movhu   (d0, a1), d2
4841a3a6: a1                    cmp     d0, d1
4841a3a7: 5c 34                 mov     (0x34, sp), a0
4841a3a9: 1a                    exth    d2
4841a3aa: f8 bc 60              movhu   (0x60, sp), d0
4841a3ad: 18                    exth    d0
4841a3ae: e8                    add     d2, d0
4841a3af: f8 93 60              movhu   d0, (0x60, sp)
4841a3b2: f0 60                 movhu   (a0), d0
4841a3b4: f1 da                 mov     a2, d2
4841a3b6: 48                    inc     d2
4841a3b7: 1e                    exthu   d2
4841a3b8: f1 ea                 mov     d2, a2
4841a3ba: a2                    cmp     d0, d2
4841a3bb: c1 05                 bgt     0x4841a3c0
4841a3bd: cc 53 ff              jmp     0x4841a310
4841a3c0: 5c 38                 mov     (0x38, sp), a0
4841a3c2: f1 d8                 mov     a2, d0
4841a3c4: f8 20 40              mov     (0x40, a0), a0
4841a3c7: e0                    add     d0, d0
4841a3c8: f0 00                 mov     (a0), a0
4841a3ca: 8f ff                 mov     -1, d3
4841a3cc: f1 60                 add     d0, a0
4841a3ce: 80 05                 mov     5, d0
4841a3d0: f8 70 fe              movhu   d0, (-2, a0)
4841a3d3: 5f 38                 mov     (0x38, sp), a3
4841a3d5: fa bd 72 01           movhu   (0x172, sp), d1
4841a3d9: 23 3c                 add     0x3c, a3
4841a3db: f0 03                 mov     (a3), a0
4841a3dd: fa bc 6e 01           movhu   (0x16e, sp), d0
4841a3e1: f0 00                 mov     (a0), a0
4841a3e3: 19                    exth    d1
4841a3e4: 18                    exth    d0
4841a3e5: f1 01                 sub     d0, d1
4841a3e7: fa bc 6e 01           movhu   (0x16e, sp), d0
4841a3eb: e7                    add     d1, d3
4841a3ec: f0 70                 movhu   d0, (a0)
4841a3ee: 5c 34                 mov     (0x34, sp), a0
4841a3f0: 80 01                 mov     1, d0
4841a3f2: f0 64                 movhu   (a0), d1
4841a3f4: 82                    mov     d0, d2
4841a3f5: a9                    cmp     d2, d1
4841a3f6: c0 4d                 blt     0x4841a443
4841a3f8: f8 bd 60              movhu   (0x60, sp), d1
4841a3fb: 1b                    exth    d3
4841a3fc: 4e 30                 mov     d3, (0x30, sp)
4841a3fe: 19                    exth    d1
4841a3ff: 46 2c                 mov     d1, (0x2c, sp)
4841a401: f0 03                 mov     (a3), a0
4841a403: 1c                    exthu   d0
4841a404: 74                    mov     (a0), d1
4841a405: f1 e2                 mov     d0, a2
4841a407: 46 28                 mov     d1, (0x28, sp)
4841a409: f0 03                 mov     (a3), a0
4841a40b: 74                    mov     (a0), d1
4841a40c: f0 03                 mov     (a3), a0
4841a40e: f0 04                 mov     (a0), a1
4841a410: f1 e8                 mov     d2, a0
4841a412: f1 70                 add     a0, a0
4841a414: f1 64                 add     d1, a0
4841a416: f8 6c fe              movhu   (-2, a0), d3
4841a419: 98                    mov     a2, a0
4841a41a: f1 70                 add     a0, a0
4841a41c: f1 d0                 mov     a0, d0
4841a41e: f4                    movhu   (d0, a1), d0
4841a41f: 81                    mov     d0, d1
4841a420: 1b                    exth    d3
4841a421: 18                    exth    d0
4841a422: 59 30                 mov     (0x30, sp), d1
4841a424: cb                    nop
4841a425: cb                    nop
4841a426: f2 44                 mul     d1, d0
4841a428: 59 2c                 mov     (0x2c, sp), d1
4841a42a: dd ab 75 be 03 00 00  call    0x4c0019d5, 0, 0
4841a431: 5c 28                 mov     (0x28, sp), a0
4841a433: e3                    add     d0, d3
4841a434: f1 d8                 mov     a2, d0
4841a436: e0                    add     d0, d0
4841a437: f4                    movhu   d3, (d0, a0)
4841a438: f0 5c                 movbu   d3, (a0)
4841a43a: 34 48 f0              movbu   (0xf048), d0
4841a43d: 64                    mov     d1, (a0)
4841a43e: 88                    mov     d2, d0
4841a43f: 1e                    exthu   d2
4841a440: a6                    cmp     d1, d2
4841a441: c3 c0                 ble     0x4841a401
4841a443: fa b0 bc 01           mov     (0x1bc, sp), a0
4841a447: 43 10                 mov     a0, (0x10, sp)
4841a449: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a44d: fa b5 b8 01           mov     (0x1b8, sp), d1
4841a451: dd 18 f1 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841a458: 00                    clr     d0
4841a459: cc b8 09              jmp     0x4841ae11
4841a45c: fa b0 bc 01           mov     (0x1bc, sp), a0
4841a460: 43 10                 mov     a0, (0x10, sp)
4841a462: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a466: fa b5 b8 01           mov     (0x1b8, sp), d1
4841a46a: dd ff f0 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841a471: fa b4 b4 01           mov     (0x1b4, sp), d0
4841a475: dd a5 34 01 00 00 00  call    0x4842d91a, 0, 0
4841a47c: 92                    mov     a0, a2

AcGridBoxProc:
4841ae18: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841ae1a: f8 fe ec              add     -0x14, sp
4841ae1d: 83                    mov     d0, d3
4841ae1e: 86                    mov     d1, d2
4841ae1f: fc ca 01 00 05 00     cmp     0x50001, d2
4841ae25: c2 05                 bge     0x4841ae2a
4841ae27: cc fb 02              jmp     0x4841b122
4841ae2a: fc ca 81 00 06 00     cmp     0x60081, d2
4841ae30: c3 05                 ble     0x4841ae35
4841ae32: cc f0 02              jmp     0x4841b122
4841ae35: fc dd b0 1c 5a 48     mov     0x485a1cb0, a1
4841ae3b: 80 0f                 mov     0xf, d0
4841ae3d: fc cd 00 00 fb ff     mov     0xfffb0000, d1
4841ae43: e9                    add     d2, d1
4841ae44: f2 04                 and     d1, d0
4841ae46: f8 c0 03              asl     3, d0
4841ae49: 94                    mov     a1, a0
4841ae4a: f1 60                 add     d0, a0
4841ae4c: 70                    mov     (a0), d0
4841ae4d: a4                    cmp     d1, d0
4841ae4e: c8 18                 beq     0x4841ae66
4841ae50: db                    setlb
4841ae51: a0 00                 cmp     0, d0
4841ae53: c9 05                 bne     0x4841ae58
4841ae55: cc cd 02              jmp     0x4841b122
4841ae58: 20 08                 add     8, a0
4841ae5a: fc d8 30 1d 5a 48     cmp     0x485a1d30, a0
4841ae60: c4 03                 bcs     0x4841ae63
4841ae62: 94                    mov     a1, a0
4841ae63: 70                    mov     (a0), d0
4841ae64: a4                    cmp     d1, d0
4841ae65: d9                    lne
4841ae66: f8 20 04              mov     (4, a0), a0
4841ae69: f0 f4                 jmp     (a0)
4841ae6b: 8c                    mov     d3, d0
4841ae6c: dd ae 2a 01 00 00 00  call    0x4842d91a, 0, 0
4841ae73: 5e 34                 mov     (0x34, sp), a2
4841ae75: 93                    mov     a0, a3
4841ae76: f8 03 4c              mov     (0x4c, a3), d0
4841ae79: 4b 10                 mov     a2, (0x10, sp)
4841ae7b: 89                    mov     d2, d1
4841ae7c: dd 04 fe 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841ae83: 4b 10                 mov     a2, (0x10, sp)
4841ae85: 8c                    mov     d3, d0
4841ae86: 89                    mov     d2, d1
4841ae87: dd e2 e6 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841ae8e: 23 1c                 add     0x1c, a3
4841ae90: 00                    clr     d0
4841ae91: 42 10                 mov     d0, (0x10, sp)
4841ae93: 8c                    mov     d3, d0
4841ae94: fc cd 83 00 06 00     mov     0x00060083, d1
4841ae9a: dd f3 e4 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841aea1: f0 67                 movhu   (a3), d1
4841aea3: 82                    mov     d0, d2
4841aea4: f8 c6 10              lsr     16, d2
4841aea7: fa e2 ff ff           and     0xffff, d2
4841aeab: 19                    exth    d1
4841aeac: 88                    mov     d2, d0
4841aead: 1c                    exthu   d0
4841aeae: e4                    add     d1, d0
4841aeaf: 42 10                 mov     d0, (0x10, sp)
4841aeb1: 8c                    mov     d3, d0
4841aeb2: fc cd 0f 00 05 00     mov     0x0005000f, d1
4841aeb8: cd 20 c8 00 0c        call    0x484176d8, 0, 0xc
4841aebd: f0 67                 movhu   (a3), d1
4841aebf: 1e                    exthu   d2
4841aec0: 19                    exth    d1
4841aec1: e6                    add     d1, d2
4841aec2: 4a 10                 mov     d2, (0x10, sp)
4841aec4: 8c                    mov     d3, d0
4841aec5: fc cd 10 00 05 00     mov     0x00050010, d1
4841aecb: cd 2c c8 00 0c        call    0x484176f7, 0, 0xc
4841aed0: 80 01                 mov     1, d0
4841aed2: cd 45 c7 80 18        call    0x48417617, [d2], 0x18
4841aed7: 00                    clr     d0
4841aed8: df f0 24              ret     [d2,d3,a2,a3], 0x24
4841aedb: 5f 34                 mov     (0x34, sp), a3
4841aedd: 8c                    mov     d3, d0
4841aede: 4f 10                 mov     a3, (0x10, sp)
4841aee0: 89                    mov     d2, d1
4841aee1: dd 88 e6 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841aee8: 4f 10                 mov     a3, (0x10, sp)
4841aeea: 8c                    mov     d3, d0
4841aeeb: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841aef1: dd 9c e4 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841aef8: a0 00                 cmp     0, d0
4841aefa: c8 71                 beq     0x4841af6b
4841aefc: 00                    clr     d0
4841aefd: 42 10                 mov     d0, (0x10, sp)
4841aeff: 8c                    mov     d3, d0
4841af00: fc cd 83 00 06 00     mov     0x00060083, d1
4841af06: dd 87 e4 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841af0d: 81                    mov     d0, d1
4841af0e: f8 c5 10              lsr     16, d1
4841af11: fa e1 ff ff           and     0xffff, d1
4841af15: 86                    mov     d1, d2
4841af16: 18                    exth    d0
4841af17: 28 ff                 add     -1, d0
4841af19: 1c                    exthu   d0
4841af1a: fc c0 00 00 ff ff     add     0xffff0000, d0
4841af20: 42 10                 mov     d0, (0x10, sp)
4841af22: 8c                    mov     d3, d0
4841af23: fc cd b3 00 06 00     mov     0x000600b3, d1
4841af29: dd 64 e4 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841af30: 4f 10                 mov     a3, (0x10, sp)
4841af32: 8c                    mov     d3, d0
4841af33: fc cd 11 00 05 00     mov     0x00050011, d1
4841af39: cd 07 c8 f0 2c        call    0x48417740, [d2,d3,a2,a3], 0x2c
4841af3e: 1a                    exth    d2
4841af3f: f1 ea                 mov     d2, a2
4841af41: 99                    mov     a2, a1
4841af42: f1 7d                 add     a3, a1
4841af44: 47 10                 mov     a1, (0x10, sp)
4841af46: 8c                    mov     d3, d0
4841af47: fc cd 0f 00 05 00     mov     0x0005000f, d1
4841af4d: cd 8b c7 00 0c        call    0x484176d8, 0, 0xc
4841af52: f1 7e                 add     a3, a2
4841af54: 4b 10                 mov     a2, (0x10, sp)
4841af56: fc cd 10 00 05 00     mov     0x00050010, d1
4841af5c: 8c                    mov     d3, d0
4841af5d: cd 9a c7 00 0c        call    0x484176f7, 0, 0xc
4841af62: 80 01                 mov     1, d0
4841af64: cd b3 c6 80 18        call    0x48417617, [d2], 0x18
4841af69: ca 5c                 bra     0x4841afc5
4841af6b: 4f 10                 mov     a3, (0x10, sp)
4841af6d: 8c                    mov     d3, d0
4841af6e: fc cd 85 00 06 00     mov     0x00060085, d1
4841af74: dd 19 e4 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841af7b: a0 00                 cmp     0, d0
4841af7d: c8 48                 beq     0x4841afc5
4841af7f: 8c                    mov     d3, d0
4841af80: dd 9a 29 01 00 00 00  call    0x4842d91a, 0, 0
4841af87: f8 00 4c              mov     (0x4c, a0), d0
4841af8a: 4f 10                 mov     a3, (0x10, sp)
4841af8c: 89                    mov     d2, d1
4841af8d: dd f3 fc 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841af94: 4f 10                 mov     a3, (0x10, sp)
4841af96: 8c                    mov     d3, d0
4841af97: fc cd 11 00 05 00     mov     0x00050011, d1
4841af9d: cd a3 c7 f0 2c        call    0x48417740, [d2,d3,a2,a3], 0x2c
4841afa2: 4f 10                 mov     a3, (0x10, sp)
4841afa4: 8c                    mov     d3, d0
4841afa5: fc cd 0f 00 05 00     mov     0x0005000f, d1
4841afab: cd 2d c7 00 0c        call    0x484176d8, 0, 0xc
4841afb0: 4f 10                 mov     a3, (0x10, sp)
4841afb2: fc cd 10 00 05 00     mov     0x00050010, d1
4841afb8: 8c                    mov     d3, d0
4841afb9: cd 3e c7 00 0c        call    0x484176f7, 0, 0xc
4841afbe: 80 01                 mov     1, d0
4841afc0: cd 57 c6 80 18        call    0x48417617, [d2], 0x18
4841afc5: 00                    clr     d0
4841afc6: df f0 24              ret     [d2,d3,a2,a3], 0x24
4841afc9: 5f 34                 mov     (0x34, sp), a3
4841afcb: 8c                    mov     d3, d0
4841afcc: 4f 10                 mov     a3, (0x10, sp)
4841afce: 89                    mov     d2, d1
4841afcf: dd 9a e5 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841afd6: 4f 10                 mov     a3, (0x10, sp)
4841afd8: 8c                    mov     d3, d0
4841afd9: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841afdf: dd ae e3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841afe6: a0 00                 cmp     0, d0
4841afe8: c8 6f                 beq     0x4841b057
4841afea: 00                    clr     d0
4841afeb: 42 10                 mov     d0, (0x10, sp)
4841afed: 8c                    mov     d3, d0
4841afee: fc cd 83 00 06 00     mov     0x00060083, d1
4841aff4: dd 99 e3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841affb: 82                    mov     d0, d2
4841affc: f8 c6 10              lsr     16, d2
4841afff: fa e2 ff ff           and     0xffff, d2
4841b003: 18                    exth    d0
4841b004: 40                    inc     d0
4841b005: 1c                    exthu   d0
4841b006: fc c0 00 00 ff ff     add     0xffff0000, d0
4841b00c: 42 10                 mov     d0, (0x10, sp)
4841b00e: 8c                    mov     d3, d0
4841b00f: fc cd b3 00 06 00     mov     0x000600b3, d1
4841b015: dd 78 e3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b01c: 4f 10                 mov     a3, (0x10, sp)
4841b01e: 8c                    mov     d3, d0
4841b01f: fc cd 12 00 05 00     mov     0x00050012, d1
4841b025: cd 1b c7 f0 2c        call    0x48417740, [d2,d3,a2,a3], 0x2c
4841b02a: 1a                    exth    d2
4841b02b: f1 ea                 mov     d2, a2
4841b02d: 98                    mov     a2, a0
4841b02e: f1 7c                 add     a3, a0
4841b030: 43 10                 mov     a0, (0x10, sp)
4841b032: 8c                    mov     d3, d0
4841b033: fc cd 0f 00 05 00     mov     0x0005000f, d1
4841b039: cd 9f c6 00 0c        call    0x484176d8, 0, 0xc
4841b03e: f1 7e                 add     a3, a2
4841b040: 4b 10                 mov     a2, (0x10, sp)
4841b042: fc cd 10 00 05 00     mov     0x00050010, d1
4841b048: 8c                    mov     d3, d0
4841b049: cd ae c6 00 0c        call    0x484176f7, 0, 0xc
4841b04e: 80 01                 mov     1, d0
4841b050: cd c7 c5 80 18        call    0x48417617, [d2], 0x18
4841b055: ca 5c                 bra     0x4841b0b1
4841b057: 4f 10                 mov     a3, (0x10, sp)
4841b059: 8c                    mov     d3, d0
4841b05a: fc cd 85 00 06 00     mov     0x00060085, d1
4841b060: dd 2d e3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b067: a0 00                 cmp     0, d0
4841b069: c8 48                 beq     0x4841b0b1
4841b06b: 8c                    mov     d3, d0
4841b06c: dd ae 28 01 00 00 00  call    0x4842d91a, 0, 0
4841b073: f8 00 4c              mov     (0x4c, a0), d0
4841b076: 4f 10                 mov     a3, (0x10, sp)
4841b078: 89                    mov     d2, d1
4841b079: dd 07 fc 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841b080: 4f 10                 mov     a3, (0x10, sp)
4841b082: 8c                    mov     d3, d0
4841b083: fc cd 12 00 05 00     mov     0x00050012, d1
4841b089: cd b7 c6 f0 2c        call    0x48417740, [d2,d3,a2,a3], 0x2c
4841b08e: 4f 10                 mov     a3, (0x10, sp)
4841b090: 8c                    mov     d3, d0
4841b091: fc cd 0f 00 05 00     mov     0x0005000f, d1
4841b097: cd 41 c6 00 0c        call    0x484176d8, 0, 0xc
4841b09c: 4f 10                 mov     a3, (0x10, sp)
4841b09e: fc cd 10 00 05 00     mov     0x00050010, d1
4841b0a4: 8c                    mov     d3, d0
4841b0a5: cd 52 c6 00 0c        call    0x484176f7, 0, 0xc
4841b0aa: 80 01                 mov     1, d0
4841b0ac: cd 6b c5 80 18        call    0x48417617, [d2], 0x18
4841b0b1: 00                    clr     d0
4841b0b2: df f0 24              ret     [d2,d3,a2,a3], 0x24
4841b0b5: 8c                    mov     d3, d0
4841b0b6: dd 64 28 01 00 00 00  call    0x4842d91a, 0, 0
4841b0bd: f8 24 44              mov     (0x44, a0), a1
4841b0c0: 5c 34                 mov     (0x34, sp), a0
4841b0c2: dd 8f 7f be 03 20 04  call    0x4c003051, [a2], 4
4841b0c9: 00                    clr     d0
4841b0ca: ca 65                 bra     0x4841b12f
4841b0cc: 8c                    mov     d3, d0
4841b0cd: dd 4d 28 01 00 00 00  call    0x4842d91a, 0, 0
4841b0d4: f8 24 48              mov     (0x48, a0), a1
4841b0d7: 5c 34                 mov     (0x34, sp), a0
4841b0d9: dd 78 7f be 03 20 04  call    0x4c003051, [a2], 4
4841b0e0: 00                    clr     d0
4841b0e1: ca 4e                 bra     0x4841b12f
4841b0e3: 5e 34                 mov     (0x34, sp), a2
4841b0e5: 8c                    mov     d3, d0
4841b0e6: 4b 10                 mov     a2, (0x10, sp)
4841b0e8: 89                    mov     d2, d1
4841b0e9: dd 80 e4 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841b0f0: 8c                    mov     d3, d0
4841b0f1: dd 29 28 01 00 00 00  call    0x4842d91a, 0, 0
4841b0f8: f8 00 4c              mov     (0x4c, a0), d0
4841b0fb: 4b 10                 mov     a2, (0x10, sp)
4841b0fd: 89                    mov     d2, d1
4841b0fe: dd 82 fb 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841b105: 00                    clr     d0
4841b106: ca 29                 bra     0x4841b12f
4841b108: 8c                    mov     d3, d0
4841b109: dd 11 28 01 00 00 00  call    0x4842d91a, 0, 0
4841b110: f8 00 4c              mov     (0x4c, a0), d0
4841b113: 5c 34                 mov     (0x34, sp), a0
4841b115: 89                    mov     d2, d1
4841b116: 43 10                 mov     a0, (0x10, sp)
4841b118: dd 68 fb 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841b11f: 00                    clr     d0
4841b120: ca 0f                 bra     0x4841b12f
4841b122: 5c 34                 mov     (0x34, sp), a0
4841b124: 89                    mov     d2, d1
4841b125: 43 10                 mov     a0, (0x10, sp)
4841b127: 8c                    mov     d3, d0
4841b128: dd 41 e4 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841b12f: df f0 24              ret     [d2,d3,a2,a3], 0x24
4841b132: f8 fe d4              add     -0x2c, sp
4841b135: fc c9 11 00 05 00     cmp     0x50011, d1
4841b13b: c8 3c                 beq     0x4841b177
4841b13d: fc c9 0f 00 05 00     cmp     0x5000f, d1
4841b143: c8 34                 beq     0x4841b177
4841b145: fc c9 12 00 05 00     cmp     0x50012, d1
4841b14b: c8 2c                 beq     0x4841b177
4841b14d: fc c9 10 00 05 00     cmp     0x50010, d1
4841b153: c8 24                 beq     0x4841b177
4841b155: fc c9 14 00 05 00     cmp     0x50014, d1
4841b15b: c8 1c                 beq     0x4841b177
4841b15d: fc c9 15 00 05 00     cmp     0x50015, d1
4841b163: c8 14                 beq     0x4841b177
4841b165: fc c9 81 00 06 00     cmp     0x60081, d1
4841b16b: c8 0f                 beq     0x4841b17a
4841b16d: fc c9 00 00 05 00     cmp     0x50000, d1
4841b173: c8 5b                 beq     0x4841b1ce
4841b175: ca 58                 bra     0x4841b1cd
4841b177: 00                    clr     d0
4841b178: ca 56                 bra     0x4841b1ce
4841b17a: 58 3c                 mov     (0x3c, sp), d0
4841b17c: 3c                    mov     sp, a0
4841b17d: f8 c4 10              lsr     16, d0
4841b180: fa e0 ff ff           and     0xffff, d0
4841b184: f8 93 18              movhu   d0, (0x18, sp)
4841b187: 59 3c                 mov     (0x3c, sp), d1
4841b189: f1 d0                 mov     a0, d0
4841b18b: f8 97 1a              movhu   d1, (0x1a, sp)
4841b18e: 28 20                 add     0x20, d0
4841b190: 42 1c                 mov     d0, (0x1c, sp)
4841b192: 42 08                 mov     d0, (8, sp)
4841b194: fc cc 60 f1 59 48     mov     0x4859f160, d0
4841b19a: 42 0c                 mov     d0, (0xc, sp)
4841b19c: f8 bc 18              movhu   (0x18, sp), d0
4841b19f: 18                    exth    d0
4841b1a0: 42 10                 mov     d0, (0x10, sp)
4841b1a2: f8 bc 1a              movhu   (0x1a, sp), d0
4841b1a5: 18                    exth    d0
4841b1a6: 42 14                 mov     d0, (0x14, sp)
4841b1a8: dd a0 68 be 03 20 20  call    0x4c001a48, [a2], 0x20
4841b1af: dd 47 e5 00 00 00 10  call    0x484296f6, 0, 0x10
4841b1b6: 3c                    mov     sp, a0
4841b1b7: 20 18                 add     0x18, a0
4841b1b9: 43 10                 mov     a0, (0x10, sp)
4841b1bb: fc cd 80 00 06 00     mov     0x00060080, d1
4841b1c1: dd cc e1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b1c8: 00                    clr     d0
4841b1c9: ca 05                 bra     0x4841b1ce
4841b1cb: ca 03                 bra     0x4841b1ce
4841b1cd: 00                    clr     d0
4841b1ce: df 00 2c              ret     0, 0x2c

PsEditBoxProc:
4841b1d1: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841b1d3: f8 fe b0              add     -0x50, sp
4841b1d6: 42 68                 mov     d0, (0x68, sp)
4841b1d8: 86                    mov     d1, d2
4841b1d9: fc ca 01 00 05 00     cmp     0x50001, d2
4841b1df: c2 05                 bge     0x4841b1e4
4841b1e1: cc f1 06              jmp     0x4841b8d2
4841b1e4: fc ca c6 00 06 00     cmp     0x600c6, d2
4841b1ea: c3 05                 ble     0x4841b1ef
4841b1ec: cc e6 06              jmp     0x4841b8d2
4841b1ef: fc dd 30 1d 5a 48     mov     0x485a1d30, a1
4841b1f5: 80 1f                 mov     0x1f, d0
4841b1f7: fc cd 00 00 fb ff     mov     0xfffb0000, d1
4841b1fd: e9                    add     d2, d1
4841b1fe: f2 04                 and     d1, d0
4841b200: f8 c0 03              asl     3, d0
4841b203: f1 e0                 mov     d0, a0
4841b205: f1 74                 add     a1, a0
4841b207: 70                    mov     (a0), d0
4841b208: a4                    cmp     d1, d0
4841b209: c8 18                 beq     0x4841b221
4841b20b: db                    setlb
4841b20c: a0 00                 cmp     0, d0
4841b20e: c9 05                 bne     0x4841b213
4841b210: cc c2 06              jmp     0x4841b8d2
4841b213: 20 08                 add     8, a0
4841b215: fc d8 30 1e 5a 48     cmp     0x485a1e30, a0
4841b21b: c4 03                 bcs     0x4841b21e
4841b21d: 94                    mov     a1, a0
4841b21e: 70                    mov     (a0), d0
4841b21f: a4                    cmp     d1, d0
4841b220: d9                    lne
4841b221: f8 20 04              mov     (4, a0), a0
4841b224: f0 f4                 jmp     (a0)
4841b226: 58 68                 mov     (0x68, sp), d0
4841b228: dd f2 26 01 00 00 00  call    0x4842d91a, 0, 0
4841b22f: 93                    mov     a0, a3
4841b230: 9a 34                 mov     0x34, a2
4841b232: f1 7e                 add     a3, a2
4841b234: f0 02                 mov     (a2), a0
4841b236: 5d 70                 mov     (0x70, sp), a1
4841b238: 70                    mov     (a0), d0
4841b239: f1 94                 cmp     a1, d0
4841b23b: c8 2a                 beq     0x4841b265
4841b23d: f0 02                 mov     (a2), a0
4841b23f: 00                    clr     d0
4841b240: f0 14                 mov     a1, (a0)
4841b242: 42 10                 mov     d0, (0x10, sp)
4841b244: 58 68                 mov     (0x68, sp), d0
4841b246: fc cd b3 00 06 00     mov     0x000600b3, d1
4841b24c: dd 41 e1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b253: 00                    clr     d0
4841b254: 42 10                 mov     d0, (0x10, sp)
4841b256: 58 68                 mov     (0x68, sp), d0
4841b258: fc cd b4 00 06 00     mov     0x000600b4, d1
4841b25e: dd 2f e1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b265: f0 02                 mov     (a2), a0
4841b267: 70                    mov     (a0), d0
4841b268: a0 00                 cmp     0, d0
4841b26a: c8 42                 beq     0x4841b2ac
4841b26c: f8 03 30              mov     (0x30, a3), d0
4841b26f: a0 00                 cmp     0, d0
4841b271: c8 3b                 beq     0x4841b2ac
4841b273: 00                    clr     d0
4841b274: 42 10                 mov     d0, (0x10, sp)
4841b276: 58 68                 mov     (0x68, sp), d0
4841b278: fc cd 4e 00 06 00     mov     0x0006004e, d1
4841b27e: dd 0f e1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b285: 82                    mov     d0, d2
4841b286: 1a                    exth    d2
4841b287: 4a 10                 mov     d2, (0x10, sp)
4841b289: 58 68                 mov     (0x68, sp), d0
4841b28b: fc cd 0f 00 05 00     mov     0x0005000f, d1
4841b291: cd 47 c4 00 0c        call    0x484176d8, 0, 0xc
4841b296: 4a 10                 mov     d2, (0x10, sp)
4841b298: 58 68                 mov     (0x68, sp), d0
4841b29a: fc cd 10 00 05 00     mov     0x00050010, d1
4841b2a0: cd 57 c4 00 0c        call    0x484176f7, 0, 0xc
4841b2a5: 80 01                 mov     1, d0
4841b2a7: cd 70 c3 80 18        call    0x48417617, [d2], 0x18
4841b2ac: 00                    clr     d0
4841b2ad: df f0 60              ret     [d2,d3,a2,a3], 0x60
4841b2b0: 5c 70                 mov     (0x70, sp), a0
4841b2b2: 89                    mov     d2, d1
4841b2b3: 43 10                 mov     a0, (0x10, sp)
4841b2b5: 58 68                 mov     (0x68, sp), d0
4841b2b7: dd b2 e2 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841b2be: 58 68                 mov     (0x68, sp), d0
4841b2c0: dd 5a 26 01 00 00 00  call    0x4842d91a, 0, 0
4841b2c7: f8 60 2e              movhu   (0x2e, a0), d0
4841b2ca: fa c8 ff 00           cmp     0xff, d0
4841b2ce: c8 2d                 beq     0x4841b2fb
4841b2d0: 00                    clr     d0
4841b2d1: 42 10                 mov     d0, (0x10, sp)
4841b2d3: 58 68                 mov     (0x68, sp), d0
4841b2d5: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841b2db: dd b2 e0 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b2e2: a0 00                 cmp     0, d0
4841b2e4: c8 32                 beq     0x4841b316
4841b2e6: 80 01                 mov     1, d0
4841b2e8: 42 10                 mov     d0, (0x10, sp)
4841b2ea: 58 68                 mov     (0x68, sp), d0
4841b2ec: fc cd 4a 00 06 00     mov     0x0006004a, d1
4841b2f2: dd 9b e0 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b2f9: ca 1d                 bra     0x4841b316
4841b2fb: f8 20 34              mov     (0x34, a0), a0
4841b2fe: 70                    mov     (a0), d0
4841b2ff: a0 00                 cmp     0, d0
4841b301: c8 15                 beq     0x4841b316
4841b303: 80 01                 mov     1, d0
4841b305: 42 10                 mov     d0, (0x10, sp)
4841b307: 58 68                 mov     (0x68, sp), d0
4841b309: fc cd 4a 00 06 00     mov     0x0006004a, d1
4841b30f: dd 7e e0 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b316: 00                    clr     d0
4841b317: df f0 60              ret     [d2,d3,a2,a3], 0x60
4841b31a: 5c 70                 mov     (0x70, sp), a0
4841b31c: 89                    mov     d2, d1
4841b31d: 43 10                 mov     a0, (0x10, sp)
4841b31f: 58 68                 mov     (0x68, sp), d0
4841b321: dd 48 e2 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841b328: 58 68                 mov     (0x68, sp), d0
4841b32a: dd f0 25 01 00 00 00  call    0x4842d91a, 0, 0
4841b331: 43 30                 mov     a0, (0x30, sp)
4841b333: 00                    clr     d0
4841b334: 42 10                 mov     d0, (0x10, sp)
4841b336: 58 68                 mov     (0x68, sp), d0
4841b338: fc cd af 00 06 00     mov     0x000600af, d1
4841b33e: dd 4f e0 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b345: 42 34                 mov     d0, (0x34, sp)
4841b347: 00                    clr     d0
4841b348: 42 10                 mov     d0, (0x10, sp)
4841b34a: 58 68                 mov     (0x68, sp), d0
4841b34c: fc cd a3 00 06 00     mov     0x000600a3, d1
4841b352: dd 3b e0 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b359: f8 93 3e              movhu   d0, (0x3e, sp)
4841b35c: 00                    clr     d0
4841b35d: 42 10                 mov     d0, (0x10, sp)
4841b35f: 58 68                 mov     (0x68, sp), d0
4841b361: fc cd ae 00 06 00     mov     0x000600ae, d1
4841b367: dd 26 e0 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b36e: f8 93 3c              movhu   d0, (0x3c, sp)
4841b371: 5c 30                 mov     (0x30, sp), a0
4841b373: f8 60 2e              movhu   (0x2e, a0), d0
4841b376: cd aa 24 f0 48        call    0x4841d820, [d2,d3,a2,a3], 0x48
4841b37b: 3c                    mov     sp, a0
4841b37c: f1 d0                 mov     a0, d0
4841b37e: 28 44                 add     0x44, d0
4841b380: 42 2c                 mov     d0, (0x2c, sp)
4841b382: 58 68                 mov     (0x68, sp), d0
4841b384: 5c 2c                 mov     (0x2c, sp), a0
4841b386: cd 5f b7 00 14        call    0x48416ae5, 0, 0x14
4841b38b: 2c 00 01              mov     0x100, d0
4841b38e: cd 9c b2 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841b393: 43 28                 mov     a0, (0x28, sp)
4841b395: 2c 00 01              mov     0x100, d0
4841b398: cd 92 b2 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841b39d: 93                    mov     a0, a3
4841b39e: 5c 28                 mov     (0x28, sp), a0
4841b3a0: 43 10                 mov     a0, (0x10, sp)
4841b3a2: 58 68                 mov     (0x68, sp), d0
4841b3a4: fc cd c6 00 06 00     mov     0x000600c6, d1
4841b3aa: dd e3 df 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b3b1: 5c 28                 mov     (0x28, sp), a0
4841b3b3: 9d                    mov     a3, a1
4841b3b4: 58 34                 mov     (0x34, sp), d0
4841b3b6: dd f7 2b 01 00 f0 20  call    0x4842dfad, [d2,d3,a2,a3], 0x20
4841b3bd: 9c                    mov     a3, a0
4841b3be: dd 39 7f be 03 00 00  call    0x4c0032f7, 0, 0
4841b3c5: f1 e2                 mov     d0, a2
4841b3c7: 9c                    mov     a3, a0
4841b3c8: dd 2f 7f be 03 00 00  call    0x4c0032f7, 0, 0
4841b3cf: 83                    mov     d0, d3
4841b3d0: f8 bc 48              movhu   (0x48, sp), d0
4841b3d3: 18                    exth    d0
4841b3d4: f1 e1                 mov     d0, a1
4841b3d6: f8 bd 44              movhu   (0x44, sp), d1
4841b3d9: 5c 30                 mov     (0x30, sp), a0
4841b3db: f8 be 44              movhu   (0x44, sp), d2
4841b3de: f8 60 2c              movhu   (0x2c, a0), d0
4841b3e1: 1a                    exth    d2
4841b3e2: 4a 40                 mov     d2, (0x40, sp)
4841b3e4: 19                    exth    d1
4841b3e5: f1 25                 sub     d1, a1
4841b3e7: f1 d6                 mov     a1, d2
4841b3e9: f1 d9                 mov     a2, d1
4841b3eb: cb                    nop
4841b3ec: cb                    nop
4841b3ed: f2 59                 mulu    d2, d1
4841b3ef: 5a 40                 mov     (0x40, sp), d2
4841b3f1: ec                    add     d3, d0
4841b3f2: 3e                    mov     sp, a2
4841b3f3: 22 4c                 add     0x4c, a2
4841b3f5: 99                    mov     a2, a1
4841b3f6: 0c                    clr     d3
4841b3f7: f2 fe                 mov     d3, mdr
4841b3f9: f2 71                 divu    d0, d1
4841b3fb: e9                    add     d2, d1
4841b3fc: f8 97 48              movhu   d1, (0x48, sp)
4841b3ff: 5c 2c                 mov     (0x2c, sp), a0
4841b401: cd 32 ba f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841b406: 58 28                 mov     (0x28, sp), d0
4841b408: 99                    mov     a2, a1
4841b409: 42 10                 mov     d0, (0x10, sp)
4841b40b: f8 bc 3e              movhu   (0x3e, sp), d0
4841b40e: 18                    exth    d0
4841b40f: 42 1c                 mov     d0, (0x1c, sp)
4841b411: 5c 30                 mov     (0x30, sp), a0
4841b413: f8 40 2a              movbu   (0x2a, a0), d0
4841b416: 42 20                 mov     d0, (0x20, sp)
4841b418: f8 bd 3c              movhu   (0x3c, sp), d1
4841b41b: 5c 2c                 mov     (0x2c, sp), a0
4841b41d: 19                    exth    d1
4841b41e: 58 34                 mov     (0x34, sp), d0
4841b420: dd a4 a6 00 00 a0 28  call    0x48425ac4, [d2,a2], 0x28
4841b427: 00                    clr     d0
4841b428: fc cd b3 00 06 00     mov     0x000600b3, d1
4841b42e: 42 10                 mov     d0, (0x10, sp)
4841b430: 58 68                 mov     (0x68, sp), d0
4841b432: dd 5b df 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b439: 9c                    mov     a3, a0
4841b43a: cd a4 b2 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841b43f: 5c 28                 mov     (0x28, sp), a0
4841b441: cd 9d b2 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841b446: 00                    clr     d0
4841b447: df f0 60              ret     [d2,d3,a2,a3], 0x60
4841b44a: 58 68                 mov     (0x68, sp), d0
4841b44c: dd ce 24 01 00 00 00  call    0x4842d91a, 0, 0
4841b453: f8 60 2e              movhu   (0x2e, a0), d0
4841b456: fa c8 ff 00           cmp     0xff, d0
4841b45a: c8 25                 beq     0x4841b47f
4841b45c: 00                    clr     d0
4841b45d: 42 10                 mov     d0, (0x10, sp)
4841b45f: 58 68                 mov     (0x68, sp), d0
4841b461: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841b467: dd 26 df 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b46e: 42 10                 mov     d0, (0x10, sp)
4841b470: 58 68                 mov     (0x68, sp), d0
4841b472: fc cd 4b 00 06 00     mov     0x0006004b, d1
4841b478: dd 15 df 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b47f: 00                    clr     d0
4841b480: df f0 60              ret     [d2,d3,a2,a3], 0x60
4841b483: 58 68                 mov     (0x68, sp), d0
4841b485: dd 95 24 01 00 00 00  call    0x4842d91a, 0, 0
4841b48c: 43 30                 mov     a0, (0x30, sp)
4841b48e: 00                    clr     d0
4841b48f: 42 10                 mov     d0, (0x10, sp)
4841b491: 58 68                 mov     (0x68, sp), d0
4841b493: fc cd af 00 06 00     mov     0x000600af, d1
4841b499: dd f4 de 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b4a0: 42 38                 mov     d0, (0x38, sp)
4841b4a2: 00                    clr     d0
4841b4a3: 42 10                 mov     d0, (0x10, sp)
4841b4a5: 58 68                 mov     (0x68, sp), d0
4841b4a7: fc cd a3 00 06 00     mov     0x000600a3, d1
4841b4ad: dd e0 de 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b4b4: f8 93 3e              movhu   d0, (0x3e, sp)
4841b4b7: 00                    clr     d0
4841b4b8: 42 10                 mov     d0, (0x10, sp)
4841b4ba: 58 68                 mov     (0x68, sp), d0
4841b4bc: fc cd ae 00 06 00     mov     0x000600ae, d1
4841b4c2: dd cb de 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b4c9: f8 93 3c              movhu   d0, (0x3c, sp)
4841b4cc: 3c                    mov     sp, a0
4841b4cd: f1 d0                 mov     a0, d0
4841b4cf: 28 44                 add     0x44, d0
4841b4d1: 42 34                 mov     d0, (0x34, sp)
4841b4d3: 58 68                 mov     (0x68, sp), d0
4841b4d5: 5c 34                 mov     (0x34, sp), a0
4841b4d7: cd 0e b6 00 14        call    0x48416ae5, 0, 0x14
4841b4dc: 2c 00 01              mov     0x100, d0
4841b4df: cd 4b b1 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841b4e4: 43 2c                 mov     a0, (0x2c, sp)
4841b4e6: 2c 00 01              mov     0x100, d0
4841b4e9: cd 41 b1 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841b4ee: 43 28                 mov     a0, (0x28, sp)
4841b4f0: 5c 2c                 mov     (0x2c, sp), a0
4841b4f2: fc cd c6 00 06 00     mov     0x000600c6, d1
4841b4f8: 43 10                 mov     a0, (0x10, sp)
4841b4fa: 58 68                 mov     (0x68, sp), d0
4841b4fc: dd 91 de 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b503: 5c 2c                 mov     (0x2c, sp), a0
4841b505: 5d 28                 mov     (0x28, sp), a1
4841b507: 58 38                 mov     (0x38, sp), d0
4841b509: dd a4 2a 01 00 f0 20  call    0x4842dfad, [d2,d3,a2,a3], 0x20
4841b510: 5c 28                 mov     (0x28, sp), a0
4841b512: dd e5 7d be 03 00 00  call    0x4c0032f7, 0, 0
4841b519: 5c 30                 mov     (0x30, sp), a0
4841b51b: f8 bf 48              movhu   (0x48, sp), d3
4841b51e: 20 2c                 add     0x2c, a0
4841b520: f8 bd 44              movhu   (0x44, sp), d1
4841b523: f0 68                 movhu   (a0), d2
4841b525: f1 e2                 mov     d0, a2
4841b527: f8 bc 48              movhu   (0x48, sp), d0
4841b52a: 1b                    exth    d3
4841b52b: 18                    exth    d0
4841b52c: f1 e1                 mov     d0, a1
4841b52e: f0 60                 movhu   (a0), d0
4841b530: 19                    exth    d1
4841b531: f1 07                 sub     d1, d3
4841b533: 8d                    mov     d3, d1
4841b534: cb                    nop
4841b535: cb                    nop
4841b536: f2 41                 mul     d0, d1
4841b538: f1 d8                 mov     a2, d0
4841b53a: e8                    add     d2, d0
4841b53b: 08                    clr     d2
4841b53c: f2 fa                 mov     d2, mdr
4841b53e: f2 71                 divu    d0, d1
4841b540: f1 25                 sub     d1, a1
4841b542: f1 d4                 mov     a1, d0
4841b544: f8 93 44              movhu   d0, (0x44, sp)
4841b547: f8 bc 48              movhu   (0x48, sp), d0
4841b54a: 3f                    mov     sp, a3
4841b54b: 18                    exth    d0
4841b54c: 28 fa                 add     -6, d0
4841b54e: f8 93 48              movhu   d0, (0x48, sp)
4841b551: 23 4c                 add     0x4c, a3
4841b553: 5c 34                 mov     (0x34, sp), a0
4841b555: 9d                    mov     a3, a1
4841b556: cd dd b8 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841b55b: 2c 00 01              mov     0x100, d0
4841b55e: cd cc b0 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841b563: 5d 70                 mov     (0x70, sp), a1
4841b565: 92                    mov     a0, a2
4841b566: b5 00                 cmp     0, a1
4841b568: c9 31                 bne     0x4841b599
4841b56a: 4b 10                 mov     a2, (0x10, sp)
4841b56c: 58 68                 mov     (0x68, sp), d0
4841b56e: fc cd 3a 00 06 00     mov     0x0006003a, d1
4841b574: dd 19 de 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b57b: f0 42                 movbu   (a2), d0
4841b57d: a0 00                 cmp     0, d0
4841b57f: c9 22                 bne     0x4841b5a1
4841b581: 98                    mov     a2, a0
4841b582: cd 5c b1 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841b587: 5c 28                 mov     (0x28, sp), a0
4841b589: cd 55 b1 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841b58e: 5c 2c                 mov     (0x2c, sp), a0
4841b590: cd 4e b1 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841b595: 00                    clr     d0
4841b596: df f0 60              ret     [d2,d3,a2,a3], 0x60
4841b599: 98                    mov     a2, a0
4841b59a: dd b7 7a be 03 20 04  call    0x4c003051, [a2], 4
4841b5a1: 00                    clr     d0
4841b5a2: 42 10                 mov     d0, (0x10, sp)
4841b5a4: 58 68                 mov     (0x68, sp), d0
4841b5a6: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841b5ac: dd e1 dd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841b5b3: 08                    clr     d2
4841b5b4: a8                    cmp     d2, d0
4841b5b5: c8 16                 beq     0x4841b5cb
4841b5b7: cd 15 c1 00 00        call    0x484176cc, 0, 0
4841b5bc: 59 68                 mov     (0x68, sp), d1
4841b5be: 08                    clr     d2
4841b5bf: a4                    cmp     d1, d0
4841b5c0: c9 04                 bne     0x4841b5c4
4841b5c2: 8a 01                 mov     1, d2
4841b5c4: 5c 30                 mov     (0x30, sp), a0
4841b5c6: f8 04 30              mov     (0x30, a0), d1
4841b5c9: f2 06                 and     d1, d2
4841b5cb: 4b 10                 mov     a2, (0x10, sp)
4841b5cd: f8 bc 3e              movhu   (0x3e, sp), d0
4841b5d0: 9d                    mov     a3, a1

PsNumEditBoxProc:
4841b8e3: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841b8e5: f8 fe c4              add     -0x3c, sp
4841b8e8: 82                    mov     d0, d2
4841b8e9: 87                    mov     d1, d3
4841b8ea: fc cb b4 00 06 00     cmp     0x600b4, d3
4841b8f0: c9 6f                 bne     0x4841b95f
4841b8f2: 3f                    mov     sp, a3
4841b8f3: dd 27 20 01 00 00 00  call    0x4842d91a, 0, 0
4841b8fa: 43 14                 mov     a0, (0x14, sp)
4841b8fc: 23 18                 add     0x18, a3
4841b8fe: 9c                    mov     a3, a0
4841b8ff: 3e                    mov     sp, a2
4841b900: 22 24                 add     0x24, a2
4841b902: fc dd 68 f1 59 48     mov     0x4859f168, a1
4841b908: dd 49 77 be 03 20 04  call    0x4c003051, [a2], 4
4841b90f: 4b 08                 mov     a2, (8, sp)
4841b911: fc cc 6c f1 59 48     mov     0x4859f16c, d0
4841b917: 42 0c                 mov     d0, (0xc, sp)
4841b919: 5c 14                 mov     (0x14, sp), a0
4841b91b: f8 60 38              movhu   (0x38, a0), d0
4841b91e: 18                    exth    d0
4841b91f: 42 10                 mov     d0, (0x10, sp)
4841b921: dd 27 61 be 03 20 20  call    0x4c001a48, [a2], 0x20
4841b928: 9c                    mov     a3, a0
4841b929: 99                    mov     a2, a1
4841b92a: dd 5d 80 be 03 20 04  call    0x4c003987, [a2], 4
4841b931: 9c                    mov     a3, a0
4841b932: 3e                    mov     sp, a2
4841b933: 22 30                 add     0x30, a2
4841b935: fc dd 70 f1 59 48     mov     0x4859f170, a1
4841b93b: dd 4c 80 be 03 20 04  call    0x4c003987, [a2], 4
4841b942: 4b 08                 mov     a2, (8, sp)
4841b944: 4f 0c                 mov     a3, (0xc, sp)
4841b946: 5c 5c                 mov     (0x5c, sp), a0
4841b948: 43 10                 mov     a0, (0x10, sp)
4841b94a: dd fe 60 be 03 20 20  call    0x4c001a48, [a2], 0x20
4841b951: 4b 10                 mov     a2, (0x10, sp)
4841b953: 8d                    mov     d3, d1
4841b954: 88                    mov     d2, d0
4841b955: dd 14 dc 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841b95c: 00                    clr     d0
4841b95d: ca 0d                 bra     0x4841b96a
4841b95f: 5c 5c                 mov     (0x5c, sp), a0
4841b961: 43 10                 mov     a0, (0x10, sp)
4841b963: dd 06 dc 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841b96a: df f0 4c              ret     [d2,d3,a2,a3], 0x4c

PsTblEditBoxProc:
4841b96d: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841b96f: f8 fe ec              add     -0x14, sp
4841b972: 82                    mov     d0, d2
4841b973: 87                    mov     d1, d3
4841b974: fc cb b4 00 06 00     cmp     0x600b4, d3
4841b97a: c9 3e                 bne     0x4841b9b8
4841b97c: dd 9e 1f 01 00 00 00  call    0x4842d91a, 0, 0
4841b983: 2c 00 01              mov     0x100, d0
4841b986: 92                    mov     a0, a2
4841b987: cd a3 ac b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841b98c: 5d 34                 mov     (0x34, sp), a1
4841b98e: 93                    mov     a0, a3
4841b98f: f0 17                 mov     a1, (a3)
4841b991: f8 02 38              mov     (0x38, a2), d0
4841b994: 92                    mov     a0, a2
4841b995: 4b 10                 mov     a2, (0x10, sp)
4841b997: fc cd 49 00 06 00     mov     0x00060049, d1
4841b99d: dd e3 f2 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841b9a4: 4b 10                 mov     a2, (0x10, sp)
4841b9a6: 8d                    mov     d3, d1
4841b9a7: 88                    mov     d2, d0
4841b9a8: dd c1 db 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841b9af: 9c                    mov     a3, a0
4841b9b0: cd 2e ad f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841b9b5: 00                    clr     d0
4841b9b6: ca 0d                 bra     0x4841b9c3
4841b9b8: 5c 34                 mov     (0x34, sp), a0
4841b9ba: 43 10                 mov     a0, (0x10, sp)
4841b9bc: dd ad db 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841b9c3: df f0 24              ret     [d2,d3,a2,a3], 0x24
4841b9c6: f8 fe f0              add     -0x10, sp
4841b9c9: fc c9 49 00 06 00     cmp     0x60049, d1
4841b9cf: c9 18                 bne     0x4841b9e7
4841b9d1: 5c 20                 mov     (0x20, sp), a0
4841b9d3: fc dd 84 f1 59 48     mov     0x4859f184, a1
4841b9d9: 70                    mov     (a0), d0
4841b9da: 54                    asl2    d0
4841b9db: f3 91                 mov     (d0, a1), a1
4841b9dd: dd 74 76 be 03 20 04  call    0x4c003051, [a2], 4
4841b9e4: 00                    clr     d0
4841b9e5: ca 03                 bra     0x4841b9e8
4841b9e7: 00                    clr     d0
4841b9e8: df 00 10              ret     0, 0x10

AcOnOffBoxProc:
4841b9eb: cf a0                 movm    [d2,a2], (sp)
4841b9ed: f8 fe ec              add     -0x14, sp
4841b9f0: 82                    mov     d0, d2
4841b9f1: fc c9 b2 00 06 00     cmp     0x600b2, d1
4841b9f7: c8 36                 beq     0x4841ba2d
4841b9f9: fc c9 3a 00 06 00     cmp     0x6003a, d1
4841b9ff: c8 4e                 beq     0x4841ba4d
4841ba01: fc c9 3b 00 06 00     cmp     0x6003b, d1
4841ba07: c8 68                 beq     0x4841ba6f
4841ba09: fc c9 62 00 06 00     cmp     0x60062, d1
4841ba0f: c9 05                 bne     0x4841ba14
4841ba11: cc 89 00              jmp     0x4841ba9a
4841ba14: fc c9 0f 00 05 00     cmp     0x5000f, d1
4841ba1a: c9 05                 bne     0x4841ba1f
4841ba1c: cc 8c 00              jmp     0x4841baa8
4841ba1f: fc c9 10 00 05 00     cmp     0x50010, d1
4841ba25: c9 05                 bne     0x4841ba2a
4841ba27: cc c9 00              jmp     0x4841baf0
4841ba2a: cc 0d 01              jmp     0x4841bb37
4841ba2d: 5c 2c                 mov     (0x2c, sp), a0
4841ba2f: 43 10                 mov     a0, (0x10, sp)
4841ba31: dd 38 db 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841ba38: 00                    clr     d0
4841ba39: 42 10                 mov     d0, (0x10, sp)
4841ba3b: fc cd b4 00 06 00     mov     0x000600b4, d1
4841ba41: 88                    mov     d2, d0
4841ba42: dd 4b d9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841ba49: 00                    clr     d0
4841ba4a: df a0 1c              ret     [d2,a2], 0x1c
4841ba4d: dd cd 1e 01 00 00 00  call    0x4842d91a, 0, 0
4841ba54: f8 24 38              mov     (0x38, a0), a1
4841ba57: fc dc 94 f1 59 48     mov     0x4859f194, a0
4841ba5d: 71                    mov     (a1), d0
4841ba5e: 1c                    exthu   d0
4841ba5f: 54                    asl2    d0
4841ba60: f3 90                 mov     (d0, a0), a1
4841ba62: 5c 2c                 mov     (0x2c, sp), a0
4841ba64: dd ed 75 be 03 20 04  call    0x4c003051, [a2], 4
4841ba6b: 00                    clr     d0
4841ba6c: df a0 1c              ret     [d2,a2], 0x1c
4841ba6f: dd ab 1e 01 00 00 00  call    0x4842d91a, 0, 0
4841ba76: 20 38                 add     0x38, a0
4841ba78: f0 04                 mov     (a0), a1
4841ba7a: 71                    mov     (a1), d0
4841ba7b: 5d 2c                 mov     (0x2c, sp), a1
4841ba7d: f1 94                 cmp     a1, d0
4841ba7f: c8 17                 beq     0x4841ba96
4841ba81: f0 00                 mov     (a0), a0
4841ba83: 00                    clr     d0
4841ba84: fc cd b4 00 06 00     mov     0x000600b4, d1
4841ba8a: f0 14                 mov     a1, (a0)
4841ba8c: 42 10                 mov     d0, (0x10, sp)
4841ba8e: 88                    mov     d2, d0
4841ba8f: dd fe d8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841ba96: 00                    clr     d0
4841ba97: df a0 1c              ret     [d2,a2], 0x1c
4841ba9a: dd 80 1e 01 00 00 00  call    0x4842d91a, 0, 0
4841baa1: f8 20 38              mov     (0x38, a0), a0
4841baa4: 70                    mov     (a0), d0
4841baa5: df a0 1c              ret     [d2,a2], 0x1c
4841baa8: 5e 2c                 mov     (0x2c, sp), a2
4841baaa: 4b 10                 mov     a2, (0x10, sp)
4841baac: dd bd da 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841bab3: 4b 10                 mov     a2, (0x10, sp)
4841bab5: 88                    mov     d2, d0
4841bab6: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841babc: dd d1 d8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bac3: a0 00                 cmp     0, d0
4841bac5: c8 28                 beq     0x4841baed
4841bac7: 4b 10                 mov     a2, (0x10, sp)
4841bac9: 88                    mov     d2, d0
4841baca: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841bad0: dd bd d8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bad7: a0 00                 cmp     0, d0
4841bad9: c8 14                 beq     0x4841baed
4841badb: 80 01                 mov     1, d0
4841badd: 42 10                 mov     d0, (0x10, sp)
4841badf: fc cd 3b 00 06 00     mov     0x0006003b, d1
4841bae5: 88                    mov     d2, d0
4841bae6: dd a7 d8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841baed: 00                    clr     d0
4841baee: ca 54                 bra     0x4841bb42
4841baf0: 5e 2c                 mov     (0x2c, sp), a2
4841baf2: 4b 10                 mov     a2, (0x10, sp)
4841baf4: dd 75 da 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841bafb: 4b 10                 mov     a2, (0x10, sp)
4841bafd: 88                    mov     d2, d0
4841bafe: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841bb04: dd 89 d8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bb0b: a0 00                 cmp     0, d0
4841bb0d: c8 27                 beq     0x4841bb34
4841bb0f: 4b 10                 mov     a2, (0x10, sp)
4841bb11: 88                    mov     d2, d0
4841bb12: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841bb18: dd 75 d8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bb1f: a0 00                 cmp     0, d0
4841bb21: c8 13                 beq     0x4841bb34
4841bb23: 00                    clr     d0
4841bb24: 42 10                 mov     d0, (0x10, sp)
4841bb26: fc cd 3b 00 06 00     mov     0x0006003b, d1
4841bb2c: 88                    mov     d2, d0
4841bb2d: dd 60 d8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bb34: 00                    clr     d0
4841bb35: ca 0d                 bra     0x4841bb42
4841bb37: 5c 2c                 mov     (0x2c, sp), a0
4841bb39: 43 10                 mov     a0, (0x10, sp)
4841bb3b: dd 2e da 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841bb42: df a0 1c              ret     [d2,a2], 0x1c

AcNumEditBoxProc:
4841bb45: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841bb47: f8 fe d0              add     -0x30, sp
4841bb4a: 83                    mov     d0, d3
4841bb4b: fc c9 0f 00 05 00     cmp     0x5000f, d1
4841bb51: c2 05                 bge     0x4841bb56
4841bb53: cc 2c 03              jmp     0x4841be7f
4841bb56: fc c9 b2 00 06 00     cmp     0x600b2, d1
4841bb5c: c3 05                 ble     0x4841bb61
4841bb5e: cc 21 03              jmp     0x4841be7f
4841bb61: fc dd 30 1e 5a 48     mov     0x485a1e30, a1
4841bb67: 80 0f                 mov     0xf, d0
4841bb69: fc ce f2 ff fa ff     mov     0xfffafff2, d2
4841bb6f: e6                    add     d1, d2
4841bb70: f2 08                 and     d2, d0
4841bb72: f8 c0 03              asl     3, d0
4841bb75: 94                    mov     a1, a0
4841bb76: f1 60                 add     d0, a0
4841bb78: 70                    mov     (a0), d0
4841bb79: a8                    cmp     d2, d0
4841bb7a: c8 18                 beq     0x4841bb92
4841bb7c: db                    setlb
4841bb7d: a0 00                 cmp     0, d0
4841bb7f: c9 05                 bne     0x4841bb84
4841bb81: cc fe 02              jmp     0x4841be7f
4841bb84: 20 08                 add     8, a0
4841bb86: fc d8 b0 1e 5a 48     cmp     0x485a1eb0, a0
4841bb8c: c4 03                 bcs     0x4841bb8f
4841bb8e: 94                    mov     a1, a0
4841bb8f: 70                    mov     (a0), d0
4841bb90: a8                    cmp     d2, d0
4841bb91: d9                    lne
4841bb92: f8 20 04              mov     (4, a0), a0
4841bb95: f0 f4                 jmp     (a0)
4841bb97: 5c 50                 mov     (0x50, sp), a0
4841bb99: 8c                    mov     d3, d0
4841bb9a: 43 10                 mov     a0, (0x10, sp)
4841bb9c: dd cd d9 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841bba3: 00                    clr     d0
4841bba4: 42 10                 mov     d0, (0x10, sp)
4841bba6: fc cd b4 00 06 00     mov     0x000600b4, d1
4841bbac: 8c                    mov     d3, d0
4841bbad: dd e0 d7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bbb4: 00                    clr     d0
4841bbb5: df f0 40              ret     [d2,d3,a2,a3], 0x40
4841bbb8: 8c                    mov     d3, d0
4841bbb9: dd 61 1d 01 00 00 00  call    0x4842d91a, 0, 0
4841bbc0: 43 14                 mov     a0, (0x14, sp)
4841bbc2: 3f                    mov     sp, a3
4841bbc3: 23 18                 add     0x18, a3
4841bbc5: 9c                    mov     a3, a0
4841bbc6: 3e                    mov     sp, a2
4841bbc7: 22 24                 add     0x24, a2
4841bbc9: fc dd 9c f1 59 48     mov     0x4859f19c, a1
4841bbcf: dd 82 74 be 03 20 04  call    0x4c003051, [a2], 4
4841bbd6: 4b 08                 mov     a2, (8, sp)
4841bbd8: fc cc a0 f1 59 48     mov     0x4859f1a0, d0
4841bbde: 42 0c                 mov     d0, (0xc, sp)
4841bbe0: 5c 14                 mov     (0x14, sp), a0
4841bbe2: f8 60 3c              movhu   (0x3c, a0), d0
4841bbe5: 18                    exth    d0
4841bbe6: 42 10                 mov     d0, (0x10, sp)
4841bbe8: dd 60 5e be 03 20 20  call    0x4c001a48, [a2], 0x20
4841bbef: 9c                    mov     a3, a0
4841bbf0: 99                    mov     a2, a1
4841bbf1: dd 96 7d be 03 20 04  call    0x4c003987, [a2], 4
4841bbf8: 9c                    mov     a3, a0
4841bbf9: fc dd a4 f1 59 48     mov     0x4859f1a4, a1
4841bbff: dd 88 7d be 03 20 04  call    0x4c003987, [a2], 4
4841bc06: 5c 50                 mov     (0x50, sp), a0
4841bc08: 43 08                 mov     a0, (8, sp)
4841bc0a: 4f 0c                 mov     a3, (0xc, sp)
4841bc0c: 5c 14                 mov     (0x14, sp), a0
4841bc0e: f8 20 38              mov     (0x38, a0), a0
4841bc11: f0 60                 movhu   (a0), d0
4841bc13: 18                    exth    d0
4841bc14: 42 10                 mov     d0, (0x10, sp)
4841bc16: dd 32 5e be 03 20 20  call    0x4c001a48, [a2], 0x20
4841bc1d: 00                    clr     d0
4841bc1e: df f0 40              ret     [d2,d3,a2,a3], 0x40
4841bc21: 8c                    mov     d3, d0
4841bc22: dd f8 1c 01 00 00 00  call    0x4842d91a, 0, 0
4841bc29: f8 20 38              mov     (0x38, a0), a0
4841bc2c: 58 50                 mov     (0x50, sp), d0
4841bc2e: fc cd b4 00 06 00     mov     0x000600b4, d1
4841bc34: f0 70                 movhu   d0, (a0)
4841bc36: 00                    clr     d0
4841bc37: 42 10                 mov     d0, (0x10, sp)
4841bc39: 8c                    mov     d3, d0
4841bc3a: dd 53 d7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bc41: 00                    clr     d0
4841bc42: df f0 40              ret     [d2,d3,a2,a3], 0x40
4841bc45: 8c                    mov     d3, d0
4841bc46: dd d4 1c 01 00 00 00  call    0x4842d91a, 0, 0
4841bc4d: 5f 50                 mov     (0x50, sp), a3
4841bc4f: f1 d2                 mov     a0, d2
4841bc51: bf 00                 cmp     0, a3
4841bc53: c3 5f                 ble     0x4841bcb2
4841bc55: 95 38                 mov     0x38, a1
4841bc57: f1 69                 add     d2, a1
4841bc59: f0 01                 mov     (a1), a0
4841bc5b: 9a 3e                 mov     0x3e, a2
4841bc5d: f1 6a                 add     d2, a2
4841bc5f: f0 62                 movhu   (a2), d0
4841bc61: f0 64                 movhu   (a0), d1
4841bc63: 18                    exth    d0
4841bc64: 19                    exth    d1
4841bc65: f1 de                 mov     a3, d2
4841bc67: f1 04                 sub     d1, d0
4841bc69: 89                    mov     d2, d1
4841bc6a: 19                    exth    d1
4841bc6b: a4                    cmp     d1, d0
4841bc6c: c0 22                 blt     0x4841bc8e
4841bc6e: f0 01                 mov     (a1), a0
4841bc70: f0 09                 mov     (a1), a2
4841bc72: f0 64                 movhu   (a0), d1
4841bc74: 1a                    exth    d2
4841bc75: 19                    exth    d1
4841bc76: 84                    mov     d1, d0
4841bc77: e8                    add     d2, d0
4841bc78: f0 72                 movhu   d0, (a2)
4841bc7a: 00                    clr     d0
4841bc7b: 42 10                 mov     d0, (0x10, sp)
4841bc7d: fc cd b4 00 06 00     mov     0x000600b4, d1
4841bc83: 8c                    mov     d3, d0
4841bc84: dd 09 d7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bc8b: cc 81 00              jmp     0x4841bd0c
4841bc8e: f0 01                 mov     (a1), a0
4841bc90: f0 62                 movhu   (a2), d0
4841bc92: f0 64                 movhu   (a0), d1
4841bc94: 18                    exth    d0
4841bc95: 19                    exth    d1
4841bc96: a1                    cmp     d0, d1
4841bc97: c8 75                 beq     0x4841bd0c
4841bc99: f0 62                 movhu   (a2), d0
4841bc9b: f0 01                 mov     (a1), a0
4841bc9d: fc cd b4 00 06 00     mov     0x000600b4, d1
4841bca3: f0 70                 movhu   d0, (a0)
4841bca5: 00                    clr     d0
4841bca6: 42 10                 mov     d0, (0x10, sp)
4841bca8: 8c                    mov     d3, d0
4841bca9: dd e4 d6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bcb0: ca 5c                 bra     0x4841bd0c
4841bcb2: 95 38                 mov     0x38, a1
4841bcb4: f1 69                 add     d2, a1
4841bcb6: f0 01                 mov     (a1), a0
4841bcb8: 9a 40                 mov     0x40, a2
4841bcba: f1 6a                 add     d2, a2
4841bcbc: f0 66                 movhu   (a2), d1
4841bcbe: f0 60                 movhu   (a0), d0
4841bcc0: 19                    exth    d1
4841bcc1: 18                    exth    d0
4841bcc2: f1 de                 mov     a3, d2
4841bcc4: f1 01                 sub     d0, d1
4841bcc6: 88                    mov     d2, d0
4841bcc7: 18                    exth    d0
4841bcc8: a1                    cmp     d0, d1
4841bcc9: c1 21                 bgt     0x4841bcea
4841bccb: f0 01                 mov     (a1), a0
4841bccd: f0 09                 mov     (a1), a2
4841bccf: f0 64                 movhu   (a0), d1
4841bcd1: 1a                    exth    d2
4841bcd2: 19                    exth    d1
4841bcd3: 84                    mov     d1, d0
4841bcd4: e8                    add     d2, d0
4841bcd5: f0 72                 movhu   d0, (a2)
4841bcd7: 00                    clr     d0
4841bcd8: 42 10                 mov     d0, (0x10, sp)
4841bcda: fc cd b4 00 06 00     mov     0x000600b4, d1
4841bce0: 8c                    mov     d3, d0
4841bce1: dd ac d6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bce8: ca 24                 bra     0x4841bd0c
4841bcea: f0 01                 mov     (a1), a0
4841bcec: f0 62                 movhu   (a2), d0
4841bcee: f0 64                 movhu   (a0), d1
4841bcf0: 18                    exth    d0
4841bcf1: 19                    exth    d1
4841bcf2: a1                    cmp     d0, d1
4841bcf3: c8 19                 beq     0x4841bd0c
4841bcf5: f0 62                 movhu   (a2), d0
4841bcf7: f0 01                 mov     (a1), a0
4841bcf9: fc cd b4 00 06 00     mov     0x000600b4, d1
4841bcff: f0 70                 movhu   d0, (a0)
4841bd01: 00                    clr     d0
4841bd02: 42 10                 mov     d0, (0x10, sp)
4841bd04: 8c                    mov     d3, d0
4841bd05: dd 88 d6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bd0c: 00                    clr     d0
4841bd0d: df f0 40              ret     [d2,d3,a2,a3], 0x40
4841bd10: 8c                    mov     d3, d0
4841bd11: dd 09 1c 01 00 00 00  call    0x4842d91a, 0, 0
4841bd18: f8 20 38              mov     (0x38, a0), a0
4841bd1b: f0 60                 movhu   (a0), d0
4841bd1d: 18                    exth    d0
4841bd1e: df f0 40              ret     [d2,d3,a2,a3], 0x40
4841bd21: 5e 50                 mov     (0x50, sp), a2
4841bd23: 8c                    mov     d3, d0
4841bd24: 4b 10                 mov     a2, (0x10, sp)
4841bd26: dd 43 d8 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841bd2d: 8c                    mov     d3, d0
4841bd2e: dd ec 1b 01 00 00 00  call    0x4842d91a, 0, 0
4841bd35: 93                    mov     a0, a3
4841bd36: 4b 10                 mov     a2, (0x10, sp)
4841bd38: 8c                    mov     d3, d0
4841bd39: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841bd3f: dd 4e d6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bd46: a0 00                 cmp     0, d0
4841bd48: c8 2a                 beq     0x4841bd72
4841bd4a: 4b 10                 mov     a2, (0x10, sp)
4841bd4c: 8c                    mov     d3, d0
4841bd4d: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841bd53: dd 3a d6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bd5a: a0 00                 cmp     0, d0
4841bd5c: c8 16                 beq     0x4841bd72
4841bd5e: f8 63 42              movhu   (0x42, a3), d0
4841bd61: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841bd67: 18                    exth    d0
4841bd68: 42 10                 mov     d0, (0x10, sp)
4841bd6a: 8c                    mov     d3, d0
4841bd6b: dd 22 d6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bd72: 00                    clr     d0
4841bd73: df f0 40              ret     [d2,d3,a2,a3], 0x40
4841bd76: 5e 50                 mov     (0x50, sp), a2
4841bd78: 8c                    mov     d3, d0
4841bd79: 4b 10                 mov     a2, (0x10, sp)
4841bd7b: dd ee d7 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841bd82: 8c                    mov     d3, d0
4841bd83: dd 97 1b 01 00 00 00  call    0x4842d91a, 0, 0
4841bd8a: 93                    mov     a0, a3
4841bd8b: 4b 10                 mov     a2, (0x10, sp)
4841bd8d: 8c                    mov     d3, d0
4841bd8e: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841bd94: dd f9 d5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bd9b: a0 00                 cmp     0, d0
4841bd9d: c8 2a                 beq     0x4841bdc7
4841bd9f: 4b 10                 mov     a2, (0x10, sp)
4841bda1: 8c                    mov     d3, d0
4841bda2: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841bda8: dd e5 d5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bdaf: a0 00                 cmp     0, d0
4841bdb1: c8 16                 beq     0x4841bdc7
4841bdb3: f8 63 44              movhu   (0x44, a3), d0
4841bdb6: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841bdbc: 18                    exth    d0
4841bdbd: 42 10                 mov     d0, (0x10, sp)
4841bdbf: 8c                    mov     d3, d0
4841bdc0: dd cd d5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bdc7: 00                    clr     d0
4841bdc8: df f0 40              ret     [d2,d3,a2,a3], 0x40
4841bdcb: 5e 50                 mov     (0x50, sp), a2
4841bdcd: 8c                    mov     d3, d0
4841bdce: 4b 10                 mov     a2, (0x10, sp)
4841bdd0: dd 99 d7 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841bdd7: 8c                    mov     d3, d0
4841bdd8: dd 42 1b 01 00 00 00  call    0x4842d91a, 0, 0
4841bddf: 93                    mov     a0, a3
4841bde0: 4b 10                 mov     a2, (0x10, sp)
4841bde2: 8c                    mov     d3, d0
4841bde3: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841bde9: dd a4 d5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841bdf0: a0 00                 cmp     0, d0
4841bdf2: c8 30                 beq     0x4841be22
4841bdf4: 4b 10                 mov     a2, (0x10, sp)
4841bdf6: 8c                    mov     d3, d0
4841bdf7: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841bdfd: dd 90 d5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841be04: a0 00                 cmp     0, d0
4841be06: c8 1c                 beq     0x4841be22
4841be08: f8 63 42              movhu   (0x42, a3), d0
4841be0b: 85 ff                 mov     -1, d1
4841be0d: 18                    exth    d0
4841be0e: cb                    nop
4841be0f: cb                    nop
4841be10: f2 44                 mul     d1, d0
4841be12: 42 10                 mov     d0, (0x10, sp)
4841be14: 8c                    mov     d3, d0
4841be15: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841be1b: dd 72 d5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841be22: 00                    clr     d0
4841be23: ca 68                 bra     0x4841be8b
4841be25: 5e 50                 mov     (0x50, sp), a2
4841be27: 8c                    mov     d3, d0
4841be28: 4b 10                 mov     a2, (0x10, sp)
4841be2a: dd 3f d7 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841be31: 8c                    mov     d3, d0
4841be32: dd e8 1a 01 00 00 00  call    0x4842d91a, 0, 0
4841be39: 93                    mov     a0, a3
4841be3a: 4b 10                 mov     a2, (0x10, sp)
4841be3c: 8c                    mov     d3, d0
4841be3d: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841be43: dd 4a d5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841be4a: a0 00                 cmp     0, d0
4841be4c: c8 30                 beq     0x4841be7c
4841be4e: 4b 10                 mov     a2, (0x10, sp)
4841be50: 8c                    mov     d3, d0
4841be51: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841be57: dd 36 d5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841be5e: a0 00                 cmp     0, d0
4841be60: c8 1c                 beq     0x4841be7c
4841be62: f8 67 44              movhu   (0x44, a3), d1
4841be65: 80 ff                 mov     -1, d0
4841be67: 19                    exth    d1
4841be68: cb                    nop
4841be69: cb                    nop
4841be6a: f2 41                 mul     d0, d1
4841be6c: 46 10                 mov     d1, (0x10, sp)
4841be6e: 8c                    mov     d3, d0
4841be6f: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841be75: dd 18 d5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841be7c: 00                    clr     d0
4841be7d: ca 0e                 bra     0x4841be8b
4841be7f: 5c 50                 mov     (0x50, sp), a0
4841be81: 8c                    mov     d3, d0
4841be82: 43 10                 mov     a0, (0x10, sp)
4841be84: dd e5 d6 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841be8b: df f0 40              ret     [d2,d3,a2,a3], 0x40

AcMmmEditBoxProc:
4841be8e: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841be90: f8 fe dc              add     -0x24, sp
4841be93: 83                    mov     d0, d3
4841be94: 86                    mov     d1, d2
4841be95: fc ca 01 00 05 00     cmp     0x50001, d2
4841be9b: c2 05                 bge     0x4841bea0
4841be9d: cc ee 03              jmp     0x4841c28b
4841bea0: fc ca 3d 00 06 00     cmp     0x6003d, d2
4841bea6: c3 05                 ble     0x4841beab
4841bea8: cc e3 03              jmp     0x4841c28b
4841beab: fc dd b0 1e 5a 48     mov     0x485a1eb0, a1
4841beb1: 80 0f                 mov     0xf, d0
4841beb3: fc cd 00 00 fb ff     mov     0xfffb0000, d1
4841beb9: e9                    add     d2, d1
4841beba: f2 04                 and     d1, d0
4841bebc: f8 c0 03              asl     3, d0
4841bebf: f1 e0                 mov     d0, a0
4841bec1: f1 74                 add     a1, a0
4841bec3: 70                    mov     (a0), d0
4841bec4: a4                    cmp     d1, d0
4841bec5: c8 18                 beq     0x4841bedd
4841bec7: db                    setlb
4841bec8: a0 00                 cmp     0, d0
4841beca: c9 05                 bne     0x4841becf
4841becc: cc bf 03              jmp     0x4841c28b
4841becf: 20 08                 add     8, a0
4841bed1: fc d8 30 1f 5a 48     cmp     0x485a1f30, a0
4841bed7: c4 03                 bcs     0x4841beda
4841bed9: 94                    mov     a1, a0
4841beda: 70                    mov     (a0), d0
4841bedb: a4                    cmp     d1, d0
4841bedc: d9                    lne
4841bedd: f8 20 04              mov     (4, a0), a0
4841bee0: f0 f4                 jmp     (a0)
4841bee2: 8c                    mov     d3, d0
4841bee3: dd 37 1a 01 00 00 00  call    0x4842d91a, 0, 0
4841beea: f8 00 38              mov     (0x38, a0), d0
4841beed: 04                    clr     d1
4841beee: 46 10                 mov     d1, (0x10, sp)
4841bef0: fc cd bc 00 06 00     mov     0x000600bc, d1
4841bef6: dd 8a ed 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841befd: cd 12 05 80 18        call    0x4841c40f, [d2], 0x18
4841bf02: 5c 44                 mov     (0x44, sp), a0
4841bf04: 89                    mov     d2, d1
4841bf05: 43 10                 mov     a0, (0x10, sp)
4841bf07: 8c                    mov     d3, d0
4841bf08: dd 61 d6 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841bf0f: 00                    clr     d0
4841bf10: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841bf13: 8c                    mov     d3, d0
4841bf14: dd 06 1a 01 00 00 00  call    0x4842d91a, 0, 0
4841bf1b: f8 24 3c              mov     (0x3c, a0), a1
4841bf1e: fc cd bb 00 06 00     mov     0x000600bb, d1
4841bf24: f0 61                 movhu   (a1), d0
4841bf26: f8 93 1c              movhu   d0, (0x1c, sp)
4841bf29: 5e 44                 mov     (0x44, sp), a2
4841bf2b: 4b 20                 mov     a2, (0x20, sp)
4841bf2d: f8 00 38              mov     (0x38, a0), d0
4841bf30: 3c                    mov     sp, a0
4841bf31: 20 14                 add     0x14, a0
4841bf33: 43 10                 mov     a0, (0x10, sp)
4841bf35: dd 4b ed 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841bf3c: 00                    clr     d0
4841bf3d: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841bf40: 8c                    mov     d3, d0
4841bf41: dd d9 19 01 00 00 00  call    0x4842d91a, 0, 0
4841bf48: 92                    mov     a0, a2
4841bf49: 22 38                 add     0x38, a2
4841bf4b: 72                    mov     (a2), d0
4841bf4c: 04                    clr     d1
4841bf4d: 46 10                 mov     d1, (0x10, sp)
4841bf4f: fc cd bc 00 06 00     mov     0x000600bc, d1
4841bf55: dd 2b ed 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841bf5c: 82                    mov     d0, d2
4841bf5d: 72                    mov     (a2), d0
4841bf5e: 04                    clr     d1
4841bf5f: 46 10                 mov     d1, (0x10, sp)
4841bf61: fc cd bd 00 06 00     mov     0x000600bd, d1
4841bf67: dd 19 ed 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841bf6e: 81                    mov     d0, d1
4841bf6f: 5c 44                 mov     (0x44, sp), a0
4841bf71: fc e1 00 00 00 ff     and     0xff000000, d1
4841bf77: f1 51                 add     a0, d1
4841bf79: 88                    mov     d2, d0
4841bf7a: cd 02 04 e0 20        call    0x4841c37c, [d2,d3,a2], 0x20
4841bf7f: 00                    clr     d0
4841bf80: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841bf83: 8c                    mov     d3, d0
4841bf84: dd 96 19 01 00 00 00  call    0x4842d91a, 0, 0
4841bf8b: 92                    mov     a0, a2
4841bf8c: 22 38                 add     0x38, a2
4841bf8e: 72                    mov     (a2), d0
4841bf8f: 04                    clr     d1
4841bf90: 46 10                 mov     d1, (0x10, sp)
4841bf92: fc cd bc 00 06 00     mov     0x000600bc, d1
4841bf98: dd e8 ec 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841bf9f: 04                    clr     d1
4841bfa0: 83                    mov     d0, d3
4841bfa1: 72                    mov     (a2), d0
4841bfa2: 46 10                 mov     d1, (0x10, sp)
4841bfa4: fc cd bd 00 06 00     mov     0x000600bd, d1
4841bfaa: dd d6 ec 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841bfb1: 5a 44                 mov     (0x44, sp), d2
4841bfb3: 81                    mov     d0, d1
4841bfb4: 1a                    exth    d2
4841bfb5: 4a 10                 mov     d2, (0x10, sp)
4841bfb7: 8c                    mov     d3, d0
4841bfb8: cd 0c 04 e0 20        call    0x4841c3c4, [d2,d3,a2], 0x20
4841bfbd: 00                    clr     d0
4841bfbe: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841bfc1: 5c 44                 mov     (0x44, sp), a0
4841bfc3: 8c                    mov     d3, d0
4841bfc4: 43 10                 mov     a0, (0x10, sp)
4841bfc6: 89                    mov     d2, d1
4841bfc7: dd a2 d5 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841bfce: 8c                    mov     d3, d0
4841bfcf: dd 4b 19 01 00 00 00  call    0x4842d91a, 0, 0
4841bfd6: 92                    mov     a0, a2
4841bfd7: 22 38                 add     0x38, a2
4841bfd9: 72                    mov     (a2), d0
4841bfda: 04                    clr     d1
4841bfdb: 46 10                 mov     d1, (0x10, sp)
4841bfdd: fc cd bc 00 06 00     mov     0x000600bc, d1
4841bfe3: dd 9d ec 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841bfea: 82                    mov     d0, d2
4841bfeb: 72                    mov     (a2), d0
4841bfec: 04                    clr     d1
4841bfed: 46 10                 mov     d1, (0x10, sp)
4841bfef: fc cd bd 00 06 00     mov     0x000600bd, d1
4841bff5: dd 8b ec 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841bffc: 81                    mov     d0, d1
4841bffd: 88                    mov     d2, d0
4841bffe: cd 36 03 e0 20        call    0x4841c334, [d2,d3,a2], 0x20
4841c003: 00                    clr     d0
4841c004: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841c007: 5f 44                 mov     (0x44, sp), a3
4841c009: 8c                    mov     d3, d0
4841c00a: 4f 10                 mov     a3, (0x10, sp)
4841c00c: 89                    mov     d2, d1
4841c00d: dd 5c d5 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c014: 8c                    mov     d3, d0
4841c015: dd 05 19 01 00 00 00  call    0x4842d91a, 0, 0
4841c01c: f1 d2                 mov     a0, d2
4841c01e: 9a 38                 mov     0x38, a2
4841c020: f1 6a                 add     d2, a2
4841c022: 72                    mov     (a2), d0
4841c023: 4f 10                 mov     a3, (0x10, sp)
4841c025: fc cd ba 00 06 00     mov     0x000600ba, d1
4841c02b: dd 55 ec 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c032: a0 00                 cmp     0, d0
4841c034: c8 3a                 beq     0x4841c06e
4841c036: 72                    mov     (a2), d0
4841c037: 4f 10                 mov     a3, (0x10, sp)
4841c039: fc cd b9 00 06 00     mov     0x000600b9, d1
4841c03f: dd 41 ec 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c046: 72                    mov     (a2), d0
4841c047: 4f 10                 mov     a3, (0x10, sp)
4841c049: fc cd be 00 06 00     mov     0x000600be, d1
4841c04f: dd 31 ec 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c056: f1 e8                 mov     d2, a0
4841c058: f8 20 3c              mov     (0x3c, a0), a0
4841c05b: fc cd b4 00 06 00     mov     0x000600b4, d1
4841c061: f0 70                 movhu   d0, (a0)
4841c063: 00                    clr     d0
4841c064: 42 10                 mov     d0, (0x10, sp)
4841c066: 8c                    mov     d3, d0
4841c067: dd 26 d3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c06e: 00                    clr     d0
4841c06f: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841c072: 5e 44                 mov     (0x44, sp), a2
4841c074: 8c                    mov     d3, d0
4841c075: 4b 10                 mov     a2, (0x10, sp)
4841c077: 89                    mov     d2, d1
4841c078: dd f1 d4 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c07f: 8c                    mov     d3, d0
4841c080: dd 9a 18 01 00 00 00  call    0x4842d91a, 0, 0
4841c087: 93                    mov     a0, a3
4841c088: 4b 10                 mov     a2, (0x10, sp)
4841c08a: 8c                    mov     d3, d0
4841c08b: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841c091: dd fc d2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c098: a0 00                 cmp     0, d0
4841c09a: c8 39                 beq     0x4841c0d3
4841c09c: 4b 10                 mov     a2, (0x10, sp)
4841c09e: 8c                    mov     d3, d0
4841c09f: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841c0a5: dd e8 d2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c0ac: a0 00                 cmp     0, d0
4841c0ae: c8 25                 beq     0x4841c0d3
4841c0b0: f8 03 38              mov     (0x38, a3), d0
4841c0b3: 04                    clr     d1
4841c0b4: 46 10                 mov     d1, (0x10, sp)
4841c0b6: fc cd 3e 00 06 00     mov     0x0006003e, d1
4841c0bc: dd c4 eb 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c0c3: 42 10                 mov     d0, (0x10, sp)
4841c0c5: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841c0cb: 8c                    mov     d3, d0
4841c0cc: dd c1 d2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c0d3: 00                    clr     d0
4841c0d4: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841c0d7: 5e 44                 mov     (0x44, sp), a2
4841c0d9: 8c                    mov     d3, d0
4841c0da: 4b 10                 mov     a2, (0x10, sp)
4841c0dc: 89                    mov     d2, d1
4841c0dd: dd 8c d4 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c0e4: 8c                    mov     d3, d0
4841c0e5: dd 35 18 01 00 00 00  call    0x4842d91a, 0, 0
4841c0ec: 93                    mov     a0, a3
4841c0ed: 4b 10                 mov     a2, (0x10, sp)
4841c0ef: 8c                    mov     d3, d0
4841c0f0: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841c0f6: dd 97 d2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c0fd: a0 00                 cmp     0, d0
4841c0ff: c8 39                 beq     0x4841c138
4841c101: 4b 10                 mov     a2, (0x10, sp)
4841c103: 8c                    mov     d3, d0
4841c104: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841c10a: dd 83 d2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c111: a0 00                 cmp     0, d0
4841c113: c8 25                 beq     0x4841c138
4841c115: f8 03 38              mov     (0x38, a3), d0
4841c118: 04                    clr     d1
4841c119: 46 10                 mov     d1, (0x10, sp)
4841c11b: fc cd 3f 00 06 00     mov     0x0006003f, d1
4841c121: dd 5f eb 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c128: 42 10                 mov     d0, (0x10, sp)
4841c12a: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841c130: 8c                    mov     d3, d0
4841c131: dd 5c d2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c138: 00                    clr     d0
4841c139: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841c13c: 5e 44                 mov     (0x44, sp), a2
4841c13e: 8c                    mov     d3, d0
4841c13f: 4b 10                 mov     a2, (0x10, sp)
4841c141: 89                    mov     d2, d1
4841c142: dd 27 d4 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c149: 8c                    mov     d3, d0
4841c14a: dd d0 17 01 00 00 00  call    0x4842d91a, 0, 0
4841c151: 93                    mov     a0, a3
4841c152: 4b 10                 mov     a2, (0x10, sp)
4841c154: 8c                    mov     d3, d0
4841c155: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841c15b: dd 32 d2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c162: a0 00                 cmp     0, d0
4841c164: c8 3f                 beq     0x4841c1a3
4841c166: 4b 10                 mov     a2, (0x10, sp)
4841c168: 8c                    mov     d3, d0
4841c169: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841c16f: dd 1e d2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c176: a0 00                 cmp     0, d0
4841c178: c8 2b                 beq     0x4841c1a3
4841c17a: f8 03 38              mov     (0x38, a3), d0
4841c17d: 04                    clr     d1
4841c17e: 46 10                 mov     d1, (0x10, sp)
4841c180: fc cd 3e 00 06 00     mov     0x0006003e, d1
4841c186: dd fa ea 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c18d: 85 ff                 mov     -1, d1
4841c18f: cb                    nop
4841c190: cb                    nop
4841c191: f2 54                 mulu    d1, d0
4841c193: 42 10                 mov     d0, (0x10, sp)
4841c195: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841c19b: 8c                    mov     d3, d0
4841c19c: dd f1 d1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c1a3: 00                    clr     d0
4841c1a4: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841c1a7: 5e 44                 mov     (0x44, sp), a2
4841c1a9: 8c                    mov     d3, d0
4841c1aa: 4b 10                 mov     a2, (0x10, sp)
4841c1ac: 89                    mov     d2, d1
4841c1ad: dd bc d3 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c1b4: 8c                    mov     d3, d0
4841c1b5: dd 65 17 01 00 00 00  call    0x4842d91a, 0, 0
4841c1bc: 93                    mov     a0, a3
4841c1bd: 4b 10                 mov     a2, (0x10, sp)
4841c1bf: 8c                    mov     d3, d0
4841c1c0: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841c1c6: dd c7 d1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c1cd: a0 00                 cmp     0, d0
4841c1cf: c8 3f                 beq     0x4841c20e
4841c1d1: 4b 10                 mov     a2, (0x10, sp)
4841c1d3: 8c                    mov     d3, d0
4841c1d4: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841c1da: dd b3 d1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c1e1: a0 00                 cmp     0, d0
4841c1e3: c8 2b                 beq     0x4841c20e
4841c1e5: f8 03 38              mov     (0x38, a3), d0
4841c1e8: 04                    clr     d1
4841c1e9: 46 10                 mov     d1, (0x10, sp)
4841c1eb: fc cd 3f 00 06 00     mov     0x0006003f, d1
4841c1f1: dd 8f ea 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c1f8: 85 ff                 mov     -1, d1
4841c1fa: cb                    nop
4841c1fb: cb                    nop
4841c1fc: f2 54                 mulu    d1, d0
4841c1fe: 42 10                 mov     d0, (0x10, sp)
4841c200: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841c206: 8c                    mov     d3, d0
4841c207: dd 86 d1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c20e: 00                    clr     d0
4841c20f: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841c212: 5e 44                 mov     (0x44, sp), a2
4841c214: 8c                    mov     d3, d0
4841c215: 4b 10                 mov     a2, (0x10, sp)
4841c217: 89                    mov     d2, d1
4841c218: dd 51 d3 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c21f: 4b 10                 mov     a2, (0x10, sp)
4841c221: 8c                    mov     d3, d0
4841c222: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841c228: dd 65 d1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c22f: a0 00                 cmp     0, d0
4841c231: c8 57                 beq     0x4841c288
4841c233: 4b 10                 mov     a2, (0x10, sp)
4841c235: 8c                    mov     d3, d0
4841c236: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841c23c: dd 51 d1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c243: a0 00                 cmp     0, d0
4841c245: c8 43                 beq     0x4841c288
4841c247: 8c                    mov     d3, d0
4841c248: dd d2 16 01 00 00 00  call    0x4842d91a, 0, 0
4841c24f: 92                    mov     a0, a2
4841c250: 22 38                 add     0x38, a2
4841c252: 72                    mov     (a2), d0
4841c253: 04                    clr     d1
4841c254: 46 10                 mov     d1, (0x10, sp)
4841c256: fc cd a9 00 06 00     mov     0x000600a9, d1
4841c25c: dd 24 ea 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c263: a0 00                 cmp     0, d0
4841c265: c8 23                 beq     0x4841c288
4841c267: 72                    mov     (a2), d0
4841c268: 04                    clr     d1
4841c269: 46 10                 mov     d1, (0x10, sp)
4841c26b: fc cd aa 00 06 00     mov     0x000600aa, d1
4841c271: dd 0f ea 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c278: 42 10                 mov     d0, (0x10, sp)
4841c27a: fc cd 3b 00 06 00     mov     0x0006003b, d1
4841c280: 8c                    mov     d3, d0
4841c281: dd 0c d1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c288: 00                    clr     d0
4841c289: ca 0f                 bra     0x4841c298
4841c28b: 5c 44                 mov     (0x44, sp), a0
4841c28d: 89                    mov     d2, d1

MainGetM3Em:
4841c32f: cf e0                 movm    [d2,d3,a2], (sp)
4841c331: f8 fe ec              add     -0x14, sp
4841c334: 87                    mov     d1, d3
4841c335: 82                    mov     d0, d2
4841c336: 80 10                 mov     0x10, d0
4841c338: cd f2 a2 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841c33d: 92                    mov     a0, a2
4841c33e: 6a                    mov     d2, (a2)
4841c33f: f8 1e 04              mov     d3, (4, a2)
4841c342: 00                    clr     d0
4841c343: f8 72 08              movhu   d0, (8, a2)
4841c346: f8 12 0c              mov     d0, (0xc, a2)
4841c349: 43 10                 mov     a0, (0x10, sp)
4841c34b: fc cc 02 00 03 00     mov     0x00030002, d0
4841c351: fc cd bf 00 06 00     mov     0x000600bf, d1
4841c357: dd ee e9 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c35e: 4b 10                 mov     a2, (0x10, sp)
4841c360: fc cc 03 00 03 00     mov     0x00030003, d0
4841c366: fc cd 23 00 06 00     mov     0x00060023, d1
4841c36c: dd d9 e9 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c373: 00                    clr     d0
4841c374: df e0 20              ret     [d2,d3,a2], 0x20

MainPutM3Em:
4841c377: cf e0                 movm    [d2,d3,a2], (sp)
4841c379: f8 fe ec              add     -0x14, sp
4841c37c: 87                    mov     d1, d3
4841c37d: 82                    mov     d0, d2
4841c37e: 80 10                 mov     0x10, d0
4841c380: cd aa a2 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841c385: 92                    mov     a0, a2
4841c386: 6a                    mov     d2, (a2)
4841c387: f8 1e 04              mov     d3, (4, a2)
4841c38a: 00                    clr     d0
4841c38b: f8 72 08              movhu   d0, (8, a2)
4841c38e: f8 12 0c              mov     d0, (0xc, a2)
4841c391: 43 10                 mov     a0, (0x10, sp)
4841c393: fc cc 02 00 03 00     mov     0x00030002, d0
4841c399: fc cd c0 00 06 00     mov     0x000600c0, d1
4841c39f: dd a6 e9 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c3a6: 4b 10                 mov     a2, (0x10, sp)
4841c3a8: fc cc 03 00 03 00     mov     0x00030003, d0
4841c3ae: fc cd 23 00 06 00     mov     0x00060023, d1
4841c3b4: dd 91 e9 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c3bb: 00                    clr     d0
4841c3bc: df e0 20              ret     [d2,d3,a2], 0x20

MainAddM3Em:
4841c3bf: cf e0                 movm    [d2,d3,a2], (sp)
4841c3c1: f8 fe ec              add     -0x14, sp
4841c3c4: 87                    mov     d1, d3
4841c3c5: 82                    mov     d0, d2
4841c3c6: 80 10                 mov     0x10, d0
4841c3c8: cd 62 a2 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841c3cd: 92                    mov     a0, a2
4841c3ce: 6a                    mov     d2, (a2)
4841c3cf: f8 1e 04              mov     d3, (4, a2)
4841c3d2: f8 bc 30              movhu   (0x30, sp), d0
4841c3d5: fc cd c1 00 06 00     mov     0x000600c1, d1
4841c3db: f8 72 08              movhu   d0, (8, a2)
4841c3de: 00                    clr     d0
4841c3df: f8 12 0c              mov     d0, (0xc, a2)
4841c3e2: 43 10                 mov     a0, (0x10, sp)
4841c3e4: fc cc 02 00 03 00     mov     0x00030002, d0
4841c3ea: dd 5b e9 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c3f1: 4b 10                 mov     a2, (0x10, sp)
4841c3f3: fc cc 03 00 03 00     mov     0x00030003, d0
4841c3f9: fc cd 23 00 06 00     mov     0x00060023, d1
4841c3ff: dd 46 e9 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c406: 00                    clr     d0
4841c407: df e0 20              ret     [d2,d3,a2], 0x20

SetMmmFilter:
4841c40a: cf 80                 movm    [d2], (sp)
4841c40c: f8 fe ec              add     -0x14, sp
4841c40f: 82                    mov     d0, d2
4841c410: 4a 10                 mov     d2, (0x10, sp)
4841c412: 80 ff                 mov     -1, d0
4841c414: fc cd d0 00 06 00     mov     0x000600d0, d1
4841c41a: dd 3c d4 00 00 80 1c  call    0x48429856, [d2], 0x1c
4841c421: dd 64 05 01 00 00 10  call    0x4842c985, 0, 0x10
4841c428: 4a 10                 mov     d2, (0x10, sp)
4841c42a: fc cd d0 00 06 00     mov     0x000600d0, d1
4841c430: dd dd d3 00 00 80 1c  call    0x4842980d, [d2], 0x1c
4841c437: df 80 18              ret     [d2], 0x18

AcRamEditBoxProc:
4841c43a: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841c43c: f8 fe d4              add     -0x2c, sp
4841c43f: 42 44                 mov     d0, (0x44, sp)
4841c441: 87                    mov     d1, d3
4841c442: fc cb 09 00 05 00     cmp     0x50009, d3
4841c448: c2 05                 bge     0x4841c44d
4841c44a: cc a7 03              jmp     0x4841c7f1
4841c44d: fc cb 3d 00 06 00     cmp     0x6003d, d3
4841c453: c3 05                 ble     0x4841c458
4841c455: cc 9c 03              jmp     0x4841c7f1
4841c458: 85 0f                 mov     0xf, d1
4841c45a: fc ce f8 ff fa ff     mov     0xfffafff8, d2
4841c460: ee                    add     d3, d2
4841c461: f2 09                 and     d2, d1
4841c463: f8 c1 03              asl     3, d1
4841c466: f1 e4                 mov     d1, a0
4841c468: fc d0 30 1f 5a 48     add     0x485a1f30, a0
4841c46e: 70                    mov     (a0), d0
4841c46f: a8                    cmp     d2, d0
4841c470: c8 05                 beq     0x4841c475
4841c472: cc 7f 03              jmp     0x4841c7f1
4841c475: f8 20 04              mov     (4, a0), a0
4841c478: f0 f4                 jmp     (a0)
4841c47a: 58 44                 mov     (0x44, sp), d0
4841c47c: dd 9e 14 01 00 00 00  call    0x4842d91a, 0, 0
4841c483: 92                    mov     a0, a2
4841c484: 9f 38                 mov     0x38, a3
4841c486: f1 7b                 add     a2, a3
4841c488: 73                    mov     (a3), d0
4841c489: 04                    clr     d1
4841c48a: 46 10                 mov     d1, (0x10, sp)
4841c48c: fc cd 42 00 06 00     mov     0x00060042, d1
4841c492: dd ee e7 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c499: 42 14                 mov     d0, (0x14, sp)
4841c49b: f8 22 3c              mov     (0x3c, a2), a0
4841c49e: fc cd 44 00 06 00     mov     0x00060044, d1
4841c4a4: 70                    mov     (a0), d0
4841c4a5: 3c                    mov     sp, a0
4841c4a6: 42 24                 mov     d0, (0x24, sp)
4841c4a8: 5d 4c                 mov     (0x4c, sp), a1
4841c4aa: f1 d2                 mov     a0, d2
4841c4ac: 47 28                 mov     a1, (0x28, sp)
4841c4ae: 73                    mov     (a3), d0
4841c4af: 2a 14                 add     0x14, d2
4841c4b1: 4a 10                 mov     d2, (0x10, sp)
4841c4b3: dd cd e7 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c4ba: 00                    clr     d0
4841c4bb: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841c4be: 58 44                 mov     (0x44, sp), d0
4841c4c0: dd 5a 14 01 00 00 00  call    0x4842d91a, 0, 0
4841c4c7: 92                    mov     a0, a2
4841c4c8: 22 38                 add     0x38, a2
4841c4ca: 72                    mov     (a2), d0
4841c4cb: 04                    clr     d1
4841c4cc: 46 10                 mov     d1, (0x10, sp)
4841c4ce: fc cd 42 00 06 00     mov     0x00060042, d1
4841c4d4: dd ac e7 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c4db: 42 14                 mov     d0, (0x14, sp)
4841c4dd: 72                    mov     (a2), d0
4841c4de: 04                    clr     d1
4841c4df: 46 10                 mov     d1, (0x10, sp)
4841c4e1: fc cd 43 00 06 00     mov     0x00060043, d1
4841c4e7: dd 99 e7 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c4ee: f8 93 18              movhu   d0, (0x18, sp)
4841c4f1: 5d 4c                 mov     (0x4c, sp), a1
4841c4f3: 3f                    mov     sp, a3
4841c4f4: 23 14                 add     0x14, a3
4841c4f6: 47 24                 mov     a1, (0x24, sp)
4841c4f8: 72                    mov     (a2), d0
4841c4f9: 04                    clr     d1
4841c4fa: 46 10                 mov     d1, (0x10, sp)
4841c4fc: fc cd 40 00 06 00     mov     0x00060040, d1
4841c502: dd 7e e7 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c509: 42 1c                 mov     d0, (0x1c, sp)
4841c50b: 72                    mov     (a2), d0
4841c50c: 04                    clr     d1
4841c50d: 46 10                 mov     d1, (0x10, sp)
4841c50f: fc cd 41 00 06 00     mov     0x00060041, d1
4841c515: dd 6b e7 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c51c: 42 20                 mov     d0, (0x20, sp)
4841c51e: 9c                    mov     a3, a0
4841c51f: cd 71 03 20 18        call    0x4841c890, [a2], 0x18
4841c524: 00                    clr     d0
4841c525: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841c528: 58 44                 mov     (0x44, sp), d0
4841c52a: dd f0 13 01 00 00 00  call    0x4842d91a, 0, 0
4841c531: 92                    mov     a0, a2
4841c532: 22 38                 add     0x38, a2
4841c534: 72                    mov     (a2), d0
4841c535: 04                    clr     d1
4841c536: 46 10                 mov     d1, (0x10, sp)
4841c538: fc cd 42 00 06 00     mov     0x00060042, d1
4841c53e: dd 42 e7 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c545: 42 14                 mov     d0, (0x14, sp)
4841c547: 72                    mov     (a2), d0
4841c548: 04                    clr     d1
4841c549: 46 10                 mov     d1, (0x10, sp)
4841c54b: fc cd 43 00 06 00     mov     0x00060043, d1
4841c551: dd 2f e7 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c558: f8 93 18              movhu   d0, (0x18, sp)
4841c55b: 5d 4c                 mov     (0x4c, sp), a1
4841c55d: 3f                    mov     sp, a3
4841c55e: 23 14                 add     0x14, a3
4841c560: 47 24                 mov     a1, (0x24, sp)
4841c562: 72                    mov     (a2), d0
4841c563: 04                    clr     d1
4841c564: 46 10                 mov     d1, (0x10, sp)
4841c566: fc cd 40 00 06 00     mov     0x00060040, d1
4841c56c: dd 14 e7 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c573: 42 1c                 mov     d0, (0x1c, sp)
4841c575: 72                    mov     (a2), d0
4841c576: 04                    clr     d1
4841c577: 46 10                 mov     d1, (0x10, sp)
4841c579: fc cd 41 00 06 00     mov     0x00060041, d1
4841c57f: dd 01 e7 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c586: 42 20                 mov     d0, (0x20, sp)
4841c588: 9c                    mov     a3, a0
4841c589: cd 4c 03 20 18        call    0x4841c8d5, [a2], 0x18
4841c58e: 00                    clr     d0
4841c58f: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841c592: 5c 4c                 mov     (0x4c, sp), a0
4841c594: 8d                    mov     d3, d1
4841c595: 43 10                 mov     a0, (0x10, sp)
4841c597: 58 44                 mov     (0x44, sp), d0
4841c599: dd d0 cf 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c5a0: 58 44                 mov     (0x44, sp), d0
4841c5a2: dd 78 13 01 00 00 00  call    0x4842d91a, 0, 0
4841c5a9: 92                    mov     a0, a2
4841c5aa: 22 38                 add     0x38, a2
4841c5ac: 72                    mov     (a2), d0
4841c5ad: 04                    clr     d1
4841c5ae: 46 10                 mov     d1, (0x10, sp)
4841c5b0: fc cd 42 00 06 00     mov     0x00060042, d1
4841c5b6: dd ca e6 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c5bd: f1 e3                 mov     d0, a3
4841c5bf: 72                    mov     (a2), d0
4841c5c0: 04                    clr     d1
4841c5c1: 46 10                 mov     d1, (0x10, sp)
4841c5c3: fc cd 43 00 06 00     mov     0x00060043, d1
4841c5c9: dd b7 e6 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c5d0: 1c                    exthu   d0
4841c5d1: 9c                    mov     a3, a0
4841c5d2: cd 48 03 a0 1c        call    0x4841c91a, [d2,a2], 0x1c
4841c5d7: 00                    clr     d0
4841c5d8: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841c5db: 5e 4c                 mov     (0x4c, sp), a2
4841c5dd: 8d                    mov     d3, d1
4841c5de: 4b 10                 mov     a2, (0x10, sp)
4841c5e0: 58 44                 mov     (0x44, sp), d0
4841c5e2: dd 87 cf 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c5e9: 58 44                 mov     (0x44, sp), d0
4841c5eb: dd 2f 13 01 00 00 00  call    0x4842d91a, 0, 0
4841c5f2: 93                    mov     a0, a3
4841c5f3: 8a 38                 mov     0x38, d2
4841c5f5: f1 5e                 add     a3, d2
4841c5f7: f1 e8                 mov     d2, a0
4841c5f9: 70                    mov     (a0), d0
4841c5fa: 04                    clr     d1
4841c5fb: 46 10                 mov     d1, (0x10, sp)
4841c5fd: fc cd 42 00 06 00     mov     0x00060042, d1
4841c603: dd 7d e6 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c60a: 76                    mov     (a2), d1
4841c60b: a4                    cmp     d1, d0
4841c60c: c9 2e                 bne     0x4841c63a
4841c60e: f8 22 10              mov     (0x10, a2), a0
4841c611: f8 27 3c              mov     (0x3c, a3), a1
4841c614: fc cd 78 00 06 00     mov     0x00060078, d1
4841c61a: f0 11                 mov     a0, (a1)
4841c61c: f1 e9                 mov     d2, a1
4841c61e: 71                    mov     (a1), d0
4841c61f: 43 10                 mov     a0, (0x10, sp)
4841c621: dd 5f e6 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c628: 00                    clr     d0
4841c629: 42 10                 mov     d0, (0x10, sp)
4841c62b: 58 44                 mov     (0x44, sp), d0
4841c62d: fc cd b4 00 06 00     mov     0x000600b4, d1
4841c633: dd 5a cd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c63a: 00                    clr     d0
4841c63b: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841c63e: 5e 4c                 mov     (0x4c, sp), a2
4841c640: 8d                    mov     d3, d1
4841c641: 4b 10                 mov     a2, (0x10, sp)
4841c643: 58 44                 mov     (0x44, sp), d0
4841c645: dd 24 cf 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c64c: 58 44                 mov     (0x44, sp), d0
4841c64e: dd cc 12 01 00 00 00  call    0x4842d91a, 0, 0
4841c655: 93                    mov     a0, a3
4841c656: 4b 10                 mov     a2, (0x10, sp)
4841c658: 58 44                 mov     (0x44, sp), d0
4841c65a: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841c660: dd 2d cd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c667: a0 00                 cmp     0, d0
4841c669: c8 3b                 beq     0x4841c6a4
4841c66b: 4b 10                 mov     a2, (0x10, sp)
4841c66d: 58 44                 mov     (0x44, sp), d0
4841c66f: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841c675: dd 18 cd 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c67c: a0 00                 cmp     0, d0
4841c67e: c8 26                 beq     0x4841c6a4
4841c680: f8 03 38              mov     (0x38, a3), d0
4841c683: 04                    clr     d1
4841c684: 46 10                 mov     d1, (0x10, sp)
4841c686: fc cd 3e 00 06 00     mov     0x0006003e, d1
4841c68c: dd f4 e5 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c693: 42 10                 mov     d0, (0x10, sp)
4841c695: 58 44                 mov     (0x44, sp), d0
4841c697: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841c69d: dd f0 cc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c6a4: 00                    clr     d0
4841c6a5: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841c6a8: 5e 4c                 mov     (0x4c, sp), a2
4841c6aa: 8d                    mov     d3, d1
4841c6ab: 4b 10                 mov     a2, (0x10, sp)
4841c6ad: 58 44                 mov     (0x44, sp), d0
4841c6af: dd ba ce 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c6b6: 58 44                 mov     (0x44, sp), d0
4841c6b8: dd 62 12 01 00 00 00  call    0x4842d91a, 0, 0
4841c6bf: 93                    mov     a0, a3
4841c6c0: 4b 10                 mov     a2, (0x10, sp)
4841c6c2: 58 44                 mov     (0x44, sp), d0
4841c6c4: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841c6ca: dd c3 cc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c6d1: a0 00                 cmp     0, d0
4841c6d3: c8 3b                 beq     0x4841c70e
4841c6d5: 4b 10                 mov     a2, (0x10, sp)
4841c6d7: 58 44                 mov     (0x44, sp), d0
4841c6d9: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841c6df: dd ae cc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c6e6: a0 00                 cmp     0, d0
4841c6e8: c8 26                 beq     0x4841c70e
4841c6ea: f8 03 38              mov     (0x38, a3), d0
4841c6ed: 04                    clr     d1
4841c6ee: 46 10                 mov     d1, (0x10, sp)
4841c6f0: fc cd 3f 00 06 00     mov     0x0006003f, d1
4841c6f6: dd 8a e5 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c6fd: 42 10                 mov     d0, (0x10, sp)
4841c6ff: 58 44                 mov     (0x44, sp), d0
4841c701: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841c707: dd 86 cc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c70e: 00                    clr     d0
4841c70f: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841c712: 5e 4c                 mov     (0x4c, sp), a2
4841c714: 8d                    mov     d3, d1
4841c715: 4b 10                 mov     a2, (0x10, sp)
4841c717: 58 44                 mov     (0x44, sp), d0
4841c719: dd 50 ce 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c720: 58 44                 mov     (0x44, sp), d0
4841c722: dd f8 11 01 00 00 00  call    0x4842d91a, 0, 0
4841c729: 93                    mov     a0, a3
4841c72a: 4b 10                 mov     a2, (0x10, sp)
4841c72c: 58 44                 mov     (0x44, sp), d0
4841c72e: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841c734: dd 59 cc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c73b: a0 00                 cmp     0, d0
4841c73d: c8 41                 beq     0x4841c77e
4841c73f: 4b 10                 mov     a2, (0x10, sp)
4841c741: 58 44                 mov     (0x44, sp), d0
4841c743: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841c749: dd 44 cc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c750: a0 00                 cmp     0, d0
4841c752: c8 2c                 beq     0x4841c77e
4841c754: f8 03 38              mov     (0x38, a3), d0
4841c757: 04                    clr     d1
4841c758: 46 10                 mov     d1, (0x10, sp)
4841c75a: fc cd 3e 00 06 00     mov     0x0006003e, d1
4841c760: dd 20 e5 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c767: 85 ff                 mov     -1, d1
4841c769: cb                    nop
4841c76a: cb                    nop
4841c76b: f2 54                 mulu    d1, d0
4841c76d: 42 10                 mov     d0, (0x10, sp)
4841c76f: 58 44                 mov     (0x44, sp), d0
4841c771: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841c777: dd 16 cc 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c77e: 00                    clr     d0
4841c77f: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841c782: 5e 4c                 mov     (0x4c, sp), a2
4841c784: 8d                    mov     d3, d1
4841c785: 4b 10                 mov     a2, (0x10, sp)
4841c787: 58 44                 mov     (0x44, sp), d0
4841c789: dd e0 cd 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c790: 58 44                 mov     (0x44, sp), d0
4841c792: dd 88 11 01 00 00 00  call    0x4842d91a, 0, 0
4841c799: 93                    mov     a0, a3
4841c79a: 4b 10                 mov     a2, (0x10, sp)
4841c79c: 58 44                 mov     (0x44, sp), d0
4841c79e: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841c7a4: dd e9 cb 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c7ab: a0 00                 cmp     0, d0
4841c7ad: c8 41                 beq     0x4841c7ee
4841c7af: 4b 10                 mov     a2, (0x10, sp)
4841c7b1: 58 44                 mov     (0x44, sp), d0
4841c7b3: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841c7b9: dd d4 cb 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c7c0: a0 00                 cmp     0, d0
4841c7c2: c8 2c                 beq     0x4841c7ee
4841c7c4: f8 03 38              mov     (0x38, a3), d0
4841c7c7: 04                    clr     d1
4841c7c8: 46 10                 mov     d1, (0x10, sp)
4841c7ca: fc cd 3f 00 06 00     mov     0x0006003f, d1
4841c7d0: dd b0 e4 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c7d7: 85 ff                 mov     -1, d1
4841c7d9: cb                    nop
4841c7da: cb                    nop
4841c7db: f2 54                 mulu    d1, d0
4841c7dd: 42 10                 mov     d0, (0x10, sp)
4841c7df: 58 44                 mov     (0x44, sp), d0
4841c7e1: fc cd 3d 00 06 00     mov     0x0006003d, d1
4841c7e7: dd a6 cb 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841c7ee: 00                    clr     d0
4841c7ef: ca 10                 bra     0x4841c7ff
4841c7f1: 5c 4c                 mov     (0x4c, sp), a0
4841c7f3: 8d                    mov     d3, d1
4841c7f4: 43 10                 mov     a0, (0x10, sp)
4841c7f6: 58 44                 mov     (0x44, sp), d0
4841c7f8: dd 71 cd 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841c7ff: df f0 3c              ret     [d2,d3,a2,a3], 0x3c
4841c802: cf 80                 movm    [d2], (sp)
4841c804: f8 fe ec              add     -0x14, sp
4841c807: 82                    mov     d0, d2
4841c808: fc c9 44 00 06 00     cmp     0x60044, d1
4841c80e: c8 3c                 beq     0x4841c84a
4841c810: fc c9 3e 00 06 00     cmp     0x6003e, d1
4841c816: c8 52                 beq     0x4841c868
4841c818: fc c9 3f 00 06 00     cmp     0x6003f, d1
4841c81e: c8 4e                 beq     0x4841c86c
4841c820: fc c9 40 00 06 00     cmp     0x60040, d1
4841c826: c8 4a                 beq     0x4841c870
4841c828: fc c9 41 00 06 00     cmp     0x60041, d1
4841c82e: c8 46                 beq     0x4841c874
4841c830: fc c9 42 00 06 00     cmp     0x60042, d1
4841c836: c8 42                 beq     0x4841c878
4841c838: fc c9 43 00 06 00     cmp     0x60043, d1

MainRamPut:
4841c88b: cf 20                 movm    [a2], (sp)
4841c88d: f8 fe ec              add     -0x14, sp
4841c890: 92                    mov     a0, a2
4841c891: 80 18                 mov     0x18, d0
4841c893: cd 97 9d b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841c898: 91                    mov     a0, a1
4841c899: 85 fa                 mov     -6, d1
4841c89b: db                    setlb
4841c89c: 72                    mov     (a2), d0
4841c89d: 52                    inc4    a2
4841c89e: 61                    mov     d0, (a1)
4841c89f: 51                    inc4    a1
4841c8a0: 44                    inc     d1
4841c8a1: d9                    lne
4841c8a2: 92                    mov     a0, a2
4841c8a3: 4b 10                 mov     a2, (0x10, sp)
4841c8a5: fc cc 08 00 03 00     mov     0x00030008, d0
4841c8ab: fc cd 60 00 06 00     mov     0x00060060, d1
4841c8b1: dd 94 e4 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c8b8: 4b 10                 mov     a2, (0x10, sp)
4841c8ba: fc cc 03 00 03 00     mov     0x00030003, d0
4841c8c0: fc cd 23 00 06 00     mov     0x00060023, d1
4841c8c6: dd 7f e4 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c8cd: df 20 18              ret     [a2], 0x18

MainRamAdd:
4841c8d0: cf 20                 movm    [a2], (sp)
4841c8d2: f8 fe ec              add     -0x14, sp
4841c8d5: 92                    mov     a0, a2
4841c8d6: 80 18                 mov     0x18, d0
4841c8d8: cd 52 9d b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841c8dd: 91                    mov     a0, a1
4841c8de: 85 fa                 mov     -6, d1
4841c8e0: db                    setlb
4841c8e1: 72                    mov     (a2), d0
4841c8e2: 52                    inc4    a2
4841c8e3: 61                    mov     d0, (a1)
4841c8e4: 51                    inc4    a1
4841c8e5: 44                    inc     d1
4841c8e6: d9                    lne
4841c8e7: 92                    mov     a0, a2
4841c8e8: 4b 10                 mov     a2, (0x10, sp)
4841c8ea: fc cc 08 00 03 00     mov     0x00030008, d0
4841c8f0: fc cd 61 00 06 00     mov     0x00060061, d1
4841c8f6: dd 4f e4 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c8fd: 4b 10                 mov     a2, (0x10, sp)
4841c8ff: fc cc 03 00 03 00     mov     0x00030003, d0
4841c905: fc cd 23 00 06 00     mov     0x00060023, d1
4841c90b: dd 3a e4 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c912: df 20 18              ret     [a2], 0x18

MainRamGet:
4841c915: cf a0                 movm    [d2,a2], (sp)
4841c917: f8 fe ec              add     -0x14, sp
4841c91a: 82                    mov     d0, d2
4841c91b: 92                    mov     a0, a2
4841c91c: 80 18                 mov     0x18, d0
4841c91e: cd 0c 9d b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841c923: f0 18                 mov     a2, (a0)
4841c925: f8 78 04              movhu   d2, (4, a0)
4841c928: 00                    clr     d0
4841c929: f8 10 08              mov     d0, (8, a0)
4841c92c: f8 10 0c              mov     d0, (0xc, a0)
4841c92f: f8 10 10              mov     d0, (0x10, a0)
4841c932: f8 10 14              mov     d0, (0x14, a0)
4841c935: 92                    mov     a0, a2
4841c936: 4b 10                 mov     a2, (0x10, sp)
4841c938: fc cc 08 00 03 00     mov     0x00030008, d0
4841c93e: fc cd 5f 00 06 00     mov     0x0006005f, d1
4841c944: dd 01 e4 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c94b: 4b 10                 mov     a2, (0x10, sp)
4841c94d: fc cc 03 00 03 00     mov     0x00030003, d0
4841c953: fc cd 23 00 06 00     mov     0x00060023, d1
4841c959: dd ec e3 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841c960: df a0 1c              ret     [d2,a2], 0x1c

AcBitEditBoxProc:
4841c963: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841c965: f8 fe dc              add     -0x24, sp
4841c968: 82                    mov     d0, d2
4841c969: fc c9 3a 00 06 00     cmp     0x6003a, d1
4841c96f: c8 41                 beq     0x4841c9b0
4841c971: fc c9 3b 00 06 00     cmp     0x6003b, d1
4841c977: c8 79                 beq     0x4841c9f0
4841c979: fc c9 3d 00 06 00     cmp     0x6003d, d1
4841c97f: c8 71                 beq     0x4841c9f0
4841c981: fc c9 09 00 05 00     cmp     0x50009, d1
4841c987: c9 05                 bne     0x4841c98c
4841c989: cc a8 00              jmp     0x4841ca31
4841c98c: fc c9 1c 00 05 00     cmp     0x5001c, d1
4841c992: c9 05                 bne     0x4841c997
4841c994: cc e1 00              jmp     0x4841ca75
4841c997: fc c9 0f 00 05 00     cmp     0x5000f, d1
4841c99d: c9 05                 bne     0x4841c9a2
4841c99f: cc 39 01              jmp     0x4841cad8
4841c9a2: fc c9 10 00 05 00     cmp     0x50010, d1
4841c9a8: c9 05                 bne     0x4841c9ad
4841c9aa: cc aa 01              jmp     0x4841cb54
4841c9ad: cc 22 02              jmp     0x4841cbcf
4841c9b0: dd 6a 0f 01 00 00 00  call    0x4842d91a, 0, 0
4841c9b7: 92                    mov     a0, a2
4841c9b8: 9f 38                 mov     0x38, a3
4841c9ba: f1 7b                 add     a2, a3
4841c9bc: 73                    mov     (a3), d0
4841c9bd: 04                    clr     d1
4841c9be: 46 10                 mov     d1, (0x10, sp)
4841c9c0: fc cd 5a 00 06 00     mov     0x0006005a, d1
4841c9c6: dd ba e2 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c9cd: 42 14                 mov     d0, (0x14, sp)
4841c9cf: f8 22 3c              mov     (0x3c, a2), a0
4841c9d2: fc cd 59 00 06 00     mov     0x00060059, d1
4841c9d8: 70                    mov     (a0), d0
4841c9d9: 3c                    mov     sp, a0
4841c9da: 42 1c                 mov     d0, (0x1c, sp)
4841c9dc: 5d 44                 mov     (0x44, sp), a1
4841c9de: 20 14                 add     0x14, a0
4841c9e0: 47 20                 mov     a1, (0x20, sp)
4841c9e2: 73                    mov     (a3), d0
4841c9e3: 43 10                 mov     a0, (0x10, sp)
4841c9e5: dd 9b e2 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841c9ec: 00                    clr     d0
4841c9ed: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841c9f0: dd 2a 0f 01 00 00 00  call    0x4842d91a, 0, 0
4841c9f7: 92                    mov     a0, a2
4841c9f8: 22 38                 add     0x38, a2
4841c9fa: 72                    mov     (a2), d0
4841c9fb: 04                    clr     d1
4841c9fc: 46 10                 mov     d1, (0x10, sp)
4841c9fe: fc cd 5a 00 06 00     mov     0x0006005a, d1
4841ca04: dd 7c e2 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841ca0b: 42 14                 mov     d0, (0x14, sp)
4841ca0d: 72                    mov     (a2), d0
4841ca0e: 04                    clr     d1
4841ca0f: 46 10                 mov     d1, (0x10, sp)
4841ca11: fc cd 5b 00 06 00     mov     0x0006005b, d1
4841ca17: dd 69 e2 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841ca1e: 42 18                 mov     d0, (0x18, sp)
4841ca20: 5d 44                 mov     (0x44, sp), a1
4841ca22: 3f                    mov     sp, a3
4841ca23: 23 14                 add     0x14, a3
4841ca25: 47 1c                 mov     a1, (0x1c, sp)
4841ca27: 9c                    mov     a3, a0
4841ca28: cd 18 02 30 1c        call    0x4841cc40, [a2,a3], 0x1c
4841ca2d: 00                    clr     d0
4841ca2e: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841ca31: 5c 44                 mov     (0x44, sp), a0
4841ca33: 43 10                 mov     a0, (0x10, sp)
4841ca35: dd 34 cb 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841ca3c: 88                    mov     d2, d0
4841ca3d: dd dd 0e 01 00 00 00  call    0x4842d91a, 0, 0
4841ca44: 92                    mov     a0, a2
4841ca45: 22 38                 add     0x38, a2
4841ca47: 72                    mov     (a2), d0
4841ca48: 04                    clr     d1
4841ca49: 46 10                 mov     d1, (0x10, sp)
4841ca4b: fc cd 5a 00 06 00     mov     0x0006005a, d1
4841ca51: dd 2f e2 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841ca58: f1 e3                 mov     d0, a3
4841ca5a: 72                    mov     (a2), d0
4841ca5b: 04                    clr     d1
4841ca5c: 46 10                 mov     d1, (0x10, sp)
4841ca5e: fc cd 5b 00 06 00     mov     0x0006005b, d1
4841ca64: dd 1c e2 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841ca6b: 9c                    mov     a3, a0
4841ca6c: cd 19 02 a0 1c        call    0x4841cc85, [d2,a2], 0x1c
4841ca71: 00                    clr     d0
4841ca72: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841ca75: 5f 44                 mov     (0x44, sp), a3
4841ca77: 9a 38                 mov     0x38, a2
4841ca79: 4f 10                 mov     a3, (0x10, sp)
4841ca7b: dd ee ca 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841ca82: 88                    mov     d2, d0
4841ca83: dd 97 0e 01 00 00 00  call    0x4842d91a, 0, 0
4841ca8a: f1 d3                 mov     a0, d3
4841ca8c: f1 6e                 add     d3, a2
4841ca8e: 72                    mov     (a2), d0
4841ca8f: 04                    clr     d1
4841ca90: 46 10                 mov     d1, (0x10, sp)
4841ca92: fc cd 5a 00 06 00     mov     0x0006005a, d1
4841ca98: dd e8 e1 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841ca9f: 77                    mov     (a3), d1
4841caa0: a4                    cmp     d1, d0
4841caa1: c9 33                 bne     0x4841cad4
4841caa3: 72                    mov     (a2), d0
4841caa4: 04                    clr     d1
4841caa5: 46 10                 mov     d1, (0x10, sp)
4841caa7: fc cd 5b 00 06 00     mov     0x0006005b, d1
4841caad: dd d3 e1 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841cab4: f8 07 04              mov     (4, a3), d1
4841cab7: a4                    cmp     d1, d0
4841cab8: c9 1c                 bne     0x4841cad4
4841caba: f1 ec                 mov     d3, a0
4841cabc: f8 03 08              mov     (8, a3), d0
4841cabf: f8 20 3c              mov     (0x3c, a0), a0
4841cac2: fc cd b4 00 06 00     mov     0x000600b4, d1
4841cac8: 60                    mov     d0, (a0)
4841cac9: 00                    clr     d0
4841caca: 42 10                 mov     d0, (0x10, sp)
4841cacc: 88                    mov     d2, d0
4841cacd: dd c0 c8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cad4: 00                    clr     d0
4841cad5: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841cad8: 5e 44                 mov     (0x44, sp), a2
4841cada: 4b 10                 mov     a2, (0x10, sp)
4841cadc: dd 8d ca 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841cae3: 88                    mov     d2, d0
4841cae4: dd 36 0e 01 00 00 00  call    0x4842d91a, 0, 0
4841caeb: 93                    mov     a0, a3
4841caec: 4b 10                 mov     a2, (0x10, sp)
4841caee: 88                    mov     d2, d0
4841caef: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841caf5: dd 98 c8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cafc: a0 00                 cmp     0, d0
4841cafe: c8 52                 beq     0x4841cb50
4841cb00: 4b 10                 mov     a2, (0x10, sp)
4841cb02: 88                    mov     d2, d0
4841cb03: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841cb09: dd 84 c8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cb10: a0 00                 cmp     0, d0
4841cb12: c8 3e                 beq     0x4841cb50
4841cb14: f8 03 38              mov     (0x38, a3), d0
4841cb17: 04                    clr     d1
4841cb18: 46 10                 mov     d1, (0x10, sp)
4841cb1a: fc cd 5c 00 06 00     mov     0x0006005c, d1
4841cb20: dd 60 e1 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841cb27: a0 00                 cmp     0, d0
4841cb29: c8 15                 beq     0x4841cb3e
4841cb2b: 00                    clr     d0
4841cb2c: 42 10                 mov     d0, (0x10, sp)
4841cb2e: fc cd 3b 00 06 00     mov     0x0006003b, d1
4841cb34: 88                    mov     d2, d0
4841cb35: dd 58 c8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cb3c: ca 14                 bra     0x4841cb50
4841cb3e: 80 01                 mov     1, d0
4841cb40: 42 10                 mov     d0, (0x10, sp)
4841cb42: fc cd 3b 00 06 00     mov     0x0006003b, d1
4841cb48: 88                    mov     d2, d0
4841cb49: dd 44 c8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cb50: 00                    clr     d0
4841cb51: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841cb54: 5e 44                 mov     (0x44, sp), a2
4841cb56: 4b 10                 mov     a2, (0x10, sp)
4841cb58: dd 11 ca 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841cb5f: 88                    mov     d2, d0
4841cb60: dd ba 0d 01 00 00 00  call    0x4842d91a, 0, 0
4841cb67: 93                    mov     a0, a3
4841cb68: 4b 10                 mov     a2, (0x10, sp)
4841cb6a: 88                    mov     d2, d0
4841cb6b: fc cd 3c 00 06 00     mov     0x0006003c, d1
4841cb71: dd 1c c8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cb78: a0 00                 cmp     0, d0
4841cb7a: c8 52                 beq     0x4841cbcc
4841cb7c: 4b 10                 mov     a2, (0x10, sp)
4841cb7e: 88                    mov     d2, d0
4841cb7f: fc cd 4d 00 06 00     mov     0x0006004d, d1
4841cb85: dd 08 c8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cb8c: a0 00                 cmp     0, d0
4841cb8e: c8 3e                 beq     0x4841cbcc
4841cb90: f8 03 38              mov     (0x38, a3), d0
4841cb93: 04                    clr     d1
4841cb94: 46 10                 mov     d1, (0x10, sp)
4841cb96: fc cd 5c 00 06 00     mov     0x0006005c, d1
4841cb9c: dd e4 e0 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841cba3: a0 00                 cmp     0, d0
4841cba5: c8 16                 beq     0x4841cbbb
4841cba7: 80 01                 mov     1, d0
4841cba9: 42 10                 mov     d0, (0x10, sp)
4841cbab: fc cd 3b 00 06 00     mov     0x0006003b, d1
4841cbb1: 88                    mov     d2, d0
4841cbb2: dd db c7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cbb9: ca 13                 bra     0x4841cbcc
4841cbbb: 00                    clr     d0
4841cbbc: 42 10                 mov     d0, (0x10, sp)
4841cbbe: fc cd 3b 00 06 00     mov     0x0006003b, d1
4841cbc4: 88                    mov     d2, d0
4841cbc5: dd c8 c7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cbcc: 00                    clr     d0
4841cbcd: ca 0d                 bra     0x4841cbda
4841cbcf: 5c 44                 mov     (0x44, sp), a0
4841cbd1: 43 10                 mov     a0, (0x10, sp)
4841cbd3: dd 96 c9 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841cbda: df f0 34              ret     [d2,d3,a2,a3], 0x34
4841cbdd: cf a0                 movm    [d2,a2], (sp)
4841cbdf: f8 fe f0              add     -0x10, sp
4841cbe2: 82                    mov     d0, d2
4841cbe3: fc c9 59 00 06 00     cmp     0x60059, d1
4841cbe9: c8 1c                 beq     0x4841cc05
4841cbeb: fc c9 5a 00 06 00     cmp     0x6005a, d1
4841cbf1: c8 33                 beq     0x4841cc24
4841cbf3: fc c9 5b 00 06 00     cmp     0x6005b, d1
4841cbf9: c8 33                 beq     0x4841cc2c
4841cbfb: fc c9 5c 00 06 00     cmp     0x6005c, d1
4841cc01: c8 33                 beq     0x4841cc34
4841cc03: ca 34                 bra     0x4841cc37
4841cc05: 5c 28                 mov     (0x28, sp), a0
4841cc07: f8 28 0c              mov     (0xc, a0), a2
4841cc0a: f8 00 08              mov     (8, a0), d0
4841cc0d: fc dc bc f1 59 48     mov     0x4859f1bc, a0
4841cc13: f8 e0 01              and     0x01, d0
4841cc16: 54                    asl2    d0
4841cc17: f3 90                 mov     (d0, a0), a1
4841cc19: 98                    mov     a2, a0
4841cc1a: dd 37 64 be 03 20 04  call    0x4c003051, [a2], 4
4841cc21: 88                    mov     d2, d0
4841cc22: ca 16                 bra     0x4841cc38
4841cc24: fc cc 18 a0 02 50     mov     0x5002a018, d0
4841cc2a: ca 0e                 bra     0x4841cc38
4841cc2c: fc cc 00 80 00 00     mov     0x00008000, d0
4841cc32: ca 06                 bra     0x4841cc38
4841cc34: 00                    clr     d0
4841cc35: ca 03                 bra     0x4841cc38
4841cc37: 00                    clr     d0
4841cc38: df a0 18              ret     [d2,a2], 0x18

MainBitPut:
4841cc3b: cf 30                 movm    [a2,a3], (sp)
4841cc3d: f8 fe ec              add     -0x14, sp
4841cc40: 93                    mov     a0, a3
4841cc41: 80 10                 mov     0x10, d0
4841cc43: cd e7 99 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841cc48: 92                    mov     a0, a2
4841cc49: 80 10                 mov     0x10, d0
4841cc4b: 9d                    mov     a3, a1
4841cc4c: dd ed 63 be 03 30 08  call    0x4c003039, [a2,a3], 8
4841cc53: 4b 10                 mov     a2, (0x10, sp)
4841cc55: fc cc 07 00 03 00     mov     0x00030007, d0
4841cc5b: fc cd 5e 00 06 00     mov     0x0006005e, d1
4841cc61: dd e4 e0 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841cc68: 4b 10                 mov     a2, (0x10, sp)
4841cc6a: fc cc 03 00 03 00     mov     0x00030003, d0
4841cc70: fc cd 23 00 06 00     mov     0x00060023, d1
4841cc76: dd cf e0 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841cc7d: df 30 1c              ret     [a2,a3], 0x1c

MainBitGet:
4841cc80: cf a0                 movm    [d2,a2], (sp)
4841cc82: f8 fe ec              add     -0x14, sp
4841cc85: 82                    mov     d0, d2
4841cc86: 92                    mov     a0, a2
4841cc87: 80 10                 mov     0x10, d0
4841cc89: cd a1 99 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841cc8e: f0 18                 mov     a2, (a0)
4841cc90: f8 18 04              mov     d2, (4, a0)
4841cc93: 00                    clr     d0
4841cc94: f8 10 08              mov     d0, (8, a0)
4841cc97: f8 10 0c              mov     d0, (0xc, a0)
4841cc9a: 92                    mov     a0, a2
4841cc9b: 4b 10                 mov     a2, (0x10, sp)
4841cc9d: fc cc 07 00 03 00     mov     0x00030007, d0
4841cca3: fc cd 5d 00 06 00     mov     0x0006005d, d1
4841cca9: dd 9c e0 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841ccb0: 4b 10                 mov     a2, (0x10, sp)
4841ccb2: fc cc 03 00 03 00     mov     0x00030003, d0
4841ccb8: fc cd 23 00 06 00     mov     0x00060023, d1
4841ccbe: dd 87 e0 00 00 e0 24  call    0x4842ad45, [d2,d3,a2], 0x24
4841ccc5: df a0 1c              ret     [d2,a2], 0x1c

PsMenuBoxProc:
4841ccc8: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841ccca: f8 fe 94              add     -0x6c, sp
4841cccd: 82                    mov     d0, d2
4841ccce: fc c9 3a 00 06 00     cmp     0x6003a, d1
4841ccd4: c8 41                 beq     0x4841cd15
4841ccd6: fc c9 b2 00 06 00     cmp     0x600b2, d1
4841ccdc: c8 41                 beq     0x4841cd1d
4841ccde: fc c9 b4 00 06 00     cmp     0x600b4, d1
4841cce4: c8 58                 beq     0x4841cd3c
4841cce6: fc c9 51 00 06 00     cmp     0x60051, d1
4841ccec: c9 05                 bne     0x4841ccf1
4841ccee: cc 9c 03              jmp     0x4841d08a
4841ccf1: fc c9 af 00 06 00     cmp     0x600af, d1
4841ccf7: c9 05                 bne     0x4841ccfc
4841ccf9: cc c9 03              jmp     0x4841d0c2
4841ccfc: fc c9 ae 00 06 00     cmp     0x600ae, d1
4841cd02: c9 05                 bne     0x4841cd07
4841cd04: cc ca 03              jmp     0x4841d0ce
4841cd07: fc c9 b8 00 06 00     cmp     0x600b8, d1
4841cd0d: c9 05                 bne     0x4841cd12
4841cd0f: cc cc 03              jmp     0x4841d0db
4841cd12: cc cc 03              jmp     0x4841d0de
4841cd15: 5c 8c                 mov     (0x8c, sp), a0
4841cd17: 00                    clr     d0
4841cd18: f0 50                 movbu   d0, (a0)
4841cd1a: df f0 7c              ret     [d2,d3,a2,a3], 0x7c
4841cd1d: 5c 8c                 mov     (0x8c, sp), a0
4841cd1f: 43 10                 mov     a0, (0x10, sp)
4841cd21: dd 48 c8 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841cd28: 88                    mov     d2, d0
4841cd29: dd f1 0b 01 00 00 00  call    0x4842d91a, 0, 0
4841cd30: f8 60 28              movhu   (0x28, a0), d0
4841cd33: cd ed 0a f0 48        call    0x4841d820, [d2,d3,a2,a3], 0x48
4841cd38: 00                    clr     d0
4841cd39: df f0 7c              ret     [d2,d3,a2,a3], 0x7c
4841cd3c: dd de 0b 01 00 00 00  call    0x4842d91a, 0, 0
4841cd43: 2c 00 01              mov     0x100, d0
4841cd46: 92                    mov     a0, a2
4841cd47: cd e3 98 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841cd4c: 43 40                 mov     a0, (0x40, sp)
4841cd4e: 2c 00 01              mov     0x100, d0
4841cd51: cd d9 98 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841cd56: 43 2c                 mov     a0, (0x2c, sp)
4841cd58: 5d 8c                 mov     (0x8c, sp), a1
4841cd5a: b5 00                 cmp     0, a1
4841cd5c: c9 2c                 bne     0x4841cd88
4841cd5e: 5c 40                 mov     (0x40, sp), a0
4841cd60: 88                    mov     d2, d0
4841cd61: 43 10                 mov     a0, (0x10, sp)
4841cd63: fc cd 3a 00 06 00     mov     0x0006003a, d1
4841cd69: dd 24 c6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cd70: 5c 40                 mov     (0x40, sp), a0
4841cd72: f0 40                 movbu   (a0), d0
4841cd74: a0 00                 cmp     0, d0
4841cd76: c9 1b                 bne     0x4841cd91
4841cd78: cd 66 99 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841cd7d: 5c 2c                 mov     (0x2c, sp), a0
4841cd7f: cd 5f 99 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841cd84: 00                    clr     d0
4841cd85: df f0 7c              ret     [d2,d3,a2,a3], 0x7c
4841cd88: 5c 40                 mov     (0x40, sp), a0
4841cd8a: dd c7 62 be 03 20 04  call    0x4c003051, [a2], 4
4841cd91: 00                    clr     d0
4841cd92: 42 10                 mov     d0, (0x10, sp)
4841cd94: 88                    mov     d2, d0
4841cd95: fc cd af 00 06 00     mov     0x000600af, d1
4841cd9b: dd f2 c5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cda2: 42 34                 mov     d0, (0x34, sp)
4841cda4: 00                    clr     d0
4841cda5: 42 10                 mov     d0, (0x10, sp)
4841cda7: 88                    mov     d2, d0
4841cda8: fc cd ae 00 06 00     mov     0x000600ae, d1
4841cdae: dd df c5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cdb5: f8 93 44              movhu   d0, (0x44, sp)
4841cdb8: 00                    clr     d0
4841cdb9: 42 10                 mov     d0, (0x10, sp)
4841cdbb: 88                    mov     d2, d0
4841cdbc: fc cd b8 00 06 00     mov     0x000600b8, d1
4841cdc2: dd cb c5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841cdc9: 42 3c                 mov     d0, (0x3c, sp)
4841cdcb: 3c                    mov     sp, a0
4841cdcc: 20 48                 add     0x48, a0
4841cdce: 88                    mov     d2, d0
4841cdcf: cd 16 9d 00 14        call    0x48416ae5, 0, 0x14
4841cdd4: 3d                    mov     sp, a1
4841cdd5: 21 48                 add     0x48, a1
4841cdd7: 3c                    mov     sp, a0
4841cdd8: 20 50                 add     0x50, a0
4841cdda: 85 fc                 mov     -4, d1
4841cddc: db                    setlb
4841cddd: f0 61                 movhu   (a1), d0
4841cddf: 21 02                 add     2, a1
4841cde1: f0 70                 movhu   d0, (a0)
4841cde3: 20 02                 add     2, a0
4841cde5: 44                    inc     d1
4841cde6: d9                    lne
4841cde7: 3c                    mov     sp, a0
4841cde8: f8 62 28              movhu   (0x28, a2), d0
4841cdeb: 20 58                 add     0x58, a0
4841cded: cd 3a ad 00 10        call    0x48417b27, 0, 0x10
4841cdf2: 58 34                 mov     (0x34, sp), d0
4841cdf4: dd 6c 11 01 00 00 00  call    0x4842df60, 0, 0
4841cdfb: f1 e2                 mov     d0, a2
4841cdfd: 58 3c                 mov     (0x3c, sp), d0
4841cdff: a0 00                 cmp     0, d0
4841ce01: c8 25                 beq     0x4841ce26
4841ce03: f8 bc 58              movhu   (0x58, sp), d0
4841ce06: 18                    exth    d0
4841ce07: a0 00                 cmp     0, d0
4841ce09: c9 1d                 bne     0x4841ce26
4841ce0b: f8 bc 48              movhu   (0x48, sp), d0
4841ce0e: 3c                    mov     sp, a0
4841ce0f: 18                    exth    d0
4841ce10: f1 d1                 mov     a0, d1
4841ce12: 29 5c                 add     0x5c, d1
4841ce14: 46 38                 mov     d1, (0x38, sp)
4841ce16: 28 20                 add     0x20, d0
4841ce18: f8 93 5c              movhu   d0, (0x5c, sp)
4841ce1b: f1 d1                 mov     a0, d1
4841ce1d: 29 50                 add     0x50, d1
4841ce1f: 46 30                 mov     d1, (0x30, sp)
4841ce21: f8 93 50              movhu   d0, (0x50, sp)
4841ce24: ca 1b                 bra     0x4841ce3f
4841ce26: f8 bc 48              movhu   (0x48, sp), d0
4841ce29: 3c                    mov     sp, a0
4841ce2a: 18                    exth    d0
4841ce2b: f1 d1                 mov     a0, d1
4841ce2d: 29 5c                 add     0x5c, d1
4841ce2f: 46 38                 mov     d1, (0x38, sp)
4841ce31: 28 04                 add     4, d0
4841ce33: f8 93 5c              movhu   d0, (0x5c, sp)
4841ce36: f1 d1                 mov     a0, d1
4841ce38: 29 50                 add     0x50, d1
4841ce3a: 46 30                 mov     d1, (0x30, sp)
4841ce3c: f8 93 50              movhu   d0, (0x50, sp)
4841ce3f: 58 3c                 mov     (0x3c, sp), d0
4841ce41: a0 00                 cmp     0, d0
4841ce43: c8 15                 beq     0x4841ce58
4841ce45: f8 bc 58              movhu   (0x58, sp), d0
4841ce48: 18                    exth    d0
4841ce49: a0 00                 cmp     0, d0
4841ce4b: c8 0d                 beq     0x4841ce58
4841ce4d: f8 bc 4c              movhu   (0x4c, sp), d0
4841ce50: 18                    exth    d0
4841ce51: 28 e0                 add     -0x20, d0
4841ce53: f8 93 54              movhu   d0, (0x54, sp)
4841ce56: ca 0b                 bra     0x4841ce61
4841ce58: f8 bc 4c              movhu   (0x4c, sp), d0
4841ce5b: 18                    exth    d0
4841ce5c: 28 fc                 add     -4, d0
4841ce5e: f8 93 54              movhu   d0, (0x54, sp)
4841ce61: 5c 40                 mov     (0x40, sp), a0
4841ce63: 5d 2c                 mov     (0x2c, sp), a1
4841ce65: 58 34                 mov     (0x34, sp), d0
4841ce67: dd 46 11 01 00 f0 20  call    0x4842dfad, [d2,d3,a2,a3], 0x20
4841ce6e: f8 bc 54              movhu   (0x54, sp), d0
4841ce71: f8 bd 50              movhu   (0x50, sp), d1
4841ce74: 18                    exth    d0
4841ce75: 19                    exth    d1
4841ce76: 5c 2c                 mov     (0x2c, sp), a0
4841ce78: f1 04                 sub     d1, d0
4841ce7a: 81                    mov     d0, d1
4841ce7b: 19                    exth    d1
4841ce7c: 58 34                 mov     (0x34, sp), d0
4841ce7e: dd f3 12 01 00 f0 2c  call    0x4842e171, [d2,d3,a2,a3], 0x2c
4841ce85: 82                    mov     d0, d2
4841ce86: 5c 2c                 mov     (0x2c, sp), a0
4841ce88: dd 6f 64 be 03 00 00  call    0x4c0032f7, 0, 0
4841ce8f: 1a                    exth    d2
4841ce90: 4a 28                 mov     d2, (0x28, sp)
4841ce92: a2                    cmp     d0, d2
4841ce93: c9 6b                 bne     0x4841cefe
4841ce95: f8 bc 58              movhu   (0x58, sp), d0
4841ce98: 18                    exth    d0
4841ce99: a0 00                 cmp     0, d0
4841ce9b: c8 17                 beq     0x4841ceb2
4841ce9d: 5c 2c                 mov     (0x2c, sp), a0
4841ce9f: 58 34                 mov     (0x34, sp), d0
4841cea1: dd 1f 12 01 00 f0 24  call    0x4842e0c0, [d2,d3,a2,a3], 0x24
4841cea8: f8 bd 54              movhu   (0x54, sp), d1
4841ceab: 18                    exth    d0
4841ceac: 19                    exth    d1
4841cead: f1 01                 sub     d0, d1
4841ceaf: f8 97 5c              movhu   d1, (0x5c, sp)
4841ceb2: f8 bc 4e              movhu   (0x4e, sp), d0
4841ceb5: f8 bd 4a              movhu   (0x4a, sp), d1
4841ceb8: f8 bf 4a              movhu   (0x4a, sp), d3
4841cebb: 18                    exth    d0
4841cebc: 19                    exth    d1
4841cebd: 1b                    exth    d3
4841cebe: f1 04                 sub     d1, d0
4841cec0: 8a 02                 mov     2, d2
4841cec2: 4a 20                 mov     d2, (0x20, sp)
4841cec4: 89                    mov     d2, d1
4841cec5: dd 10 4b be 03 00 00  call    0x4c0019d5, 0, 0
4841cecc: 82                    mov     d0, d2
4841cecd: f1 d8                 mov     a2, d0
4841cecf: 18                    exth    d0
4841ced0: 59 20                 mov     (0x20, sp), d1
4841ced2: dd 03 4b be 03 00 00  call    0x4c0019d5, 0, 0
4841ced9: ee                    add     d3, d2
4841ceda: f1 02                 sub     d0, d2
4841cedc: 2a 02                 add     2, d2
4841cede: f8 9b 5e              movhu   d2, (0x5e, sp)
4841cee1: 58 2c                 mov     (0x2c, sp), d0
4841cee3: 42 10                 mov     d0, (0x10, sp)
4841cee5: 2c f7 00              mov     0xf7, d0
4841cee8: 42 1c                 mov     d0, (0x1c, sp)
4841ceea: f8 bd 44              movhu   (0x44, sp), d1
4841ceed: 5c 30                 mov     (0x30, sp), a0
4841ceef: 5d 38                 mov     (0x38, sp), a1
4841cef1: 58 34                 mov     (0x34, sp), d0
4841cef3: 19                    exth    d1
4841cef4: dd a4 84 00 00 f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30
4841cefb: cc fd 00              jmp     0x4841cff8
4841cefe: 5c 2c                 mov     (0x2c, sp), a0
4841cf00: 88                    mov     d2, d0
4841cf01: 28 ff                 add     -1, d0
4841cf03: 04                    clr     d1
4841cf04: f4                    movbu   d1, (d0, a0)
4841cf05: 50                    inc4    a0
4841cf06: 58 3c                 mov     (0x3c, sp), d0
4841cf08: a4                    cmp     d1, d0
4841cf09: c8 53                 beq     0x4841cf5c
4841cf0b: f8 bc 58              movhu   (0x58, sp), d0
4841cf0e: 18                    exth    d0
4841cf0f: a4                    cmp     d1, d0
4841cf10: c8 4c                 beq     0x4841cf5c
4841cf12: 5c 2c                 mov     (0x2c, sp), a0
4841cf14: dd e3 63 be 03 00 00  call    0x4c0032f7, 0, 0
4841cf1b: 5c 2c                 mov     (0x2c, sp), a0
4841cf1d: 82                    mov     d0, d2
4841cf1e: 58 28                 mov     (0x28, sp), d0
4841cf20: f1 60                 add     d0, a0
4841cf22: dd d5 63 be 03 00 00  call    0x4c0032f7, 0, 0
4841cf29: a2                    cmp     d0, d2
4841cf2a: c7 19                 bls     0x4841cf43
4841cf2c: 5c 2c                 mov     (0x2c, sp), a0
4841cf2e: 58 34                 mov     (0x34, sp), d0
4841cf30: dd 90 11 01 00 f0 24  call    0x4842e0c0, [d2,d3,a2,a3], 0x24
4841cf37: f8 bd 54              movhu   (0x54, sp), d1
4841cf3a: 18                    exth    d0
4841cf3b: 19                    exth    d1
4841cf3c: f1 01                 sub     d0, d1
4841cf3e: f8 97 5c              movhu   d1, (0x5c, sp)
4841cf41: ca 1b                 bra     0x4841cf5c
4841cf43: 5c 2c                 mov     (0x2c, sp), a0
4841cf45: 58 28                 mov     (0x28, sp), d0
4841cf47: f1 60                 add     d0, a0
4841cf49: 58 34                 mov     (0x34, sp), d0
4841cf4b: dd 75 11 01 00 f0 24  call    0x4842e0c0, [d2,d3,a2,a3], 0x24
4841cf52: f8 bd 54              movhu   (0x54, sp), d1
4841cf55: 18                    exth    d0
4841cf56: 19                    exth    d1
4841cf57: f1 01                 sub     d0, d1
4841cf59: f8 97 5c              movhu   d1, (0x5c, sp)
4841cf5c: f8 bc 4e              movhu   (0x4e, sp), d0
4841cf5f: f8 bd 4a              movhu   (0x4a, sp), d1
4841cf62: f8 bf 4a              movhu   (0x4a, sp), d3
4841cf65: 18                    exth    d0
4841cf66: 19                    exth    d1
4841cf67: 1b                    exth    d3
4841cf68: f1 da                 mov     a2, d2
4841cf6a: 1a                    exth    d2
4841cf6b: 4a 24                 mov     d2, (0x24, sp)
4841cf6d: f1 04                 sub     d1, d0
4841cf6f: 8a 02                 mov     2, d2
4841cf71: 4a 20                 mov     d2, (0x20, sp)
4841cf73: 85 04                 mov     4, d1
4841cf75: dd 60 4a be 03 00 00  call    0x4c0019d5, 0, 0
4841cf7c: 82                    mov     d0, d2
4841cf7d: 58 24                 mov     (0x24, sp), d0
4841cf7f: 59 20                 mov     (0x20, sp), d1
4841cf81: dd 54 4a be 03 00 00  call    0x4c0019d5, 0, 0
4841cf88: ee                    add     d3, d2
4841cf89: f1 02                 sub     d0, d2
4841cf8b: 2a 02                 add     2, d2
4841cf8d: f8 9b 5e              movhu   d2, (0x5e, sp)
4841cf90: 58 2c                 mov     (0x2c, sp), d0
4841cf92: 42 10                 mov     d0, (0x10, sp)
4841cf94: f8 bc 44              movhu   (0x44, sp), d0
4841cf97: 18                    exth    d0
4841cf98: f1 e2                 mov     d0, a2
4841cf9a: f1 d9                 mov     a2, d1
4841cf9c: 2c f7 00              mov     0xf7, d0
4841cf9f: 42 1c                 mov     d0, (0x1c, sp)
4841cfa1: 5c 30                 mov     (0x30, sp), a0
4841cfa3: 5d 38                 mov     (0x38, sp), a1
4841cfa5: 58 34                 mov     (0x34, sp), d0
4841cfa7: dd f1 83 00 00 f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30
4841cfae: f8 bc 4e              movhu   (0x4e, sp), d0
4841cfb1: f8 bd 4a              movhu   (0x4a, sp), d1
4841cfb4: f8 bf 4a              movhu   (0x4a, sp), d3
4841cfb7: 18                    exth    d0
4841cfb8: 19                    exth    d1
4841cfb9: 1b                    exth    d3
4841cfba: f1 04                 sub     d1, d0
4841cfbc: 85 04                 mov     4, d1
4841cfbe: dd 17 4a be 03 00 00  call    0x4c0019d5, 0, 0
4841cfc5: 82                    mov     d0, d2
4841cfc6: 58 24                 mov     (0x24, sp), d0
4841cfc8: 59 20                 mov     (0x20, sp), d1
4841cfca: dd 0b 4a be 03 00 00  call    0x4c0019d5, 0, 0
4841cfd1: 89                    mov     d2, d1
4841cfd2: 55                    asl2    d1
4841cfd3: f1 09                 sub     d2, d1
4841cfd5: ed                    add     d3, d1
4841cfd6: f1 01                 sub     d0, d1
4841cfd8: 29 02                 add     2, d1
4841cfda: f8 97 5e              movhu   d1, (0x5e, sp)
4841cfdd: 58 2c                 mov     (0x2c, sp), d0
4841cfdf: 59 28                 mov     (0x28, sp), d1
4841cfe1: e4                    add     d1, d0
4841cfe2: 42 10                 mov     d0, (0x10, sp)
4841cfe4: f1 d9                 mov     a2, d1
4841cfe6: 2c f7 00              mov     0xf7, d0
4841cfe9: 42 1c                 mov     d0, (0x1c, sp)
4841cfeb: 5c 30                 mov     (0x30, sp), a0
4841cfed: 5d 38                 mov     (0x38, sp), a1
4841cfef: 58 34                 mov     (0x34, sp), d0
4841cff1: dd a7 83 00 00 f0 30  call    0x48425398, [d2,d3,a2,a3], 0x30
4841cff8: 58 3c                 mov     (0x3c, sp), d0
4841cffa: a0 00                 cmp     0, d0
4841cffc: c8 7c                 beq     0x4841d078
4841cffe: f8 bc 58              movhu   (0x58, sp), d0
4841d001: 18                    exth    d0
4841d002: a0 00                 cmp     0, d0
4841d004: c8 10                 beq     0x4841d014
4841d006: f8 bc 4c              movhu   (0x4c, sp), d0
4841d009: 3e                    mov     sp, a2
4841d00a: 18                    exth    d0
4841d00b: 22 60                 add     0x60, a2
4841d00d: 28 e7                 add     -0x19, d0
4841d00f: f8 93 60              movhu   d0, (0x60, sp)
4841d012: ca 0e                 bra     0x4841d020
4841d014: f8 bc 48              movhu   (0x48, sp), d0
4841d017: 3e                    mov     sp, a2
4841d018: 18                    exth    d0
4841d019: 22 60                 add     0x60, a2
4841d01b: 28 02                 add     2, d0
4841d01d: f8 93 60              movhu   d0, (0x60, sp)
4841d020: f8 bc 4e              movhu   (0x4e, sp), d0
4841d023: f8 bd 4a              movhu   (0x4a, sp), d1
4841d026: f8 be 4a              movhu   (0x4a, sp), d2
4841d029: 18                    exth    d0
4841d02a: 19                    exth    d1
4841d02b: 1a                    exth    d2
4841d02c: f1 04                 sub     d1, d0
4841d02e: 59 20                 mov     (0x20, sp), d1
4841d030: dd a5 49 be 03 00 00  call    0x4c0019d5, 0, 0
4841d037: e8                    add     d2, d0
4841d038: 28 f5                 add     -0xb, d0
4841d03a: f8 93 62              movhu   d0, (0x62, sp)
4841d03d: f8 bc 60              movhu   (0x60, sp), d0
4841d040: 3c                    mov     sp, a0
4841d041: 18                    exth    d0
4841d042: 28 fe                 add     -2, d0
4841d044: f8 93 64              movhu   d0, (0x64, sp)
4841d047: f8 bc 60              movhu   (0x60, sp), d0
4841d04a: 20 64                 add     0x64, a0
4841d04c: 18                    exth    d0
4841d04d: 28 19                 add     0x19, d0
4841d04f: f8 93 68              movhu   d0, (0x68, sp)
4841d052: f8 bc 62              movhu   (0x62, sp), d0
4841d055: 85 18                 mov     0x18, d1
4841d057: 18                    exth    d0
4841d058: 28 fe                 add     -2, d0
4841d05a: f8 93 66              movhu   d0, (0x66, sp)
4841d05d: f8 bc 62              movhu   (0x62, sp), d0
4841d060: 18                    exth    d0
4841d061: 28 19                 add     0x19, d0
4841d063: f8 93 6a              movhu   d0, (0x6a, sp)
4841d066: 2c c0 00              mov     0xc0, d0
4841d069: dd 3d 91 00 00 e0 20  call    0x484261a6, [d2,d3,a2], 0x20
4841d070: 58 3c                 mov     (0x3c, sp), d0
4841d072: 98                    mov     a2, a0
4841d073: cd 5f 6d a0 18        call    0x48423dd2, [d2,a2], 0x18
4841d078: 5c 40                 mov     (0x40, sp), a0
4841d07a: cd 64 96 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841d07f: 5c 2c                 mov     (0x2c, sp), a0
4841d081: cd 5d 96 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841d086: 00                    clr     d0
4841d087: df f0 7c              ret     [d2,d3,a2,a3], 0x7c
4841d08a: dd 7f 03 01 00 00 0c  call    0x4842d409, 0, 0xc
4841d091: a0 00                 cmp     0, d0
4841d093: c8 2c                 beq     0x4841d0bf
4841d095: 88                    mov     d2, d0
4841d096: dd 84 08 01 00 00 00  call    0x4842d91a, 0, 0
4841d09d: 92                    mov     a0, a2
4841d09e: 5c 8c                 mov     (0x8c, sp), a0
4841d0a0: fc cc 24 00 0d 00     mov     0x000d0024, d0
4841d0a6: 43 10                 mov     a0, (0x10, sp)
4841d0a8: fc cd 29 00 06 00     mov     0x00060029, d1
4841d0ae: dd df c2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d0b5: f8 66 28              movhu   (0x28, a2), d1
4841d0b8: a1                    cmp     d0, d1
4841d0b9: c9 06                 bne     0x4841d0bf
4841d0bb: 80 01                 mov     1, d0
4841d0bd: ca 2c                 bra     0x4841d0e9
4841d0bf: 00                    clr     d0
4841d0c0: ca 29                 bra     0x4841d0e9
4841d0c2: dd 58 08 01 00 00 00  call    0x4842d91a, 0, 0

AcTitleMenuProc:
4841d0ec: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841d0ee: f8 fe ec              add     -0x14, sp
4841d0f1: 83                    mov     d0, d3
4841d0f2: 86                    mov     d1, d2
4841d0f3: fc ca b2 00 06 00     cmp     0x600b2, d2
4841d0f9: c8 23                 beq     0x4841d11c
4841d0fb: fc ca 05 00 05 00     cmp     0x50005, d2
4841d101: c8 3b                 beq     0x4841d13c
4841d103: fc ca 3a 00 06 00     cmp     0x6003a, d2
4841d109: c9 05                 bne     0x4841d10e
4841d10b: cc 0f 01              jmp     0x4841d21a
4841d10e: fc ca b8 00 06 00     cmp     0x600b8, d2
4841d114: c9 05                 bne     0x4841d119
4841d116: cc 1b 01              jmp     0x4841d231
4841d119: cc 24 01              jmp     0x4841d23d
4841d11c: 5c 34                 mov     (0x34, sp), a0
4841d11e: 43 10                 mov     a0, (0x10, sp)
4841d120: dd 49 c4 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d127: 00                    clr     d0
4841d128: 42 10                 mov     d0, (0x10, sp)
4841d12a: fc cd b4 00 06 00     mov     0x000600b4, d1
4841d130: 8c                    mov     d3, d0
4841d131: dd 5c c2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d138: 00                    clr     d0
4841d139: df f0 24              ret     [d2,d3,a2,a3], 0x24
4841d13c: dd de 07 01 00 00 00  call    0x4842d91a, 0, 0
4841d143: 5e 34                 mov     (0x34, sp), a2
4841d145: 93                    mov     a0, a3
4841d146: 4b 10                 mov     a2, (0x10, sp)
4841d148: 8c                    mov     d3, d0
4841d149: fc cd 51 00 06 00     mov     0x00060051, d1
4841d14f: dd 3e c2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d156: a0 00                 cmp     0, d0
4841d158: c9 05                 bne     0x4841d15d
4841d15a: cc b3 00              jmp     0x4841d20d
4841d15d: 23 34                 add     0x34, a3
4841d15f: 73                    mov     (a3), d0
4841d160: a0 ff                 cmp     -1, d0
4841d162: c9 05                 bne     0x4841d167
4841d164: cc a9 00              jmp     0x4841d20d
4841d167: fc cc 35 00 04 00     mov     0x00040035, d0
4841d16d: 42 10                 mov     d0, (0x10, sp)
4841d16f: 8c                    mov     d3, d0
4841d170: fc cd 14 00 06 00     mov     0x00060014, d1
4841d176: dd 17 c2 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d17d: a0 01                 cmp     1, d0
4841d17f: c9 0e                 bne     0x4841d18d
4841d181: 73                    mov     (a3), d0
4841d182: 04                    clr     d1
4841d183: dd 71 e2 00 00 e0 20  call    0x4842b3f4, [d2,d3,a2], 0x20
4841d18a: cc 80 00              jmp     0x4841d20a
4841d18d: fc cc 46 00 04 00     mov     0x00040046, d0
4841d193: 42 10                 mov     d0, (0x10, sp)
4841d195: 8c                    mov     d3, d0
4841d196: fc cd 14 00 06 00     mov     0x00060014, d1
4841d19c: dd f1 c1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d1a3: a0 01                 cmp     1, d0
4841d1a5: c9 0d                 bne     0x4841d1b2
4841d1a7: 73                    mov     (a3), d0
4841d1a8: 04                    clr     d1
4841d1a9: dd 9f e1 00 00 e0 20  call    0x4842b348, [d2,d3,a2], 0x20
4841d1b0: ca 5a                 bra     0x4841d20a
4841d1b2: fc cc 47 00 04 00     mov     0x00040047, d0
4841d1b8: 42 10                 mov     d0, (0x10, sp)
4841d1ba: 8c                    mov     d3, d0
4841d1bb: fc cd 14 00 06 00     mov     0x00060014, d1
4841d1c1: dd cc c1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d1c8: a0 01                 cmp     1, d0
4841d1ca: c9 15                 bne     0x4841d1df
4841d1cc: 73                    mov     (a3), d0
4841d1cd: 04                    clr     d1
4841d1ce: 46 10                 mov     d1, (0x10, sp)
4841d1d0: fc cd 01 00 05 00     mov     0x00050001, d1
4841d1d6: dd b7 c1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d1dd: ca 2d                 bra     0x4841d20a
4841d1df: fc cc 48 00 04 00     mov     0x00040048, d0
4841d1e5: 42 10                 mov     d0, (0x10, sp)
4841d1e7: fc cd 14 00 06 00     mov     0x00060014, d1
4841d1ed: 8c                    mov     d3, d0
4841d1ee: dd 9f c1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d1f5: a0 01                 cmp     1, d0
4841d1f7: c9 13                 bne     0x4841d20a
4841d1f9: 73                    mov     (a3), d0
4841d1fa: 04                    clr     d1
4841d1fb: 46 10                 mov     d1, (0x10, sp)
4841d1fd: fc cd 01 00 05 00     mov     0x00050001, d1
4841d203: dd 8a c1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d20a: 00                    clr     d0
4841d20b: ca 3d                 bra     0x4841d248
4841d20d: 4b 10                 mov     a2, (0x10, sp)
4841d20f: 89                    mov     d2, d1
4841d210: 8c                    mov     d3, d0
4841d211: dd 58 c3 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d218: ca 30                 bra     0x4841d248
4841d21a: dd 00 07 01 00 00 00  call    0x4842d91a, 0, 0
4841d221: 91                    mov     a0, a1
4841d222: 5c 34                 mov     (0x34, sp), a0
4841d224: f8 25 30              mov     (0x30, a1), a1
4841d227: dd 2a 5e be 03 20 04  call    0x4c003051, [a2], 4
4841d22e: 00                    clr     d0
4841d22f: ca 19                 bra     0x4841d248
4841d231: dd e9 06 01 00 00 00  call    0x4842d91a, 0, 0
4841d238: f8 00 38              mov     (0x38, a0), d0
4841d23b: ca 0d                 bra     0x4841d248
4841d23d: 5c 34                 mov     (0x34, sp), a0
4841d23f: 43 10                 mov     a0, (0x10, sp)
4841d241: dd 28 c3 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d248: df f0 24              ret     [d2,d3,a2,a3], 0x24

VwMenuBoxProc:
4841d24b: cf 80                 movm    [d2], (sp)
4841d24d: f8 fe ec              add     -0x14, sp
4841d250: 82                    mov     d0, d2
4841d251: fc c9 b2 00 06 00     cmp     0x600b2, d1
4841d257: c8 14                 beq     0x4841d26b
4841d259: fc c9 3a 00 06 00     cmp     0x6003a, d1
4841d25f: c8 2b                 beq     0x4841d28a
4841d261: fc c9 b8 00 06 00     cmp     0x600b8, d1
4841d267: c8 3a                 beq     0x4841d2a1
4841d269: ca 44                 bra     0x4841d2ad
4841d26b: 5c 28                 mov     (0x28, sp), a0
4841d26d: 43 10                 mov     a0, (0x10, sp)
4841d26f: dd fa c2 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d276: 00                    clr     d0
4841d277: 42 10                 mov     d0, (0x10, sp)
4841d279: fc cd b4 00 06 00     mov     0x000600b4, d1
4841d27f: 88                    mov     d2, d0
4841d280: dd 0d c1 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d287: 00                    clr     d0
4841d288: ca 30                 bra     0x4841d2b8
4841d28a: dd 90 06 01 00 00 00  call    0x4842d91a, 0, 0
4841d291: 91                    mov     a0, a1
4841d292: 5c 28                 mov     (0x28, sp), a0
4841d294: f8 25 30              mov     (0x30, a1), a1
4841d297: dd ba 5d be 03 20 04  call    0x4c003051, [a2], 4
4841d29e: 00                    clr     d0
4841d29f: ca 19                 bra     0x4841d2b8
4841d2a1: dd 79 06 01 00 00 00  call    0x4842d91a, 0, 0
4841d2a8: f8 00 34              mov     (0x34, a0), d0
4841d2ab: ca 0d                 bra     0x4841d2b8
4841d2ad: 5c 28                 mov     (0x28, sp), a0
4841d2af: 43 10                 mov     a0, (0x10, sp)
4841d2b1: dd b8 c2 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d2b8: df 80 18              ret     [d2], 0x18

PsEditSwBoxProc:
4841d2bb: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841d2bd: f8 fe e0              add     -0x20, sp
4841d2c0: 82                    mov     d0, d2
4841d2c1: 87                    mov     d1, d3
4841d2c2: fc cb 3a 00 06 00     cmp     0x6003a, d3
4841d2c8: c2 05                 bge     0x4841d2cd
4841d2ca: cc c8 01              jmp     0x4841d492
4841d2cd: fc cb ef 00 06 00     cmp     0x600ef, d3
4841d2d3: c3 05                 ble     0x4841d2d8
4841d2d5: cc bd 01              jmp     0x4841d492
4841d2d8: fc dd b0 1f 5a 48     mov     0x485a1fb0, a1
4841d2de: 80 0f                 mov     0xf, d0
4841d2e0: fc cd c7 ff f9 ff     mov     0xfff9ffc7, d1
4841d2e6: ed                    add     d3, d1
4841d2e7: f2 04                 and     d1, d0
4841d2e9: f8 c0 03              asl     3, d0
4841d2ec: 94                    mov     a1, a0
4841d2ed: f1 60                 add     d0, a0
4841d2ef: 70                    mov     (a0), d0
4841d2f0: a4                    cmp     d1, d0
4841d2f1: c8 18                 beq     0x4841d309
4841d2f3: db                    setlb
4841d2f4: a0 00                 cmp     0, d0
4841d2f6: c9 05                 bne     0x4841d2fb
4841d2f8: cc 9a 01              jmp     0x4841d492
4841d2fb: 20 08                 add     8, a0
4841d2fd: fc d8 30 20 5a 48     cmp     0x485a2030, a0
4841d303: c4 03                 bcs     0x4841d306
4841d305: 94                    mov     a1, a0
4841d306: 70                    mov     (a0), d0
4841d307: a4                    cmp     d1, d0
4841d308: d9                    lne
4841d309: f8 20 04              mov     (4, a0), a0
4841d30c: f0 f4                 jmp     (a0)
4841d30e: 5c 40                 mov     (0x40, sp), a0
4841d310: 00                    clr     d0
4841d311: f0 50                 movbu   d0, (a0)
4841d313: df f0 30              ret     [d2,d3,a2,a3], 0x30
4841d316: 5c 40                 mov     (0x40, sp), a0
4841d318: 88                    mov     d2, d0
4841d319: 43 10                 mov     a0, (0x10, sp)
4841d31b: 8d                    mov     d3, d1
4841d31c: dd 4d c2 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d323: 88                    mov     d2, d0
4841d324: dd f6 05 01 00 00 00  call    0x4842d91a, 0, 0
4841d32b: 92                    mov     a0, a2
4841d32c: 22 28                 add     0x28, a2
4841d32e: f0 62                 movhu   (a2), d0
4841d330: 3c                    mov     sp, a0
4841d331: 20 14                 add     0x14, a0
4841d333: cd f4 a7 00 10        call    0x48417b27, 0, 0x10
4841d338: f8 bc 16              movhu   (0x16, sp), d0
4841d33b: 18                    exth    d0
4841d33c: fa c8 ef 00           cmp     0xef, d0
4841d340: c8 09                 beq     0x4841d349
4841d342: f0 62                 movhu   (a2), d0
4841d344: cd dc 04 f0 48        call    0x4841d820, [d2,d3,a2,a3], 0x48
4841d349: 00                    clr     d0
4841d34a: df f0 30              ret     [d2,d3,a2,a3], 0x30
4841d34d: 59 40                 mov     (0x40, sp), d1
4841d34f: 88                    mov     d2, d0
4841d350: 15                    extbu   d1
4841d351: cd 53 01 f0 10        call    0x4841d4a4, [d2,d3,a2,a3], 0x10
4841d356: 00                    clr     d0
4841d357: df f0 30              ret     [d2,d3,a2,a3], 0x30
4841d35a: 88                    mov     d2, d0
4841d35b: dd bf 05 01 00 00 00  call    0x4842d91a, 0, 0
4841d362: 92                    mov     a0, a2
4841d363: 88                    mov     d2, d0
4841d364: dd a5 00 01 00 00 0c  call    0x4842d409, 0, 0xc
4841d36b: a0 00                 cmp     0, d0
4841d36d: c8 24                 beq     0x4841d391
4841d36f: 5c 40                 mov     (0x40, sp), a0
4841d371: fc cc 24 00 0d 00     mov     0x000d0024, d0
4841d377: 43 10                 mov     a0, (0x10, sp)
4841d379: fc cd 29 00 06 00     mov     0x00060029, d1
4841d37f: dd 0e c0 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d386: f8 66 28              movhu   (0x28, a2), d1
4841d389: a1                    cmp     d0, d1
4841d38a: c9 07                 bne     0x4841d391
4841d38c: 80 01                 mov     1, d0
4841d38e: df f0 30              ret     [d2,d3,a2,a3], 0x30
4841d391: 00                    clr     d0
4841d392: df f0 30              ret     [d2,d3,a2,a3], 0x30
4841d395: 5c 40                 mov     (0x40, sp), a0
4841d397: 88                    mov     d2, d0
4841d398: 43 10                 mov     a0, (0x10, sp)
4841d39a: 8d                    mov     d3, d1
4841d39b: dd ce c1 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d3a2: 88                    mov     d2, d0
4841d3a3: dd 66 00 01 00 00 0c  call    0x4842d409, 0, 0xc
4841d3aa: a0 00                 cmp     0, d0
4841d3ac: c8 16                 beq     0x4841d3c2
4841d3ae: 80 01                 mov     1, d0
4841d3b0: 42 10                 mov     d0, (0x10, sp)
4841d3b2: fc cd 09 00 05 00     mov     0x00050009, d1
4841d3b8: 88                    mov     d2, d0
4841d3b9: dd d4 bf 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d3c0: ca 49                 bra     0x4841d409
4841d3c2: 88                    mov     d2, d0
4841d3c3: dd 57 05 01 00 00 00  call    0x4842d91a, 0, 0
4841d3ca: 92                    mov     a0, a2
4841d3cb: 3f                    mov     sp, a3
4841d3cc: 23 18                 add     0x18, a3
4841d3ce: 9c                    mov     a3, a0
4841d3cf: 88                    mov     d2, d0
4841d3d0: cd 22 9a 00 14        call    0x48416df2, 0, 0x14
4841d3d5: f8 62 28              movhu   (0x28, a2), d0
4841d3d8: 3c                    mov     sp, a0
4841d3d9: 20 14                 add     0x14, a0
4841d3db: cd 4c a7 00 10        call    0x48417b27, 0, 0x10
4841d3e0: f8 bc 16              movhu   (0x16, sp), d0
4841d3e3: 18                    exth    d0
4841d3e4: fa c8 ef 00           cmp     0xef, d0
4841d3e8: c8 18                 beq     0x4841d400
4841d3ea: f8 bc 14              movhu   (0x14, sp), d0
4841d3ed: 18                    exth    d0
4841d3ee: fa c8 7f 02           cmp     0x27f, d0
4841d3f2: c8 08                 beq     0x4841d3fa
4841d3f4: 00                    clr     d0
4841d3f5: f8 93 18              movhu   d0, (0x18, sp)
4841d3f8: ca 08                 bra     0x4841d400
4841d3fa: 2c 7f 02              mov     0x27f, d0
4841d3fd: f8 93 1c              movhu   d0, (0x1c, sp)
4841d400: 2c f5 00              mov     0xf5, d0
4841d403: 9c                    mov     a3, a0
4841d404: cd 2d 5c a0 18        call    0x48423031, [d2,a2], 0x18
4841d409: 00                    clr     d0
4841d40a: df f0 30              ret     [d2,d3,a2,a3], 0x30
4841d40d: 88                    mov     d2, d0
4841d40e: dd 0c 05 01 00 00 00  call    0x4842d91a, 0, 0
4841d415: f8 00 20              mov     (0x20, a0), d0
4841d418: df f0 30              ret     [d2,d3,a2,a3], 0x30
4841d41b: cd 31 49 00 00        call    0x48421d4c, 0, 0
4841d420: 1c                    exthu   d0
4841d421: a0 00                 cmp     0, d0
4841d423: c9 11                 bne     0x4841d434
4841d425: 88                    mov     d2, d0
4841d426: dd f4 04 01 00 00 00  call    0x4842d91a, 0, 0
4841d42d: f8 60 24              movhu   (0x24, a0), d0
4841d430: 18                    exth    d0
4841d431: df f0 30              ret     [d2,d3,a2,a3], 0x30
4841d434: 00                    clr     d0
4841d435: 42 10                 mov     d0, (0x10, sp)
4841d437: fc cd a3 00 06 00     mov     0x000600a3, d1
4841d43d: 88                    mov     d2, d0
4841d43e: dd 2b c1 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d445: ca 5a                 bra     0x4841d49f
4841d447: cd 05 49 00 00        call    0x48421d4c, 0, 0
4841d44c: 1c                    exthu   d0
4841d44d: a0 00                 cmp     0, d0
4841d44f: c9 11                 bne     0x4841d460
4841d451: 5c 40                 mov     (0x40, sp), a0
4841d453: 8d                    mov     d3, d1
4841d454: 43 10                 mov     a0, (0x10, sp)
4841d456: 88                    mov     d2, d0
4841d457: dd 12 c1 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d45e: ca 41                 bra     0x4841d49f
4841d460: 88                    mov     d2, d0
4841d461: dd b9 04 01 00 00 00  call    0x4842d91a, 0, 0
4841d468: f8 60 24              movhu   (0x24, a0), d0
4841d46b: 18                    exth    d0
4841d46c: ca 33                 bra     0x4841d49f
4841d46e: 88                    mov     d2, d0
4841d46f: dd ab 04 01 00 00 00  call    0x4842d91a, 0, 0
4841d476: f8 60 28              movhu   (0x28, a0), d0
4841d479: ca 26                 bra     0x4841d49f
4841d47b: 5e 40                 mov     (0x40, sp), a2
4841d47d: 88                    mov     d2, d0
4841d47e: 4b 10                 mov     a2, (0x10, sp)
4841d480: 8d                    mov     d3, d1
4841d481: dd e8 c0 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d488: 98                    mov     a2, a0
4841d489: 88                    mov     d2, d0
4841d48a: cd 4d 94 b0 1c        call    0x484168d7, [d2,a2,a3], 0x1c
4841d48f: 00                    clr     d0
4841d490: ca 0f                 bra     0x4841d49f
4841d492: 5c 40                 mov     (0x40, sp), a0
4841d494: 8d                    mov     d3, d1
4841d495: 43 10                 mov     a0, (0x10, sp)
4841d497: 88                    mov     d2, d0
4841d498: dd d1 c0 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d49f: df f0 30              ret     [d2,d3,a2,a3], 0x30
4841d4a2: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841d4a4: fa fe ac fe           add     -0x154, sp
4841d4a8: fa 96 70 01           movbu   d100, (0x170, sp)
4841d4ac: 83                    mov     d0, d3
4841d4ad: dd 6d 04 01 00 00 00  call    0x4842d91a, 0, 0
4841d4b4: 43 30                 mov     a0, (0x30, sp)
4841d4b6: 00                    clr     d0
4841d4b7: 42 10                 mov     d0, (0x10, sp)
4841d4b9: 8c                    mov     d3, d0
4841d4ba: fc cd af 00 06 00     mov     0x000600af, d1
4841d4c0: dd cd be 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d4c7: f1 e3                 mov     d0, a3
4841d4c9: 3c                    mov     sp, a0
4841d4ca: f1 d0                 mov     a0, d0
4841d4cc: 28 38                 add     0x38, d0
4841d4ce: 42 2c                 mov     d0, (0x2c, sp)
4841d4d0: 8c                    mov     d3, d0
4841d4d1: 5c 2c                 mov     (0x2c, sp), a0
4841d4d3: cd 12 96 00 14        call    0x48416ae5, 0, 0x14
4841d4d8: 3d                    mov     sp, a1
4841d4d9: 21 38                 add     0x38, a1
4841d4db: 3c                    mov     sp, a0
4841d4dc: 20 40                 add     0x40, a0
4841d4de: 85 fc                 mov     -4, d1
4841d4e0: db                    setlb
4841d4e1: f0 61                 movhu   (a1), d0
4841d4e3: 21 02                 add     2, a1
4841d4e5: f0 70                 movhu   d0, (a0)
4841d4e7: 20 02                 add     2, a0
4841d4e9: 44                    inc     d1
4841d4ea: d9                    lne
4841d4eb: f8 bc 38              movhu   (0x38, sp), d0
4841d4ee: 3c                    mov     sp, a0
4841d4ef: f8 93 48              movhu   d0, (0x48, sp)
4841d4f2: f8 bc 3c              movhu   (0x3c, sp), d0
4841d4f5: f1 d1                 mov     a0, d1
4841d4f7: 29 4c                 add     0x4c, d1
4841d4f9: 46 24                 mov     d1, (0x24, sp)
4841d4fb: f8 93 4c              movhu   d0, (0x4c, sp)
4841d4fe: f8 bc 3e              movhu   (0x3e, sp), d0
4841d501: f8 bd 3a              movhu   (0x3a, sp), d1
4841d504: f8 be 3a              movhu   (0x3a, sp), d2
4841d507: 18                    exth    d0
4841d508: 19                    exth    d1
4841d509: 1a                    exth    d2
4841d50a: f1 04                 sub     d1, d0
4841d50c: 85 02                 mov     2, d1
4841d50e: dd c7 44 be 03 00 00  call    0x4c0019d5, 0, 0
4841d515: e8                    add     d2, d0
4841d516: f8 93 4a              movhu   d0, (0x4a, sp)
4841d519: f8 93 4e              movhu   d0, (0x4e, sp)
4841d51c: 00                    clr     d0
4841d51d: 42 10                 mov     d0, (0x10, sp)
4841d51f: 8c                    mov     d3, d0
4841d520: fc cd ae 00 06 00     mov     0x000600ae, d1
4841d526: dd 67 be 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d52d: f8 93 34              movhu   d0, (0x34, sp)
4841d530: 00                    clr     d0
4841d531: 42 10                 mov     d0, (0x10, sp)
4841d533: 8c                    mov     d3, d0
4841d534: fc cd a3 00 06 00     mov     0x000600a3, d1
4841d53a: dd 53 be 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d541: 82                    mov     d0, d2
4841d542: 3c                    mov     sp, a0
4841d543: f1 d0                 mov     a0, d0
4841d545: 28 50                 add     0x50, d0
4841d547: 42 28                 mov     d0, (0x28, sp)
4841d549: 5c 2c                 mov     (0x2c, sp), a0
4841d54b: f1 e1                 mov     d0, a1
4841d54d: cd e6 98 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841d552: fa b8 70 01           movbu   (0x170, sp), d0
4841d556: 3e                    mov     sp, a2
4841d557: 22 48                 add     0x48, a2
4841d559: a0 03                 cmp     3, d0
4841d55b: c8 13                 beq     0x4841d56e
4841d55d: a0 0e                 cmp     0xe, d0
4841d55f: c9 05                 bne     0x4841d564
4841d561: cc 81 00              jmp     0x4841d5e2
4841d564: a0 0b                 cmp     0xb, d0
4841d566: c9 05                 bne     0x4841d56b
4841d568: cc ee 00              jmp     0x4841d656
4841d56b: cc 5a 01              jmp     0x4841d6c5
4841d56e: 8c                    mov     d3, d0
4841d56f: cd 01 99 00 08        call    0x48416e70, 0, 8
4841d574: 5d 24                 mov     (0x24, sp), a1
4841d576: 18                    exth    d0
4841d577: 98                    mov     a2, a0
4841d578: cd 21 53 b0 20        call    0x48422899, [d2,a2,a3], 0x20
4841d57d: f8 bc 4a              movhu   (0x4a, sp), d0
4841d580: 3e                    mov     sp, a2
4841d581: 18                    exth    d0
4841d582: 22 40                 add     0x40, a2
4841d584: 28 ff                 add     -1, d0
4841d586: f8 93 46              movhu   d0, (0x46, sp)
4841d589: 3f                    mov     sp, a3
4841d58a: 23 54                 add     0x54, a3
4841d58c: 98                    mov     a2, a0
4841d58d: 2c 9b 00              mov     0x9b, d0
4841d590: f8 92 54              movbu   d0, (0x54, sp)
4841d593: 00                    clr     d0
4841d594: f8 92 55              movbu   d0, (0x55, sp)
4841d597: 5d 28                 mov     (0x28, sp), a1
4841d599: cd 9a 98 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841d59e: 4f 10                 mov     a3, (0x10, sp)
4841d5a0: f8 bf 34              movhu   (0x34, sp), d3
4841d5a3: 1a                    exth    d2
4841d5a4: 1b                    exth    d3
4841d5a5: 4a 1c                 mov     d2, (0x1c, sp)
4841d5a7: 98                    mov     a2, a0
4841d5a8: 5d 28                 mov     (0x28, sp), a1
4841d5aa: 8d                    mov     d3, d1
4841d5ab: 00                    clr     d0
4841d5ac: dd ec 82 00 00 f0 10  call    0x48425898, [d2,d3,a2,a3], 0x10
4841d5b3: f8 bc 4a              movhu   (0x4a, sp), d0
4841d5b6: 98                    mov     a2, a0
4841d5b7: 18                    exth    d0
4841d5b8: 40                    inc     d0
4841d5b9: f8 93 42              movhu   d0, (0x42, sp)
4841d5bc: f8 bc 3e              movhu   (0x3e, sp), d0
4841d5bf: f8 93 46              movhu   d0, (0x46, sp)
4841d5c2: 2c 98 00              mov     0x98, d0
4841d5c5: f8 92 54              movbu   d0, (0x54, sp)
4841d5c8: 5d 28                 mov     (0x28, sp), a1
4841d5ca: cd 69 98 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841d5cf: 4f 10                 mov     a3, (0x10, sp)
4841d5d1: 4a 1c                 mov     d2, (0x1c, sp)
4841d5d3: 5d 28                 mov     (0x28, sp), a1
4841d5d5: 8d                    mov     d3, d1
4841d5d6: 98                    mov     a2, a0
4841d5d7: 00                    clr     d0
4841d5d8: dd c0 82 00 00 f0 10  call    0x48425898, [d2,d3,a2,a3], 0x10
4841d5df: cc 35 02              jmp     0x4841d814
4841d5e2: 8c                    mov     d3, d0
4841d5e3: cd 8d 98 00 08        call    0x48416e70, 0, 8
4841d5e8: 5d 24                 mov     (0x24, sp), a1
4841d5ea: 18                    exth    d0
4841d5eb: 98                    mov     a2, a0
4841d5ec: cd ad 52 b0 20        call    0x48422899, [d2,a2,a3], 0x20
4841d5f1: f8 bc 4a              movhu   (0x4a, sp), d0
4841d5f4: 3e                    mov     sp, a2
4841d5f5: 18                    exth    d0
4841d5f6: 22 40                 add     0x40, a2
4841d5f8: 28 ff                 add     -1, d0
4841d5fa: f8 93 46              movhu   d0, (0x46, sp)
4841d5fd: 3f                    mov     sp, a3
4841d5fe: 23 54                 add     0x54, a3
4841d600: 98                    mov     a2, a0
4841d601: 2c 85 00              mov     0x85, d0
4841d604: f8 92 54              movbu   d0, (0x54, sp)
4841d607: 00                    clr     d0
4841d608: f8 92 55              movbu   d0, (0x55, sp)
4841d60b: 5d 28                 mov     (0x28, sp), a1
4841d60d: cd 26 98 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841d612: 4f 10                 mov     a3, (0x10, sp)
4841d614: f8 bf 34              movhu   (0x34, sp), d3
4841d617: 1a                    exth    d2
4841d618: 1b                    exth    d3
4841d619: 4a 1c                 mov     d2, (0x1c, sp)
4841d61b: 98                    mov     a2, a0
4841d61c: 5d 28                 mov     (0x28, sp), a1
4841d61e: 8d                    mov     d3, d1
4841d61f: 00                    clr     d0
4841d620: dd 78 82 00 00 f0 10  call    0x48425898, [d2,d3,a2,a3], 0x10
4841d627: f8 bc 4a              movhu   (0x4a, sp), d0
4841d62a: 98                    mov     a2, a0
4841d62b: 18                    exth    d0
4841d62c: 40                    inc     d0
4841d62d: f8 93 42              movhu   d0, (0x42, sp)
4841d630: f8 bc 3e              movhu   (0x3e, sp), d0
4841d633: f8 93 46              movhu   d0, (0x46, sp)
4841d636: 2c 81 00              mov     0x81, d0
4841d639: f8 92 54              movbu   d0, (0x54, sp)
4841d63c: 5d 28                 mov     (0x28, sp), a1
4841d63e: cd f5 97 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841d643: 4f 10                 mov     a3, (0x10, sp)
4841d645: 4a 1c                 mov     d2, (0x1c, sp)
4841d647: 5d 28                 mov     (0x28, sp), a1
4841d649: 8d                    mov     d3, d1
4841d64a: 98                    mov     a2, a0
4841d64b: 00                    clr     d0
4841d64c: dd 4c 82 00 00 f0 10  call    0x48425898, [d2,d3,a2,a3], 0x10
4841d653: cc c1 01              jmp     0x4841d814
4841d656: 8c                    mov     d3, d0
4841d657: cd 19 98 00 08        call    0x48416e70, 0, 8
4841d65c: 5d 24                 mov     (0x24, sp), a1
4841d65e: 18                    exth    d0
4841d65f: 98                    mov     a2, a0
4841d660: cd 39 52 b0 20        call    0x48422899, [d2,a2,a3], 0x20
4841d665: f8 bc 4a              movhu   (0x4a, sp), d0
4841d668: 3e                    mov     sp, a2
4841d669: 18                    exth    d0
4841d66a: 22 40                 add     0x40, a2
4841d66c: 28 ff                 add     -1, d0
4841d66e: f8 93 46              movhu   d0, (0x46, sp)
4841d671: 98                    mov     a2, a0
4841d672: 5d 28                 mov     (0x28, sp), a1
4841d674: cd bf 97 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841d679: fc cc c4 f1 59 48     mov     0x4859f1c4, d0
4841d67f: 42 10                 mov     d0, (0x10, sp)
4841d681: f8 bf 34              movhu   (0x34, sp), d3
4841d684: 1a                    exth    d2
4841d685: 1b                    exth    d3
4841d686: 4a 1c                 mov     d2, (0x1c, sp)
4841d688: 98                    mov     a2, a0
4841d689: 5d 28                 mov     (0x28, sp), a1
4841d68b: f1 dc                 mov     a3, d0
4841d68d: 8d                    mov     d3, d1
4841d68e: dd 0a 82 00 00 f0 10  call    0x48425898, [d2,d3,a2,a3], 0x10
4841d695: f8 bc 4a              movhu   (0x4a, sp), d0
4841d698: 98                    mov     a2, a0
4841d699: 18                    exth    d0
4841d69a: 40                    inc     d0
4841d69b: f8 93 42              movhu   d0, (0x42, sp)
4841d69e: f8 bc 3e              movhu   (0x3e, sp), d0
4841d6a1: f8 93 46              movhu   d0, (0x46, sp)
4841d6a4: 5d 28                 mov     (0x28, sp), a1
4841d6a6: cd 8d 97 f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841d6ab: 98                    mov     a2, a0
4841d6ac: 8d                    mov     d3, d1
4841d6ad: fc cc c8 f1 59 48     mov     0x4859f1c8, d0
4841d6b3: 42 10                 mov     d0, (0x10, sp)
4841d6b5: 4a 1c                 mov     d2, (0x1c, sp)
4841d6b7: 5d 28                 mov     (0x28, sp), a1
4841d6b9: f1 dc                 mov     a3, d0

DrawEditSw:
4841d81b: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841d81d: f8 fe c8              add     -0x38, sp
4841d820: 1c                    exthu   d0
4841d821: fa c8 ff 00           cmp     0xff, d0
4841d825: c9 05                 bne     0x4841d82a
4841d827: df f0 48              ret     [d2,d3,a2,a3], 0x48
4841d82a: a0 17                 cmp     0x17, d0
4841d82c: c9 05                 bne     0x4841d831
4841d82e: df f0 48              ret     [d2,d3,a2,a3], 0x48
4841d831: 3c                    mov     sp, a0
4841d832: f1 d1                 mov     a0, d1
4841d834: 29 24                 add     0x24, d1
4841d836: 46 20                 mov     d1, (0x20, sp)
4841d838: f1 e4                 mov     d1, a0
4841d83a: cd ed a2 00 10        call    0x48417b27, 0, 0x10
4841d83f: f8 bc 26              movhu   (0x26, sp), d0
4841d842: 18                    exth    d0
4841d843: fa c8 ef 00           cmp     0xef, d0
4841d847: c8 30                 beq     0x4841d877
4841d849: f8 bc 24              movhu   (0x24, sp), d0
4841d84c: 18                    exth    d0
4841d84d: a0 00                 cmp     0, d0
4841d84f: c9 15                 bne     0x4841d864
4841d851: 3e                    mov     sp, a2
4841d852: 22 28                 add     0x28, a2
4841d854: 98                    mov     a2, a0
4841d855: fc dd 00 f2 59 48     mov     0x4859f200, a1
4841d85b: dd f6 57 be 03 20 04  call    0x4c003051, [a2], 4
4841d862: ca 26                 bra     0x4841d888
4841d864: 3e                    mov     sp, a2
4841d865: 22 28                 add     0x28, a2
4841d867: 98                    mov     a2, a0
4841d868: fc dd 04 f2 59 48     mov     0x4859f204, a1
4841d86e: dd e3 57 be 03 20 04  call    0x4c003051, [a2], 4
4841d875: ca 13                 bra     0x4841d888
4841d877: 3e                    mov     sp, a2
4841d878: 22 28                 add     0x28, a2
4841d87a: 98                    mov     a2, a0
4841d87b: fc dd 08 f2 59 48     mov     0x4859f208, a1
4841d881: dd d0 57 be 03 20 04  call    0x4c003051, [a2], 4
4841d888: 98                    mov     a2, a0
4841d889: 00                    clr     d0
4841d88a: dd 36 08 01 00 f0 24  call    0x4842e0c0, [d2,d3,a2,a3], 0x24
4841d891: f1 e3                 mov     d0, a3
4841d893: 00                    clr     d0
4841d894: dd cc 06 01 00 00 00  call    0x4842df60, 0, 0
4841d89b: 83                    mov     d0, d3
4841d89c: f8 bc 24              movhu   (0x24, sp), d0
4841d89f: 18                    exth    d0
4841d8a0: a0 00                 cmp     0, d0
4841d8a2: c9 1b                 bne     0x4841d8bd
4841d8a4: 80 fe                 mov     -2, d0
4841d8a6: f8 93 30              movhu   d0, (0x30, sp)
4841d8a9: f8 be 26              movhu   (0x26, sp), d2
4841d8ac: 8c                    mov     d3, d0
4841d8ad: 1a                    exth    d2
4841d8ae: 18                    exth    d0
4841d8af: 85 02                 mov     2, d1
4841d8b1: dd 24 41 be 03 00 00  call    0x4c0019d5, 0, 0
4841d8b8: f1 02                 sub     d0, d2
4841d8ba: f8 9b 32              movhu   d2, (0x32, sp)
4841d8bd: f8 bc 24              movhu   (0x24, sp), d0
4841d8c0: 18                    exth    d0
4841d8c1: fa c8 7f 02           cmp     0x27f, d0
4841d8c5: c9 23                 bne     0x4841d8e8
4841d8c7: f1 dd                 mov     a3, d1
4841d8c9: 19                    exth    d1
4841d8ca: 2c 80 02              mov     0x280, d0
4841d8cd: f1 04                 sub     d1, d0
4841d8cf: 28 fe                 add     -2, d0
4841d8d1: f8 93 30              movhu   d0, (0x30, sp)
4841d8d4: f8 be 26              movhu   (0x26, sp), d2
4841d8d7: 8c                    mov     d3, d0
4841d8d8: 1a                    exth    d2
4841d8d9: 18                    exth    d0
4841d8da: 85 02                 mov     2, d1
4841d8dc: dd f9 40 be 03 00 00  call    0x4c0019d5, 0, 0
4841d8e3: f1 02                 sub     d0, d2
4841d8e5: f8 9b 32              movhu   d2, (0x32, sp)
4841d8e8: f8 bc 26              movhu   (0x26, sp), d0
4841d8eb: 18                    exth    d0
4841d8ec: fa c8 ef 00           cmp     0xef, d0
4841d8f0: c9 25                 bne     0x4841d915
4841d8f2: f8 be 24              movhu   (0x24, sp), d2
4841d8f5: f1 dc                 mov     a3, d0
4841d8f7: 1a                    exth    d2
4841d8f8: 18                    exth    d0
4841d8f9: 85 02                 mov     2, d1
4841d8fb: dd da 40 be 03 00 00  call    0x4c0019d5, 0, 0
4841d902: f1 02                 sub     d0, d2
4841d904: 2a ff                 add     -1, d2
4841d906: f8 9b 30              movhu   d2, (0x30, sp)
4841d909: 8c                    mov     d3, d0
4841d90a: 18                    exth    d0
4841d90b: 2d f0 00              mov     0xf0, d1
4841d90e: f1 01                 sub     d0, d1
4841d910: 29 05                 add     5, d1
4841d912: f8 97 32              movhu   d1, (0x32, sp)
4841d915: f8 bc 30              movhu   (0x30, sp), d0
4841d918: 1b                    exth    d3
4841d919: 18                    exth    d0
4841d91a: 28 02                 add     2, d0
4841d91c: f8 93 24              movhu   d0, (0x24, sp)
4841d91f: f8 bc 32              movhu   (0x32, sp), d0
4841d922: 3c                    mov     sp, a0
4841d923: 18                    exth    d0
4841d924: 40                    inc     d0
4841d925: f8 93 26              movhu   d0, (0x26, sp)
4841d928: f8 bd 30              movhu   (0x30, sp), d1
4841d92b: f1 dc                 mov     a3, d0
4841d92d: 19                    exth    d1
4841d92e: 18                    exth    d0
4841d92f: e4                    add     d1, d0
4841d930: 40                    inc     d0
4841d931: f8 93 34              movhu   d0, (0x34, sp)
4841d934: f8 bd 32              movhu   (0x32, sp), d1
4841d937: 20 30                 add     0x30, a0
4841d939: 19                    exth    d1
4841d93a: e7                    add     d1, d3
4841d93b: f8 9f 36              movhu   d3, (0x36, sp)
4841d93e: 4b 10                 mov     a2, (0x10, sp)
4841d940: 2c f7 00              mov     0xf7, d0
4841d943: 42 1c                 mov     d0, (0x1c, sp)
4841d945: 5d 20                 mov     (0x20, sp), a1
4841d947: 00                    clr     d0
4841d948: 85 1c                 mov     0x1c, d1
4841d94a: cd 4e 7a f0 30        call    0x48425398, [d2,d3,a2,a3], 0x30
4841d94f: df f0 48              ret     [d2,d3,a2,a3], 0x48

PsWideESBoxProc:
4841d952: cf c0                 movm    [d2,d3], (sp)
4841d954: f8 fe ec              add     -0x14, sp
4841d957: fc c9 51 00 06 00     cmp     0x60051, d1
4841d95d: c9 47                 bne     0x4841d9a4
4841d95f: dd bb ff 00 00 00 00  call    0x4842d91a, 0, 0
4841d966: 95 28                 mov     0x28, a1
4841d968: f1 71                 add     a0, a1
4841d96a: f0 65                 movhu   (a1), d1
4841d96c: 20 2c                 add     0x2c, a0
4841d96e: f0 60                 movhu   (a0), d0
4841d970: a1                    cmp     d0, d1
4841d971: c2 08                 bge     0x4841d979
4841d973: f0 69                 movhu   (a1), d2
4841d975: f0 6c                 movhu   (a0), d3
4841d977: ca 06                 bra     0x4841d97d
4841d979: f0 68                 movhu   (a0), d2
4841d97b: f0 6d                 movhu   (a1), d3
4841d97d: 5c 2c                 mov     (0x2c, sp), a0
4841d97f: 1e                    exthu   d2
4841d980: 43 10                 mov     a0, (0x10, sp)
4841d982: fc cc 24 00 0d 00     mov     0x000d0024, d0
4841d988: fc cd 29 00 06 00     mov     0x00060029, d1
4841d98e: dd ff b9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d995: 1c                    exthu   d0
4841d996: a8                    cmp     d2, d0
4841d997: c0 0a                 blt     0x4841d9a1
4841d999: 1f                    exthu   d3
4841d99a: ac                    cmp     d3, d0
4841d99b: c1 06                 bgt     0x4841d9a1
4841d99d: 80 01                 mov     1, d0
4841d99f: ca 10                 bra     0x4841d9af
4841d9a1: 00                    clr     d0
4841d9a2: ca 0d                 bra     0x4841d9af
4841d9a4: 5c 2c                 mov     (0x2c, sp), a0
4841d9a6: 43 10                 mov     a0, (0x10, sp)
4841d9a8: dd c1 bb 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d9af: df c0 1c              ret     [d2,d3], 0x1c

AcIndexEditSwProc:
4841d9b2: cf e0                 movm    [d2,d3,a2], (sp)
4841d9b4: f8 fe ec              add     -0x14, sp
4841d9b7: 82                    mov     d0, d2
4841d9b8: 87                    mov     d1, d3
4841d9b9: fc cb b2 00 06 00     cmp     0x600b2, d3
4841d9bf: c8 18                 beq     0x4841d9d7
4841d9c1: fc cb 05 00 05 00     cmp     0x50005, d3
4841d9c7: c8 73                 beq     0x4841da3a
4841d9c9: fc cb 28 00 05 00     cmp     0x50028, d3
4841d9cf: c9 05                 bne     0x4841d9d4
4841d9d1: cc 5a 01              jmp     0x4841db2b
4841d9d4: cc db 01              jmp     0x4841dbaf
4841d9d7: 5c 30                 mov     (0x30, sp), a0
4841d9d9: 88                    mov     d2, d0
4841d9da: 43 10                 mov     a0, (0x10, sp)
4841d9dc: 8d                    mov     d3, d1
4841d9dd: dd 8c bb 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841d9e4: fc cc 38 00 04 00     mov     0x00040038, d0
4841d9ea: 42 10                 mov     d0, (0x10, sp)
4841d9ec: fc cd 14 00 06 00     mov     0x00060014, d1
4841d9f2: 88                    mov     d2, d0
4841d9f3: dd 9a b9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841d9fa: a0 00                 cmp     0, d0
4841d9fc: c8 1f                 beq     0x4841da1b
4841d9fe: 88                    mov     d2, d0
4841d9ff: dd 1b ff 00 00 00 00  call    0x4842d91a, 0, 0
4841da06: f8 40 30              movbu   (0x30, a0), d0
4841da09: fc cd b4 00 06 00     mov     0x000600b4, d1
4841da0f: 42 10                 mov     d0, (0x10, sp)
4841da11: 88                    mov     d2, d0
4841da12: dd 7b b9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841da19: ca 1d                 bra     0x4841da36
4841da1b: 88                    mov     d2, d0
4841da1c: dd fe fe 00 00 00 00  call    0x4842d91a, 0, 0
4841da23: f8 40 2c              movbu   (0x2c, a0), d0
4841da26: fc cd b4 00 06 00     mov     0x000600b4, d1
4841da2c: 42 10                 mov     d0, (0x10, sp)
4841da2e: 88                    mov     d2, d0
4841da2f: dd 5e b9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841da36: 00                    clr     d0
4841da37: df e0 20              ret     [d2,d3,a2], 0x20
4841da3a: 88                    mov     d2, d0
4841da3b: dd ce f9 00 00 00 0c  call    0x4842d409, 0, 0xc
4841da42: a0 00                 cmp     0, d0
4841da44: c9 05                 bne     0x4841da49
4841da46: cc d5 00              jmp     0x4841db1b
4841da49: 5e 30                 mov     (0x30, sp), a2
4841da4b: 88                    mov     d2, d0
4841da4c: 4b 10                 mov     a2, (0x10, sp)
4841da4e: fc cd 51 00 06 00     mov     0x00060051, d1
4841da54: dd 39 b9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841da5b: a0 00                 cmp     0, d0
4841da5d: c9 05                 bne     0x4841da62
4841da5f: cc bc 00              jmp     0x4841db1b
4841da62: 00                    clr     d0
4841da63: 42 10                 mov     d0, (0x10, sp)
4841da65: 88                    mov     d2, d0
4841da66: fc cd 4e 00 06 00     mov     0x0006004e, d1
4841da6c: dd 21 b9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841da73: 83                    mov     d0, d3
4841da74: 18                    exth    d0
4841da75: a0 ff                 cmp     -1, d0
4841da77: c9 05                 bne     0x4841da7c
4841da79: cc 9e 00              jmp     0x4841db17
4841da7c: fc cc 38 00 04 00     mov     0x00040038, d0
4841da82: 42 10                 mov     d0, (0x10, sp)
4841da84: 88                    mov     d2, d0
4841da85: fc cd 14 00 06 00     mov     0x00060014, d1
4841da8b: dd 02 b9 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841da92: a0 00                 cmp     0, d0
4841da94: c8 0f                 beq     0x4841daa3
4841da96: 88                    mov     d2, d0
4841da97: dd 83 fe 00 00 00 00  call    0x4842d91a, 0, 0
4841da9e: f8 40 30              movbu   (0x30, a0), d0
4841daa1: ca 0d                 bra     0x4841daae
4841daa3: 88                    mov     d2, d0
4841daa4: dd 76 fe 00 00 00 00  call    0x4842d91a, 0, 0
4841daab: f8 40 2c              movbu   (0x2c, a0), d0
4841daae: 14                    extbu   d0
4841daaf: a0 00                 cmp     0, d0
4841dab1: c0 66                 blt     0x4841db17
4841dab3: a0 10                 cmp     0x10, d0
4841dab5: c1 62                 bgt     0x4841db17
4841dab7: 54                    asl2    d0
4841dab8: fc dc 74 20 5a 48     mov     0x485a2074, a0
4841dabe: f3 80                 mov     (d0, a0), a0
4841dac0: f0 f4                 jmp     (a0)
4841dac2: f1 d8                 mov     a2, d0
4841dac4: f8 e0 80              and     0x80, d0
4841dac7: c8 16                 beq     0x4841dadd
4841dac9: 1b                    exth    d3
4841daca: 4e 10                 mov     d3, (0x10, sp)
4841dacc: 80 ff                 mov     -1, d0
4841dace: fc cd 10 00 05 00     mov     0x00050010, d1
4841dad4: dd b9 b8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dadb: ca 3c                 bra     0x4841db17
4841dadd: 1b                    exth    d3
4841dade: 4e 10                 mov     d3, (0x10, sp)
4841dae0: 80 ff                 mov     -1, d0
4841dae2: fc cd 0f 00 05 00     mov     0x0005000f, d1
4841dae8: dd a5 b8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841daef: ca 28                 bra     0x4841db17
4841daf1: 1b                    exth    d3
4841daf2: 4e 10                 mov     d3, (0x10, sp)
4841daf4: 80 ff                 mov     -1, d0
4841daf6: fc cd 0f 00 05 00     mov     0x0005000f, d1
4841dafc: dd 91 b8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841db03: ca 14                 bra     0x4841db17
4841db05: 1b                    exth    d3
4841db06: 4e 10                 mov     d3, (0x10, sp)
4841db08: 80 ff                 mov     -1, d0
4841db0a: fc cd 10 00 05 00     mov     0x00050010, d1
4841db10: dd 7d b8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841db17: 00                    clr     d0
4841db18: df e0 20              ret     [d2,d3,a2], 0x20
4841db1b: 5c 30                 mov     (0x30, sp), a0
4841db1d: 8d                    mov     d3, d1
4841db1e: 43 10                 mov     a0, (0x10, sp)
4841db20: 88                    mov     d2, d0
4841db21: dd 48 ba 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841db28: df e0 20              ret     [d2,d3,a2], 0x20
4841db2b: 88                    mov     d2, d0
4841db2c: dd dd f8 00 00 00 0c  call    0x4842d409, 0, 0xc
4841db33: a0 00                 cmp     0, d0
4841db35: c8 6b                 beq     0x4841dba0
4841db37: 5e 30                 mov     (0x30, sp), a2
4841db39: 88                    mov     d2, d0
4841db3a: 4b 10                 mov     a2, (0x10, sp)
4841db3c: fc cd 51 00 06 00     mov     0x00060051, d1
4841db42: dd 4b b8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841db49: a0 00                 cmp     0, d0
4841db4b: c8 55                 beq     0x4841dba0
4841db4d: 00                    clr     d0
4841db4e: 42 10                 mov     d0, (0x10, sp)
4841db50: fc cd 4e 00 06 00     mov     0x0006004e, d1
4841db56: 88                    mov     d2, d0
4841db57: dd 36 b8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841db5e: 82                    mov     d0, d2
4841db5f: 18                    exth    d0
4841db60: a0 ff                 cmp     -1, d0
4841db62: c8 3b                 beq     0x4841db9d
4841db64: 4b 10                 mov     a2, (0x10, sp)
4841db66: 80 ff                 mov     -1, d0
4841db68: fc cd 07 00 05 00     mov     0x00050007, d1
4841db6e: dd 1f b8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841db75: f1 d8                 mov     a2, d0
4841db77: f8 e4 80              or      0x80, d0
4841db7a: 42 10                 mov     d0, (0x10, sp)
4841db7c: 80 ff                 mov     -1, d0
4841db7e: fc cd 07 00 05 00     mov     0x00050007, d1
4841db84: dd 09 b8 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841db8b: 1a                    exth    d2
4841db8c: 4a 10                 mov     d2, (0x10, sp)
4841db8e: 80 ff                 mov     -1, d0
4841db90: fc cd 29 00 05 00     mov     0x00050029, d1
4841db96: dd f7 b7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841db9d: 00                    clr     d0
4841db9e: ca 1e                 bra     0x4841dbbc
4841dba0: 5c 30                 mov     (0x30, sp), a0
4841dba2: 8d                    mov     d3, d1
4841dba3: 43 10                 mov     a0, (0x10, sp)
4841dba5: 88                    mov     d2, d0
4841dba6: dd c3 b9 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841dbad: ca 0f                 bra     0x4841dbbc
4841dbaf: 5c 30                 mov     (0x30, sp), a0
4841dbb1: 8d                    mov     d3, d1
4841dbb2: 43 10                 mov     a0, (0x10, sp)
4841dbb4: 88                    mov     d2, d0
4841dbb5: dd b4 b9 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841dbbc: df e0 20              ret     [d2,d3,a2], 0x20

AcFuncEditSwProc:
4841dbbf: cf e0                 movm    [d2,d3,a2], (sp)
4841dbc1: f8 fe ec              add     -0x14, sp
4841dbc4: 82                    mov     d0, d2
4841dbc5: 87                    mov     d1, d3
4841dbc6: fc cb b2 00 06 00     cmp     0x600b2, d3
4841dbcc: c8 0d                 beq     0x4841dbd9
4841dbce: fc cb 05 00 05 00     cmp     0x50005, d3
4841dbd4: c8 66                 beq     0x4841dc3a
4841dbd6: cc dd 00              jmp     0x4841dcb3
4841dbd9: 5c 30                 mov     (0x30, sp), a0
4841dbdb: 43 10                 mov     a0, (0x10, sp)
4841dbdd: dd 8c b9 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841dbe4: fc cc 38 00 04 00     mov     0x00040038, d0
4841dbea: 42 10                 mov     d0, (0x10, sp)
4841dbec: fc cd 14 00 06 00     mov     0x00060014, d1
4841dbf2: 88                    mov     d2, d0
4841dbf3: dd 9a b7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dbfa: a0 00                 cmp     0, d0
4841dbfc: c8 1f                 beq     0x4841dc1b
4841dbfe: 88                    mov     d2, d0
4841dbff: dd 1b fd 00 00 00 00  call    0x4842d91a, 0, 0
4841dc06: f8 40 30              movbu   (0x30, a0), d0
4841dc09: fc cd b4 00 06 00     mov     0x000600b4, d1
4841dc0f: 42 10                 mov     d0, (0x10, sp)
4841dc11: 88                    mov     d2, d0
4841dc12: dd 7b b7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dc19: ca 1d                 bra     0x4841dc36
4841dc1b: 88                    mov     d2, d0
4841dc1c: dd fe fc 00 00 00 00  call    0x4842d91a, 0, 0
4841dc23: f8 40 2c              movbu   (0x2c, a0), d0
4841dc26: fc cd b4 00 06 00     mov     0x000600b4, d1
4841dc2c: 42 10                 mov     d0, (0x10, sp)
4841dc2e: 88                    mov     d2, d0
4841dc2f: dd 5e b7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dc36: 00                    clr     d0
4841dc37: df e0 20              ret     [d2,d3,a2], 0x20
4841dc3a: dd cf f7 00 00 00 0c  call    0x4842d409, 0, 0xc
4841dc41: a0 00                 cmp     0, d0
4841dc43: c8 61                 beq     0x4841dca4
4841dc45: 5e 30                 mov     (0x30, sp), a2
4841dc47: 88                    mov     d2, d0
4841dc48: 4b 10                 mov     a2, (0x10, sp)
4841dc4a: fc cd 51 00 06 00     mov     0x00060051, d1
4841dc50: dd 3d b7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dc57: a0 00                 cmp     0, d0
4841dc59: c8 4b                 beq     0x4841dca4
4841dc5b: fc cc 38 00 04 00     mov     0x00040038, d0
4841dc61: 42 10                 mov     d0, (0x10, sp)
4841dc63: 88                    mov     d2, d0
4841dc64: fc cd 14 00 06 00     mov     0x00060014, d1
4841dc6a: dd 23 b7 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dc71: a0 00                 cmp     0, d0
4841dc73: c8 19                 beq     0x4841dc8c
4841dc75: 88                    mov     d2, d0
4841dc76: dd a4 fc 00 00 00 00  call    0x4842d91a, 0, 0
4841dc7d: f8 00 34              mov     (0x34, a0), d0
4841dc80: 4b 10                 mov     a2, (0x10, sp)
4841dc82: 8d                    mov     d3, d1
4841dc83: dd fd cf 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841dc8a: ca 17                 bra     0x4841dca1
4841dc8c: 88                    mov     d2, d0
4841dc8d: dd 8d fc 00 00 00 00  call    0x4842d91a, 0, 0
4841dc94: f8 00 30              mov     (0x30, a0), d0
4841dc97: 4b 10                 mov     a2, (0x10, sp)
4841dc99: 8d                    mov     d3, d1
4841dc9a: dd e6 cf 00 00 e0 24  call    0x4842ac80, [d2,d3,a2], 0x24
4841dca1: 00                    clr     d0
4841dca2: ca 1c                 bra     0x4841dcbe
4841dca4: 5c 30                 mov     (0x30, sp), a0
4841dca6: 8d                    mov     d3, d1
4841dca7: 43 10                 mov     a0, (0x10, sp)
4841dca9: 88                    mov     d2, d0
4841dcaa: dd bf b8 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841dcb1: ca 0d                 bra     0x4841dcbe
4841dcb3: 5c 30                 mov     (0x30, sp), a0
4841dcb5: 43 10                 mov     a0, (0x10, sp)
4841dcb7: dd b2 b8 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841dcbe: df e0 20              ret     [d2,d3,a2], 0x20

VwEditSwBoxProc:
4841dcc1: cf a0                 movm    [d2,a2], (sp)
4841dcc3: f8 fe ec              add     -0x14, sp
4841dcc6: 82                    mov     d0, d2
4841dcc7: fc c9 b2 00 06 00     cmp     0x600b2, d1
4841dccd: c8 0d                 beq     0x4841dcda
4841dccf: fc c9 3a 00 06 00     cmp     0x6003a, d1
4841dcd5: c8 65                 beq     0x4841dd3a
4841dcd7: cc ab 00              jmp     0x4841dd82
4841dcda: 5c 2c                 mov     (0x2c, sp), a0
4841dcdc: 43 10                 mov     a0, (0x10, sp)
4841dcde: dd 8b b8 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841dce5: fc cc 38 00 04 00     mov     0x00040038, d0
4841dceb: 42 10                 mov     d0, (0x10, sp)
4841dced: fc cd 14 00 06 00     mov     0x00060014, d1
4841dcf3: 88                    mov     d2, d0
4841dcf4: dd 99 b6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dcfb: a0 00                 cmp     0, d0
4841dcfd: c8 1f                 beq     0x4841dd1c
4841dcff: 88                    mov     d2, d0
4841dd00: dd 1a fc 00 00 00 00  call    0x4842d91a, 0, 0
4841dd07: f8 40 30              movbu   (0x30, a0), d0
4841dd0a: fc cd b4 00 06 00     mov     0x000600b4, d1
4841dd10: 42 10                 mov     d0, (0x10, sp)
4841dd12: 88                    mov     d2, d0
4841dd13: dd 7a b6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dd1a: ca 1d                 bra     0x4841dd37
4841dd1c: 88                    mov     d2, d0
4841dd1d: dd fd fb 00 00 00 00  call    0x4842d91a, 0, 0
4841dd24: f8 40 2c              movbu   (0x2c, a0), d0
4841dd27: fc cd b4 00 06 00     mov     0x000600b4, d1
4841dd2d: 42 10                 mov     d0, (0x10, sp)
4841dd2f: 88                    mov     d2, d0
4841dd30: dd 5d b6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dd37: 00                    clr     d0
4841dd38: ca 55                 bra     0x4841dd8d
4841dd3a: fc cc 38 00 04 00     mov     0x00040038, d0
4841dd40: 42 10                 mov     d0, (0x10, sp)
4841dd42: 88                    mov     d2, d0
4841dd43: fc cd 14 00 06 00     mov     0x00060014, d1
4841dd49: dd 44 b6 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dd50: a0 00                 cmp     0, d0
4841dd52: c8 18                 beq     0x4841dd6a
4841dd54: 88                    mov     d2, d0
4841dd55: dd c5 fb 00 00 00 00  call    0x4842d91a, 0, 0
4841dd5c: f8 24 34              mov     (0x34, a0), a1
4841dd5f: 5c 2c                 mov     (0x2c, sp), a0
4841dd61: dd f0 52 be 03 20 04  call    0x4c003051, [a2], 4
4841dd68: ca 17                 bra     0x4841dd7f
4841dd6a: 88                    mov     d2, d0
4841dd6b: dd af fb 00 00 00 00  call    0x4842d91a, 0, 0
4841dd72: 91                    mov     a0, a1
4841dd73: 5c 2c                 mov     (0x2c, sp), a0
4841dd75: f8 25 30              mov     (0x30, a1), a1
4841dd78: dd d9 52 be 03 20 04  call    0x4c003051, [a2], 4
4841dd7f: 00                    clr     d0
4841dd80: ca 0d                 bra     0x4841dd8d
4841dd82: 5c 2c                 mov     (0x2c, sp), a0
4841dd84: 43 10                 mov     a0, (0x10, sp)
4841dd86: dd e3 b7 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841dd8d: df a0 1c              ret     [d2,a2], 0x1c

AcIndexPushSwProc:
4841dd90: cf c0                 movm    [d2,d3], (sp)
4841dd92: f8 fe ec              add     -0x14, sp
4841dd95: 83                    mov     d0, d3
4841dd96: 86                    mov     d1, d2
4841dd97: fc ca 01 00 05 00     cmp     0x50001, d2
4841dd9d: c8 23                 beq     0x4841ddc0
4841dd9f: fc ca 06 00 05 00     cmp     0x50006, d2
4841dda5: c8 36                 beq     0x4841dddb
4841dda7: fc ca 07 00 05 00     cmp     0x50007, d2
4841ddad: c9 05                 bne     0x4841ddb2
4841ddaf: cc a9 00              jmp     0x4841de58
4841ddb2: fc ca a2 00 06 00     cmp     0x600a2, d2
4841ddb8: c9 05                 bne     0x4841ddbd
4841ddba: cc 18 01              jmp     0x4841ded2
4841ddbd: cc 58 01              jmp     0x4841df15
4841ddc0: 5c 2c                 mov     (0x2c, sp), a0
4841ddc2: 43 10                 mov     a0, (0x10, sp)
4841ddc4: dd a5 b7 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841ddcb: 8c                    mov     d3, d0
4841ddcc: dd 4e fb 00 00 00 00  call    0x4842d91a, 0, 0
4841ddd3: f8 20 2c              mov     (0x2c, a0), a0
4841ddd6: 00                    clr     d0
4841ddd7: 60                    mov     d0, (a0)
4841ddd8: df c0 1c              ret     [d2,d3], 0x1c
4841dddb: dd 2e f6 00 00 00 0c  call    0x4842d409, 0, 0xc
4841dde2: a0 00                 cmp     0, d0
4841dde4: c8 64                 beq     0x4841de48
4841dde6: 5c 2c                 mov     (0x2c, sp), a0
4841dde8: 8c                    mov     d3, d0
4841dde9: 43 10                 mov     a0, (0x10, sp)
4841ddeb: fc cd 51 00 06 00     mov     0x00060051, d1
4841ddf1: dd 9c b5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841ddf8: a0 00                 cmp     0, d0
4841ddfa: c8 4e                 beq     0x4841de48
4841ddfc: 00                    clr     d0
4841ddfd: 42 10                 mov     d0, (0x10, sp)
4841ddff: 8c                    mov     d3, d0
4841de00: fc cd 4e 00 06 00     mov     0x0006004e, d1
4841de06: dd 87 b5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841de0d: 82                    mov     d0, d2
4841de0e: 18                    exth    d0
4841de0f: a0 ff                 cmp     -1, d0
4841de11: c8 33                 beq     0x4841de44
4841de13: 8c                    mov     d3, d0
4841de14: dd 06 fb 00 00 00 00  call    0x4842d91a, 0, 0
4841de1b: f8 20 2c              mov     (0x2c, a0), a0
4841de1e: 80 01                 mov     1, d0
4841de20: 60                    mov     d0, (a0)
4841de21: 00                    clr     d0
4841de22: 42 10                 mov     d0, (0x10, sp)
4841de24: fc cd b2 00 06 00     mov     0x000600b2, d1
4841de2a: 8c                    mov     d3, d0
4841de2b: dd 62 b5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841de32: 1a                    exth    d2
4841de33: 4a 10                 mov     d2, (0x10, sp)
4841de35: 80 ff                 mov     -1, d0
4841de37: fc cd 35 00 05 00     mov     0x00050035, d1
4841de3d: dd 50 b5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841de44: 00                    clr     d0
4841de45: df c0 1c              ret     [d2,d3], 0x1c
4841de48: 5c 2c                 mov     (0x2c, sp), a0
4841de4a: 89                    mov     d2, d1
4841de4b: 43 10                 mov     a0, (0x10, sp)
4841de4d: 8c                    mov     d3, d0
4841de4e: dd 1b b7 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841de55: df c0 1c              ret     [d2,d3], 0x1c
4841de58: dd b1 f5 00 00 00 0c  call    0x4842d409, 0, 0xc
4841de5f: a0 00                 cmp     0, d0
4841de61: c8 62                 beq     0x4841dec3
4841de63: 5c 2c                 mov     (0x2c, sp), a0
4841de65: 8c                    mov     d3, d0
4841de66: 43 10                 mov     a0, (0x10, sp)
4841de68: fc cd 51 00 06 00     mov     0x00060051, d1
4841de6e: dd 1f b5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841de75: a0 00                 cmp     0, d0
4841de77: c8 4c                 beq     0x4841dec3
4841de79: 00                    clr     d0
4841de7a: 42 10                 mov     d0, (0x10, sp)
4841de7c: 8c                    mov     d3, d0
4841de7d: fc cd 4e 00 06 00     mov     0x0006004e, d1
4841de83: dd 0a b5 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841de8a: 82                    mov     d0, d2
4841de8b: 18                    exth    d0
4841de8c: a0 ff                 cmp     -1, d0
4841de8e: c8 31                 beq     0x4841debf
4841de90: 8c                    mov     d3, d0
4841de91: dd 89 fa 00 00 00 00  call    0x4842d91a, 0, 0
4841de98: f8 20 2c              mov     (0x2c, a0), a0
4841de9b: 00                    clr     d0
4841de9c: 60                    mov     d0, (a0)
4841de9d: 42 10                 mov     d0, (0x10, sp)
4841de9f: fc cd b2 00 06 00     mov     0x000600b2, d1
4841dea5: 8c                    mov     d3, d0
4841dea6: dd e7 b4 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dead: 1a                    exth    d2
4841deae: 4a 10                 mov     d2, (0x10, sp)
4841deb0: 80 ff                 mov     -1, d0
4841deb2: fc cd 36 00 05 00     mov     0x00050036, d1
4841deb8: dd d5 b4 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841debf: 00                    clr     d0
4841dec0: df c0 1c              ret     [d2,d3], 0x1c
4841dec3: 5c 2c                 mov     (0x2c, sp), a0
4841dec5: 89                    mov     d2, d1
4841dec6: 43 10                 mov     a0, (0x10, sp)
4841dec8: 8c                    mov     d3, d0
4841dec9: dd a0 b6 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841ded0: ca 50                 bra     0x4841df20
4841ded2: 5c 2c                 mov     (0x2c, sp), a0
4841ded4: 43 10                 mov     a0, (0x10, sp)
4841ded6: dd 93 b6 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841dedd: 82                    mov     d0, d2
4841dede: 8c                    mov     d3, d0
4841dedf: dd 3b fa 00 00 00 00  call    0x4842d91a, 0, 0
4841dee6: f8 20 2c              mov     (0x2c, a0), a0
4841dee9: 74                    mov     (a0), d1
4841deea: a5 00                 cmp     0, d1
4841deec: c8 25                 beq     0x4841df11
4841deee: 89                    mov     d2, d1
4841deef: 19                    exth    d1
4841def0: fa c9 c0 00           cmp     0xc0, d1
4841def4: c8 10                 beq     0x4841df04
4841def6: fa c9 c1 00           cmp     0xc1, d1
4841defa: c8 0f                 beq     0x4841df09
4841defc: fa c9 c9 00           cmp     0xc9, d1
4841df00: c8 0e                 beq     0x4841df0e
4841df02: ca 0f                 bra     0x4841df11
4841df04: 2e c2 00              mov     0xc2, d2
4841df07: ca 0a                 bra     0x4841df11
4841df09: 2e c3 00              mov     0xc3, d2
4841df0c: ca 05                 bra     0x4841df11
4841df0e: 2e ca 00              mov     0xca, d2
4841df11: 88                    mov     d2, d0
4841df12: 18                    exth    d0
4841df13: ca 0d                 bra     0x4841df20
4841df15: 5c 2c                 mov     (0x2c, sp), a0
4841df17: 43 10                 mov     a0, (0x10, sp)
4841df19: dd 50 b6 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841df20: df c0 1c              ret     [d2,d3], 0x1c

PsPageBoxProc:
4841df23: cf f0                 movm    [d2,d3,a2,a3], (sp)
4841df25: f8 fe cc              add     -0x34, sp
4841df28: 42 4c                 mov     d0, (0x4c, sp)
4841df2a: fc c9 01 00 05 00     cmp     0x50001, d1
4841df30: c8 44                 beq     0x4841df74
4841df32: fc c9 b4 00 06 00     cmp     0x600b4, d1
4841df38: c8 7b                 beq     0x4841dfb3
4841df3a: fc c9 51 00 06 00     cmp     0x60051, d1
4841df40: c9 05                 bne     0x4841df45
4841df42: cc 34 01              jmp     0x4841e076
4841df45: fc c9 52 00 06 00     cmp     0x60052, d1
4841df4b: c9 05                 bne     0x4841df50
4841df4d: cc 4b 01              jmp     0x4841e098
4841df50: fc c9 53 00 06 00     cmp     0x60053, d1
4841df56: c9 05                 bne     0x4841df5b
4841df58: cc 44 01              jmp     0x4841e09c
4841df5b: fc c9 54 00 06 00     cmp     0x60054, d1
4841df61: c9 05                 bne     0x4841df66
4841df63: cc 3d 01              jmp     0x4841e0a0
4841df66: fc c9 75 00 06 00     cmp     0x60075, d1
4841df6c: c9 05                 bne     0x4841df71
4841df6e: cc 41 01              jmp     0x4841e0af
4841df71: cc 4f 01              jmp     0x4841e0c0
4841df74: 5e 54                 mov     (0x54, sp), a2
4841df76: 4b 10                 mov     a2, (0x10, sp)
4841df78: dd f1 b5 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841df7f: ba 00                 cmp     0, a2
4841df81: c8 0e                 beq     0x4841df8f
4841df83: ba 05                 cmp     5, a2
4841df85: c8 0a                 beq     0x4841df8f
4841df87: ba 03                 cmp     3, a2
4841df89: c8 06                 beq     0x4841df8f
4841df8b: ba 04                 cmp     4, a2
4841df8d: c9 22                 bne     0x4841dfaf
4841df8f: 58 4c                 mov     (0x4c, sp), d0
4841df91: dd 89 f9 00 00 00 00  call    0x4842d91a, 0, 0
4841df98: f8 20 20              mov     (0x20, a0), a0
4841df9b: fc cd 16 00 05 00     mov     0x00050016, d1
4841dfa1: f0 60                 movhu   (a0), d0
4841dfa3: 18                    exth    d0
4841dfa4: 42 10                 mov     d0, (0x10, sp)
4841dfa6: 80 ff                 mov     -1, d0
4841dfa8: dd e5 b3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dfaf: 00                    clr     d0
4841dfb0: df f0 44              ret     [d2,d3,a2,a3], 0x44
4841dfb3: dd 67 f9 00 00 00 00  call    0x4842d91a, 0, 0
4841dfba: 00                    clr     d0
4841dfbb: 42 10                 mov     d0, (0x10, sp)
4841dfbd: 58 4c                 mov     (0x4c, sp), d0
4841dfbf: fc cd a3 00 06 00     mov     0x000600a3, d1
4841dfc5: 92                    mov     a0, a2
4841dfc6: dd c7 b3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dfcd: f8 93 24              movhu   d0, (0x24, sp)
4841dfd0: 5d 54                 mov     (0x54, sp), a1
4841dfd2: b5 00                 cmp     0, a1
4841dfd4: c8 1b                 beq     0x4841dfef
4841dfd6: f8 22 20              mov     (0x20, a2), a0
4841dfd9: f1 d4                 mov     a1, d0
4841dfdb: f0 70                 movhu   d0, (a0)
4841dfdd: 18                    exth    d0
4841dfde: 42 10                 mov     d0, (0x10, sp)
4841dfe0: 80 ff                 mov     -1, d0
4841dfe2: fc cd 16 00 05 00     mov     0x00050016, d1
4841dfe8: dd a5 b3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841dfef: f8 22 20              mov     (0x20, a2), a0
4841dff2: 00                    clr     d0
4841dff3: f0 6c                 movhu   (a0), d3
4841dff5: 42 10                 mov     d0, (0x10, sp)
4841dff7: 58 4c                 mov     (0x4c, sp), d0
4841dff9: fc cd 53 00 06 00     mov     0x00060053, d1
4841dfff: dd 8e b3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841e006: 82                    mov     d0, d2
4841e007: 1a                    exth    d2
4841e008: 2c 00 01              mov     0x100, d0
4841e00b: cd 1f 86 b0 28        call    0x4841662a, [d2,a2,a3], 0x28
4841e010: 43 20                 mov     a0, (0x20, sp)
4841e012: aa 0a                 cmp     0xa, d2
4841e014: c2 1a                 bge     0x4841e02e
4841e016: 43 08                 mov     a0, (8, sp)
4841e018: fc cc 0c f2 59 48     mov     0x4859f20c, d0
4841e01e: 42 0c                 mov     d0, (0xc, sp)
4841e020: 1b                    exth    d3
4841e021: 4e 10                 mov     d3, (0x10, sp)
4841e023: 4a 14                 mov     d2, (0x14, sp)
4841e025: dd 23 3a be 03 20 20  call    0x4c001a48, [a2], 0x20
4841e02c: ca 18                 bra     0x4841e044
4841e02e: 43 08                 mov     a0, (8, sp)
4841e030: fc cc 18 f2 59 48     mov     0x4859f218, d0
4841e036: 42 0c                 mov     d0, (0xc, sp)
4841e038: 1b                    exth    d3
4841e039: 4e 10                 mov     d3, (0x10, sp)
4841e03b: 4a 14                 mov     d2, (0x14, sp)
4841e03d: dd 0b 3a be 03 20 20  call    0x4c001a48, [a2], 0x20
4841e044: 3f                    mov     sp, a3
4841e045: 23 28                 add     0x28, a3
4841e047: 58 4c                 mov     (0x4c, sp), d0
4841e049: 9c                    mov     a3, a0
4841e04a: cd 9b 8a 00 14        call    0x48416ae5, 0, 0x14
4841e04f: 3e                    mov     sp, a2
4841e050: 22 30                 add     0x30, a2
4841e052: 9c                    mov     a3, a0
4841e053: 99                    mov     a2, a1
4841e054: cd df 8d f0 20        call    0x48416e33, [d2,d3,a2,a3], 0x20
4841e059: 58 20                 mov     (0x20, sp), d0
4841e05b: 99                    mov     a2, a1
4841e05c: 42 10                 mov     d0, (0x10, sp)
4841e05e: f8 bc 24              movhu   (0x24, sp), d0
4841e061: 9c                    mov     a3, a0
4841e062: 18                    exth    d0
4841e063: 42 1c                 mov     d0, (0x1c, sp)
4841e065: 00                    clr     d0
4841e066: 81                    mov     d0, d1
4841e067: cd 31 78 f0 10        call    0x48425898, [d2,d3,a2,a3], 0x10
4841e06c: 5c 20                 mov     (0x20, sp), a0
4841e06e: cd 70 86 f0 2c        call    0x484166de, [d2,d3,a2,a3], 0x2c
4841e073: 00                    clr     d0
4841e074: ca 57                 bra     0x4841e0cb
4841e076: 5c 54                 mov     (0x54, sp), a0
4841e078: fc cc 24 00 0d 00     mov     0x000d0024, d0
4841e07e: 43 10                 mov     a0, (0x10, sp)
4841e080: fc cd 29 00 06 00     mov     0x00060029, d1
4841e086: dd 07 b3 00 00 c0 24  call    0x4842938d, [d2,d3], 0x24
4841e08d: a0 18                 cmp     0x18, d0
4841e08f: c9 06                 bne     0x4841e095
4841e091: 80 01                 mov     1, d0
4841e093: ca 38                 bra     0x4841e0cb
4841e095: 00                    clr     d0
4841e096: ca 35                 bra     0x4841e0cb
4841e098: 80 01                 mov     1, d0
4841e09a: ca 31                 bra     0x4841e0cb
4841e09c: 80 01                 mov     1, d0
4841e09e: ca 2d                 bra     0x4841e0cb
4841e0a0: dd 7a f8 00 00 00 00  call    0x4842d91a, 0, 0
4841e0a7: f8 20 20              mov     (0x20, a0), a0
4841e0aa: f0 60                 movhu   (a0), d0
4841e0ac: 18                    exth    d0
4841e0ad: ca 1e                 bra     0x4841e0cb
4841e0af: dd 6b f8 00 00 00 00  call    0x4842d91a, 0, 0
4841e0b6: f8 20 20              mov     (0x20, a0), a0
4841e0b9: 58 54                 mov     (0x54, sp), d0
4841e0bb: f0 70                 movhu   d0, (a0)
4841e0bd: 00                    clr     d0
4841e0be: ca 0d                 bra     0x4841e0cb
4841e0c0: 5c 54                 mov     (0x54, sp), a0
4841e0c2: 43 10                 mov     a0, (0x10, sp)
4841e0c4: dd a5 b4 00 00 f0 28  call    0x48429569, [d2,d3,a2,a3], 0x28
4841e0cb: df f0 44              ret     [d2,d3,a2,a3], 0x44
