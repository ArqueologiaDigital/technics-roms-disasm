; KN7000 program flash - entry region disassembly (file 0x0 .. 0x400)
; MAME unidasm -arch mn10300, basepc = CPU address (file offset + 0x48400000)
; This is a curated sample; regenerate the full listing with: make disasm
;
48400000: dc 7e ff 00 00     jmp     0x4840ff7e
48400005: cb                 nop
48400006: cb                 nop
48400007: cb                 nop
48400008: cb                 nop
48400009: cb                 nop
4840000a: dc c5 77 0d 00     jmp     0x484d77cf
4840000f: 16                 extbu   d2
48400010: ff                 ?
48400011: ff                 ?
48400012: ff                 ?
48400013: ff                 ?
48400014: ff                 ?
48400015: ff                 ?
48400016: ff                 ?
48400017: ff                 ?
48400018: ff                 ?
48400019: ff                 ?
4840001a: ff                 ?
4840001b: ff                 ?
4840001c: ff                 ?
4840001d: ff                 ?
4840001e: ff                 ?
4840001f: ff                 ?
48400020: ff                 ?
48400021: ff                 ?
48400022: ff                 ?
48400023: ff                 ?
48400024: ff                 ?
48400025: ff                 ?
48400026: ff                 ?
48400027: ff                 ?
48400028: ff                 ?
48400029: ff                 ?
4840002a: ff                 ?
4840002b: ff                 ?
4840002c: ff                 ?
4840002d: ff                 ?
4840002e: ff                 ?
4840002f: ff                 ?
48400030: ff                 ?
48400031: ff                 ?
48400032: ff                 ?
48400033: ff                 ?
48400034: ff                 ?
48400035: ff                 ?
48400036: ff                 ?
48400037: ff                 ?
48400038: ff                 ?
48400039: ff                 ?
4840003a: ff                 ?
4840003b: ff                 ?
4840003c: ff                 ?
4840003d: ff                 ?
4840003e: ff                 ?
4840003f: ff                 ?
48400040: ff                 ?
48400041: ff                 ?
48400042: ff                 ?
48400043: ff                 ?
48400044: ff                 ?
48400045: ff                 ?
48400046: ff                 ?
48400047: ff                 ?
48400048: ff                 ?
48400049: ff                 ?
4840004a: ff                 ?
4840004b: ff                 ?
4840004c: ff                 ?
4840004d: ff                 ?
4840004e: ff                 ?
4840004f: ff                 ?
48400050: ff                 ?
48400051: ff                 ?
48400052: ff                 ?
48400053: ff                 ?
48400054: ff                 ?
48400055: ff                 ?
48400056: ff                 ?
48400057: ff                 ?
48400058: ff                 ?
48400059: ff                 ?
4840005a: ff                 ?
4840005b: ff                 ?
4840005c: ff                 ?
4840005d: ff                 ?
4840005e: ff                 ?
4840005f: ff                 ?
48400060: ff                 ?
48400061: ff                 ?
48400062: ff                 ?
48400063: ff                 ?
48400064: ff                 ?
48400065: ff                 ?
48400066: ff                 ?
48400067: ff                 ?
48400068: ff                 ?
48400069: ff                 ?
4840006a: ff                 ?
4840006b: ff                 ?
4840006c: ff                 ?
4840006d: ff                 ?
4840006e: ff                 ?
4840006f: ff                 ?
48400070: ff                 ?
48400071: ff                 ?
48400072: ff                 ?
48400073: ff                 ?
48400074: ff                 ?
48400075: ff                 ?
48400076: ff                 ?
48400077: ff                 ?
48400078: ff                 ?
48400079: ff                 ?
4840007a: ff                 ?
4840007b: ff                 ?
4840007c: ff                 ?
4840007d: ff                 ?
4840007e: ff                 ?
4840007f: ff                 ?
48400080: cb                 nop
48400081: df 00 00           ret     0, 0
48400084: f8 92 08           movbu   d0, (8, sp)
48400087: f8 b8 08           movbu   (8, sp), d0
4840008a: fa c8 83 00        cmp     0x83, d0
4840008e: c9 04              bne     0x48400092
48400090: ca 25              bra     0x484000b5
48400092: fa c8 84 00        cmp     0x84, d0
48400096: c9 04              bne     0x4840009a
48400098: ca 33              bra     0x484000cb
4840009a: fa c8 81 00        cmp     0x81, d0
4840009e: c9 04              bne     0x484000a2
484000a0: ca 39              bra     0x484000d9
484000a2: fa c8 80 00        cmp     0x80, d0
484000a6: c9 04              bne     0x484000aa
484000a8: ca 43              bra     0x484000eb
484000aa: fa c8 82 00        cmp     0x82, d0
484000ae: c9 04              bne     0x484000b2
484000b0: ca 5a              bra     0x4840010a
484000b2: cc 8d 00           jmp     0x4840013f
484000b5: fc a8 04 00 02 98  movbu   (0x98020004), d0
484000bb: fc 82 46 7f 00 50  movbu   d0, (0x50007f46)
484000c1: 80 1c              mov     0x1c, d0
484000c3: fc 82 04 00 02 98  movbu   d0, (0x98020004)
484000c9: ca 76              bra     0x4840013f
484000cb: fc a8 46 7f 00 50  movbu   (0x50007f46), d0
484000d1: fc 82 04 00 02 98  movbu   d0, (0x98020004)
484000d7: ca 68              bra     0x4840013f
484000d9: 80 1c              mov     0x1c, d0
484000db: fc 82 04 00 02 98  movbu   d0, (0x98020004)
484000e1: 80 01              mov     1, d0
484000e3: fc 82 10 00 00 50  movbu   d0, (0x50000010)
484000e9: ca 56              bra     0x4840013f
484000eb: fc a8 10 00 00 50  movbu   (0x50000010), d0
484000f1: a0 01              cmp     1, d0
484000f3: c8 04              beq     0x484000f7
484000f5: ca 4a              bra     0x4840013f
484000f7: 80 02              mov     2, d0
484000f9: fc 82 10 00 00 50  movbu   d0, (0x50000010)
484000ff: 2c fa 00           mov     0xfa, d0
48400102: fc 83 44 7f 00 50  movhu   d0, (0x50007f44)
48400108: ca 37              bra     0x4840013f
4840010a: fc a8 10 00 00 50  movbu   (0x50000010), d0
48400110: a0 02              cmp     2, d0
48400112: c8 04              beq     0x48400116
48400114: ca 2b              bra     0x4840013f
48400116: fc ac 44 7f 00 50  movhu   (0x50007f44), d0
4840011c: 28 ff              add     -1, d0
4840011e: fc 83 44 7f 00 50  movhu   d0, (0x50007f44)
48400124: fc ac 44 7f 00 50  movhu   (0x50007f44), d0
4840012a: a0 00              cmp     0, d0
4840012c: c8 04              beq     0x48400130
4840012e: ca 11              bra     0x4840013f
48400130: 00                 clr     d0
48400131: fc 82 10 00 00 50  movbu   d0, (0x50000010)
48400137: 80 0c              mov     0xc, d0
48400139: fc 82 04 00 02 98  movbu   d0, (0x98020004)
4840013f: df 00 00           ret     0, 0
48400142: f8 fe f0           add     -0x10, sp
48400145: fc a8 08 00 02 98  movbu   (0x98020008), d0
4840014b: f8 92 0c           movbu   d0, (0xc, sp)
4840014e: 80 02              mov     2, d0
48400150: cd d9 07 00 00     call    0x48400929, 0, 0
48400155: f8 b8 0c           movbu   (0xc, sp), d0
48400158: df 00 10           ret     0, 0x10
4840015b: fc a8 0a 00 02 98  movbu   (0x9802000a), d0
48400161: df 00 00           ret     0, 0
48400164: f8 92 08           movbu   d0, (8, sp)
48400167: fc a8 35 e9 09 50  movbu   (0x5009e935), d0
4840016d: fc 82 34 e9 09 50  movbu   d0, (0x5009e934)
48400173: f8 b8 08           movbu   (8, sp), d0
48400176: fc 82 35 e9 09 50  movbu   d0, (0x5009e935)
4840017c: fc 82 08 00 02 98  movbu   d0, (0x98020008)
48400182: df 00 00           ret     0, 0
48400185: f8 92 08           movbu   d0, (8, sp)
48400188: fc 82 0a 00 02 98  movbu   d0, (0x9802000a)
4840018e: df 00 00           ret     0, 0
48400191: f8 fe e0           add     -0x20, sp
48400194: fc a4 fc 1b 15 50  mov     (0x50151bfc), d0
4840019a: 42 0c              mov     d0, (0xc, sp)
4840019c: 2c 80 00           mov     0x80, d0
4840019f: 42 10              mov     d0, (0x10, sp)
484001a1: ca 34              bra     0x484001d5
484001a3: cd a2 ff 00 10     call    0x48400145, 0, 0x10
484001a8: 14                 extbu   d0
484001a9: f8 e0 1f           and     0x1f, d0
484001ac: 42 14              mov     d0, (0x14, sp)
484001ae: 58 14              mov     (0x14, sp), d0
484001b0: a0 00              cmp     0, d0
484001b2: c8 04              beq     0x484001b6
484001b4: ca 05              bra     0x484001b9
484001b6: 00                 clr     d0
484001b7: 42 10              mov     d0, (0x10, sp)
484001b9: fc a4 fc 1b 15 50  mov     (0x50151bfc), d0
484001bf: 42 18              mov     d0, (0x18, sp)
484001c1: 58 18              mov     (0x18, sp), d0
484001c3: 59 0c              mov     (0xc, sp), d1
484001c5: f1 04              sub     d1, d0
484001c7: 42 1c              mov     d0, (0x1c, sp)
484001c9: fa c8 f4 01        cmp     0x1f4, d0
484001cd: c5 04              bhi     0x484001d1
484001cf: ca 06              bra     0x484001d5
484001d1: 80 ff              mov     -1, d0
484001d3: 42 10              mov     d0, (0x10, sp)
484001d5: 58 10              mov     (0x10, sp), d0
484001d7: fa c8 80 00        cmp     0x80, d0
484001db: c9 04              bne     0x484001df
484001dd: ca c6              bra     0x484001a3
484001df: 58 10              mov     (0x10, sp), d0
484001e1: a0 00              cmp     0, d0
484001e3: c9 04              bne     0x484001e7
484001e5: ca 09              bra     0x484001ee
484001e7: 80 01              mov     1, d0
484001e9: cd cf 0f 00 00     call    0x484011b8, 0, 0
484001ee: df 00 20           ret     0, 0x20
484001f1: f8 fe e4           add     -0x1c, sp
484001f4: fc a4 fc 1b 15 50  mov     (0x50151bfc), d0
484001fa: 42 0c              mov     d0, (0xc, sp)
484001fc: 2c 80 00           mov     0x80, d0
484001ff: 42 10              mov     d0, (0x10, sp)
48400201: ca 32              bra     0x48400233
48400203: cd 42 ff 00 10     call    0x48400145, 0, 0x10
48400208: 14                 extbu   d0
48400209: f8 e0 90           and     0x90, d0
4840020c: fa c8 90 00        cmp     0x90, d0
48400210: c8 04              beq     0x48400214
48400212: ca 05              bra     0x48400217
48400214: 00                 clr     d0
48400215: 42 10              mov     d0, (0x10, sp)
48400217: fc a4 fc 1b 15 50  mov     (0x50151bfc), d0
4840021d: 42 14              mov     d0, (0x14, sp)
4840021f: 58 14              mov     (0x14, sp), d0
48400221: 59 0c              mov     (0xc, sp), d1
48400223: f1 04              sub     d1, d0
48400225: 42 18              mov     d0, (0x18, sp)
48400227: fa c8 f4 01        cmp     0x1f4, d0
4840022b: c5 04              bhi     0x4840022f
4840022d: ca 06              bra     0x48400233
4840022f: 80 ff              mov     -1, d0
48400231: 42 10              mov     d0, (0x10, sp)
48400233: 58 10              mov     (0x10, sp), d0
48400235: fa c8 80 00        cmp     0x80, d0
48400239: c9 04              bne     0x4840023d
4840023b: ca c8              bra     0x48400203
4840023d: 58 10              mov     (0x10, sp), d0
4840023f: a0 00              cmp     0, d0
48400241: c9 04              bne     0x48400245
48400243: ca 09              bra     0x4840024c
48400245: 80 01              mov     1, d0
48400247: cd 71 0f 00 00     call    0x484011b8, 0, 0
4840024c: df 00 1c           ret     0, 0x1c
4840024f: f8 fe e4           add     -0x1c, sp
48400252: fc a4 fc 1b 15 50  mov     (0x50151bfc), d0
48400258: 42 0c              mov     d0, (0xc, sp)
4840025a: 2c 80 00           mov     0x80, d0
4840025d: 42 10              mov     d0, (0x10, sp)
4840025f: ca 32              bra     0x48400291
48400261: cd e4 fe 00 10     call    0x48400145, 0, 0x10
48400266: 14                 extbu   d0
48400267: f8 e0 80           and     0x80, d0
4840026a: fa c8 80 00        cmp     0x80, d0
4840026e: c8 04              beq     0x48400272
48400270: ca 05              bra     0x48400275
48400272: 00                 clr     d0
48400273: 42 10              mov     d0, (0x10, sp)
48400275: fc a4 fc 1b 15 50  mov     (0x50151bfc), d0
4840027b: 42 14              mov     d0, (0x14, sp)
4840027d: 58 14              mov     (0x14, sp), d0
4840027f: 59 0c              mov     (0xc, sp), d1
48400281: f1 04              sub     d1, d0
48400283: 42 18              mov     d0, (0x18, sp)
48400285: fa c8 f4 01        cmp     0x1f4, d0
48400289: c5 04              bhi     0x4840028d
4840028b: ca 06              bra     0x48400291
4840028d: 80 ff              mov     -1, d0
4840028f: 42 10              mov     d0, (0x10, sp)
48400291: 58 10              mov     (0x10, sp), d0
48400293: fa c8 80 00        cmp     0x80, d0
48400297: c9 04              bne     0x4840029b
48400299: ca c8              bra     0x48400261
4840029b: 58 10              mov     (0x10, sp), d0
4840029d: a0 00              cmp     0, d0
4840029f: c9 04              bne     0x484002a3
484002a1: ca 09              bra     0x484002aa
484002a3: 80 01              mov     1, d0
484002a5: cd 13 0f 00 00     call    0x484011b8, 0, 0
484002aa: df 00 1c           ret     0, 0x1c
484002ad: f8 fe f4           add     -0xc, sp
484002b0: 2c 80 00           mov     0x80, d0
484002b3: cd b1 fe 00 00     call    0x48400164, 0, 0
484002b8: 80 02              mov     2, d0
484002ba: cd b2 0f 00 10     call    0x4840126c, 0, 0x10
484002bf: 2c ff 00           mov     0xff, d0
484002c2: fc 82 19 e9 09 50  movbu   d0, (0x5009e919)
484002c8: df 00 0c           ret     0, 0xc
484002cb: f8 fe ec           add     -0x14, sp
484002ce: cd 2e 0f 00 00     call    0x484011fc, 0, 0
484002d3: cd 51 0e 00 00     call    0x48401124, 0, 0
484002d8: 18                 exth    d0
484002d9: a0 ff              cmp     -1, d0
484002db: c9 04              bne     0x484002df
484002dd: ca 17              bra     0x484002f4
484002df: cd b3 0e 00 00     call    0x48401192, 0, 0
484002e4: 18                 exth    d0
484002e5: a0 ff              cmp     -1, d0
484002e7: c9 04              bne     0x484002eb
484002e9: ca 0b              bra     0x484002f4
484002eb: 2c ff 00           mov     0xff, d0
484002ee: fc 82 19 e9 09 50  movbu   d0, (0x5009e919)
484002f4: fc a8 68 e8 09 50  movbu   (0x5009e868), d0
484002fa: 10                 extb    d0
484002fb: a0 01              cmp     1, d0
484002fd: c9 05              bne     0x48400302
484002ff: cc 2f 02           jmp     0x4840052e
48400302: 80 01              mov     1, d0
48400304: fc 82 68 e8 09 50  movbu   d0, (0x5009e868)
4840030a: 2c 80 00           mov     0x80, d0
4840030d: cd 57 fe 00 00     call    0x48400164, 0, 0
48400312: 80 02              mov     2, d0
48400314: cd 58 0f 00 10     call    0x4840126c, 0, 0x10
48400319: cd 0b 0e 00 00     call    0x48401124, 0, 0
4840031e: 18                 exth    d0
4840031f: a0 ff              cmp     -1, d0
48400321: c9 05              bne     0x48400326
48400323: cc ca 00           jmp     0x484003ed
48400326: cd 6c 0e 00 00     call    0x48401192, 0, 0
4840032b: 18                 exth    d0
4840032c: a0 ff              cmp     -1, d0
4840032e: c9 05              bne     0x48400333
48400330: cc bd 00           jmp     0x484003ed
48400333: cd c9 0e 00 00     call    0x484011fc, 0, 0
48400338: cd fc 01 00 0c     call    0x48400534, 0, 0xc
4840033d: fc a8 70 e8 09 50  movbu   (0x5009e870), d0
48400343: 10                 extb    d0
48400344: a0 00              cmp     0, d0
48400346: c9 04              bne     0x4840034a
48400348: ca 0c              bra     0x48400354
4840034a: 00                 clr     d0
4840034b: fc 82 68 e8 09 50  movbu   d0, (0x5009e868)
48400351: cc dd 01           jmp     0x4840052e
48400354: cd fe fe 00 1c     call    0x48400252, 0, 0x1c
48400359: fc a8 70 e8 09 50  movbu   (0x5009e870), d0
4840035f: 10                 extb    d0
48400360: a0 00              cmp     0, d0
48400362: c9 04              bne     0x48400366
48400364: ca 0c              bra     0x48400370
48400366: 00                 clr     d0
48400367: fc 82 68 e8 09 50  movbu   d0, (0x5009e868)
4840036d: cc c1 01           jmp     0x4840052e
48400370: cd d5 fd 00 10     call    0x48400145, 0, 0x10
48400375: 14                 extbu   d0
48400376: f8 ec 40           btst    0x40, d0
48400379: c8 04              beq     0x4840037d
4840037b: ca 26              bra     0x484003a1
4840037d: 00                 clr     d0
4840037e: f8 92 10           movbu   d0, (0x10, sp)
48400381: ca 0e              bra     0x4840038f
48400383: cd c2 fd 00 10     call    0x48400145, 0, 0x10
48400388: 14                 extbu   d0
48400389: f8 e0 f0           and     0xf0, d0
4840038c: f8 92 10           movbu   d0, (0x10, sp)
4840038f: f8 b8 10           movbu   (0x10, sp), d0
48400392: fa c8 80 00        cmp     0x80, d0
48400396: c8 04              beq     0x4840039a
48400398: ca eb              bra     0x48400383
4840039a: 80 08              mov     8, d0
4840039c: cd e9 fd 00 00     call    0x48400185, 0, 0
484003a1: fc cc c4 e8 09 50  mov     0x5009e8c4, d0
484003a7: 42 0c              mov     d0, (0xc, sp)
484003a9: 40                 inc     d0
484003aa: 42 0c              mov     d0, (0xc, sp)
484003ac: cd c8 07 00 20     call    0x48400b74, 0, 0x20
484003b1: cd aa fd 00 00     call    0x4840015b, 0, 0
484003b6: 5c 0c              mov     (0xc, sp), a0
484003b8: f0 50              movbu   d0, (a0)
484003ba: 58 0c              mov     (0xc, sp), d0
484003bc: 40                 inc     d0
484003bd: 42 0c              mov     d0, (0xc, sp)
484003bf: cd 86 fd 00 10     call    0x48400145, 0, 0x10
484003c4: 14                 extbu   d0
484003c5: f8 ec 80           btst    0x80, d0
484003c8: c9 04              bne     0x484003cc
484003ca: ca f5              bra     0x484003bf
484003cc: cd 79 fd 00 10     call    0x48400145, 0, 0x10
484003d1: 14                 extbu   d0
484003d2: f8 ec 40           btst    0x40, d0
484003d5: c8 04              beq     0x484003d9
484003d7: ca d5              bra     0x484003ac
484003d9: cd 3a 09 00 14     call    0x48400d13, 0, 0x14
484003de: fc a8 c5 e8 09 50  movbu   (0x5009e8c5), d0
484003e4: fa c8 80 00        cmp     0x80, d0
484003e8: c8 05              beq     0x484003ed
484003ea: cc 6a ff           jmp     0x48400354
484003ed: 80 03              mov     3, d0
484003ef: cd 47 0a 00 10     call    0x48400e36, 0, 0x10
484003f4: fc a8 70 e8 09 50  movbu   (0x5009e870), d0
484003fa: 10                 extb    d0
484003fb: a0 00              cmp     0, d0
484003fd: c9 04              bne     0x48400401
484003ff: ca 0c              bra     0x4840040b
