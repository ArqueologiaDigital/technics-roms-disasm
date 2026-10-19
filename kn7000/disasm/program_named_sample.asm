; KN7000 program image - named function disassembly
; 47 functions in [0x48429300, 0x4842a800); names from kn7000.sym (MILK-toolkit reflection tables, shared w/ KN5000)
;

InitializeEventQueue:
4842936f: f8 fe f0              add     -0x10, sp
48429372: 3c                    mov     sp, a0
48429373: 20 0c                 add     0xc, a0
48429375: dd da b6 fe ff 20 04  call    0x48414a4f, [a2], 4
4842937c: f8 bc 0c              movhu   (0xc, sp), d0
4842937f: 18                    exth    d0
48429380: cd c3 f8 f0 44        call    0x48428c43, [d2,d3,a2,a3], 0x44
48429385: df 00 10              ret     0, 0x10

DispatchEvent:
48429388: cf c0                 movm    [d2,d3], (sp)
4842938a: f8 fe e4              add     -0x1c, sp
4842938d: 3c                    mov     sp, a0
4842938e: 20 18                 add     0x18, a0
48429390: 87                    mov     d1, d3
48429391: 82                    mov     d0, d2
48429392: dd bd b6 fe ff 20 04  call    0x48414a4f, [a2], 4
48429399: 5c 34                 mov     (0x34, sp), a0
4842939b: 88                    mov     d2, d0
4842939c: 43 10                 mov     a0, (0x10, sp)
4842939e: f8 bd 18              movhu   (0x18, sp), d1
484293a1: 19                    exth    d1
484293a2: 46 14                 mov     d1, (0x14, sp)
484293a4: 8d                    mov     d3, d1
484293a5: cd b0 f1 f0 28        call    0x48428555, [d2,d3,a2,a3], 0x28
484293aa: df c0 24              ret     [d2,d3], 0x24

SendEvent:
484293ad: cf c0                 movm    [d2,d3], (sp)
484293af: f8 fe e4              add     -0x1c, sp
484293b2: 3c                    mov     sp, a0
484293b3: 20 18                 add     0x18, a0
484293b5: 87                    mov     d1, d3
484293b6: 82                    mov     d0, d2
484293b7: dd 98 b6 fe ff 20 04  call    0x48414a4f, [a2], 4
484293be: 5c 34                 mov     (0x34, sp), a0
484293c0: 88                    mov     d2, d0
484293c1: 43 10                 mov     a0, (0x10, sp)
484293c3: f8 bd 18              movhu   (0x18, sp), d1
484293c6: 19                    exth    d1
484293c7: 46 14                 mov     d1, (0x14, sp)
484293c9: 8d                    mov     d3, d1
484293ca: cd 1a f2 f0 38        call    0x484285e4, [d2,d3,a2,a3], 0x38
484293cf: df c0 24              ret     [d2,d3], 0x24

PostEvent:
484293d2: cf b0                 movm    [d2,a2,a3], (sp)
484293d4: f8 fe e4              add     -0x1c, sp
484293d7: 82                    mov     d0, d2
484293d8: 97                    mov     a1, a3
484293d9: 92                    mov     a0, a2
484293da: 3c                    mov     sp, a0
484293db: 20 18                 add     0x18, a0
484293dd: dd 72 b6 fe ff 20 04  call    0x48414a4f, [a2], 4
484293e4: f8 bc 18              movhu   (0x18, sp), d0
484293e7: 89                    mov     d2, d1
484293e8: 18                    exth    d0
484293e9: 9d                    mov     a3, a1
484293ea: 98                    mov     a2, a0
484293eb: cd a7 f3 f0 2c        call    0x48428792, [d2,d3,a2,a3], 0x2c
484293f0: 80 01                 mov     1, d0
484293f2: df b0 28              ret     [d2,a2,a3], 0x28

DeleteSpecificEvent:
484293f5: cf c0                 movm    [d2,d3], (sp)
484293f7: f8 fe e8              add     -0x18, sp
484293fa: 3c                    mov     sp, a0
484293fb: 20 14                 add     0x14, a0
484293fd: 87                    mov     d1, d3
484293fe: 82                    mov     d0, d2
484293ff: dd 50 b6 fe ff 20 04  call    0x48414a4f, [a2], 4
48429406: f8 bd 14              movhu   (0x14, sp), d1
48429409: 88                    mov     d2, d0
4842940a: 19                    exth    d1
4842940b: 46 10                 mov     d1, (0x10, sp)
4842940d: 8d                    mov     d3, d1
4842940e: cd a3 f4 f0 54        call    0x484288b1, [d2,d3,a2,a3], 0x54
48429413: df c0 20              ret     [d2,d3], 0x20

FuncCall:
48429416: cf c0                 movm    [d2,d3], (sp)
48429418: f8 fe e4              add     -0x1c, sp
4842941b: 3c                    mov     sp, a0
4842941c: 20 18                 add     0x18, a0
4842941e: 87                    mov     d1, d3
4842941f: 82                    mov     d0, d2
48429420: dd 2f b6 fe ff 20 04  call    0x48414a4f, [a2], 4
48429427: 5c 34                 mov     (0x34, sp), a0
48429429: 88                    mov     d2, d0
4842942a: 43 10                 mov     a0, (0x10, sp)
4842942c: f8 bd 18              movhu   (0x18, sp), d1
4842942f: 19                    exth    d1
48429430: 46 14                 mov     d1, (0x14, sp)
48429432: 8d                    mov     d3, d1
48429433: cd 39 f6 f0 58        call    0x48428a6c, [d2,d3,a2,a3], 0x58
48429438: df c0 24              ret     [d2,d3], 0x24

GetEvent:
4842943b: f8 fe f0              add     -0x10, sp
4842943e: 3c                    mov     sp, a0
4842943f: 20 0c                 add     0xc, a0
48429441: dd 0e b6 fe ff 20 04  call    0x48414a4f, [a2], 4
48429448: f8 bc 0c              movhu   (0xc, sp), d0
4842944b: 85 38                 mov     0x38, d1
4842944d: 18                    exth    d0
4842944e: cb                    nop
4842944f: cb                    nop
48429450: f2 44                 mul     d1, d0
48429452: fc c0 7c 75 00 50     add     0x5000757c, d0
48429458: f1 e0                 mov     d0, a0
4842945a: f8 00 10              mov     (0x10, a0), d0
4842945d: df 00 10              ret     0, 0x10

GetCurrentTarget:
48429460: cf 40                 movm    [d3], (sp)
48429462: f8 fe f0              add     -0x10, sp
48429465: 83                    mov     d0, d3
48429466: af ff                 cmp     -1, d3
48429468: c8 21                 beq     0x48429489
4842946a: 3c                    mov     sp, a0
4842946b: 20 0c                 add     0xc, a0
4842946d: dd e2 b5 fe ff 20 04  call    0x48414a4f, [a2], 4
48429474: f8 bc 0c              movhu   (0xc, sp), d0
48429477: 85 38                 mov     0x38, d1
48429479: 18                    exth    d0
4842947a: cb                    nop
4842947b: cb                    nop
4842947c: f2 44                 mul     d1, d0
4842947e: fc c0 7c 75 00 50     add     0x5000757c, d0
48429484: f1 e0                 mov     d0, a0
48429486: f8 1c 10              mov     d3, (0x10, a0)
48429489: df 40 14              ret     [d3], 0x14

SetFocusParam:
4842948c: cf f0                 movm    [d2,d3,a2,a3], (sp)
4842948e: f8 fe e0              add     -0x20, sp
48429491: 83                    mov     d0, d3
48429492: 46 3c                 mov     d1, (0x3c, sp)
48429494: 3c                    mov     sp, a0
48429495: 20 18                 add     0x18, a0
48429497: dd b8 b5 fe ff 20 04  call    0x48414a4f, [a2], 4
4842949e: 8c                    mov     d3, d0
4842949f: f8 c4 10              lsr     16, d0
484294a2: 1c                    exthu   d0
484294a3: f8 c0 04              asl     4, d0
484294a6: fc c0 ac fa 11 50     add     0x5011faac, d0
484294ac: f1 e0                 mov     d0, a0
484294ae: f8 28 04              mov     (4, a0), a2
484294b1: ba 00                 cmp     0, a2
484294b3: c9 06                 bne     0x484294b9
484294b5: 00                    clr     d0
484294b6: df f0 30              ret     [d2,d3,a2,a3], 0x30
484294b9: f8 bd 18              movhu   (0x18, sp), d1
484294bc: fc ce 7c 75 00 50     mov     0x5000757c, d2
484294c2: 19                    exth    d1
484294c3: 80 38                 mov     0x38, d0
484294c5: cb                    nop
484294c6: cb                    nop
484294c7: f2 44                 mul     d1, d0
484294c9: e8                    add     d2, d0
484294ca: f1 e0                 mov     d0, a0
484294cc: f8 1c 20              mov     d3, (0x20, a0)
484294cf: 5c 3c                 mov     (0x3c, sp), a0
484294d1: 80 38                 mov     0x38, d0
484294d3: cb                    nop
484294d4: cb                    nop
484294d5: f2 44                 mul     d1, d0
484294d7: e8                    add     d2, d0
484294d8: f1 e1                 mov     d0, a1
484294da: f8 31 24              mov     a0, (0x24, a1)
484294dd: 5f 40                 mov     (0x40, sp), a3
484294df: 80 38                 mov     0x38, d0
484294e1: cb                    nop
484294e2: cb                    nop
484294e3: f2 44                 mul     d1, d0
484294e5: f1 e1                 mov     d0, a1
484294e7: f1 69                 add     d2, a1
484294e9: f8 3d 28              mov     a3, (0x28, a1)
484294ec: 80 38                 mov     0x38, d0
484294ee: cb                    nop
484294ef: cb                    nop
484294f0: f2 44                 mul     d1, d0
484294f2: f1 e0                 mov     d0, a0
484294f4: f1 68                 add     d2, a0
484294f6: f8 00 0c              mov     (0xc, a0), d0
484294f9: fc cd 00 00 06 00     mov     0x00060000, d1
484294ff: 42 14                 mov     d0, (0x14, sp)
48429501: 00                    clr     d0
48429502: 42 10                 mov     d0, (0x10, sp)
48429504: 8c                    mov     d3, d0
48429505: f0 f2                 calls   (a2)
48429507: f8 bd 18              movhu   (0x18, sp), d1
4842950a: 4e 1c                 mov     d3, (0x1c, sp)
4842950c: 19                    exth    d1
4842950d: 8f 38                 mov     0x38, d3
4842950f: cb                    nop
48429510: cb                    nop
48429511: f2 47                 mul     d1, d3
48429513: f1 ec                 mov     d3, a0
48429515: f1 68                 add     d2, a0
48429517: f8 10 0c              mov     d0, (0xc, a0)
4842951a: f8 c4 10              lsr     16, d0
4842951d: 1c                    exthu   d0
4842951e: f8 c0 04              asl     4, d0
48429521: 8f 38                 mov     0x38, d3
48429523: cb                    nop
48429524: cb                    nop
48429525: f2 47                 mul     d1, d3
48429527: f1 ec                 mov     d3, a0
48429529: f1 68                 add     d2, a0
4842952b: f8 04 0c              mov     (0xc, a0), d1
4842952e: f1 e0                 mov     d0, a0
48429530: fc d0 ac fa 11 50     add     0x5011faac, a0
48429536: f8 20 0c              mov     (0xc, a0), a0
48429539: 1d                    exthu   d1
4842953a: 80 18                 mov     0x18, d0
4842953c: cb                    nop
4842953d: cb                    nop
4842953e: f2 51                 mulu    d0, d1
48429540: f3 94                 mov     (d1, a0), a1
48429542: 00                    clr     d0
48429543: b5 00                 cmp     0, a1
48429545: c8 0a                 beq     0x4842954f
48429547: 4f 10                 mov     a3, (0x10, sp)
48429549: 59 3c                 mov     (0x3c, sp), d1
4842954b: 58 1c                 mov     (0x1c, sp), d0
4842954d: f0 f1                 calls   (a1)
4842954f: f8 bd 18              movhu   (0x18, sp), d1
48429552: 8f 38                 mov     0x38, d3
48429554: 19                    exth    d1
48429555: cb                    nop
48429556: cb                    nop
48429557: f2 4d                 mul     d3, d1
48429559: e6                    add     d1, d2
4842955a: 59 14                 mov     (0x14, sp), d1
4842955c: f1 e8                 mov     d2, a0
4842955e: f8 14 0c              mov     d1, (0xc, a0)
48429561: df f0 30              ret     [d2,d3,a2,a3], 0x30

ObjectProc:
48429564: cf f0                 movm    [d2,d3,a2,a3], (sp)
48429566: f8 fe e8              add     -0x18, sp
48429569: 3c                    mov     sp, a0
4842956a: 46 34                 mov     d1, (0x34, sp)
4842956c: 42 30                 mov     d0, (0x30, sp)
4842956e: 20 14                 add     0x14, a0
48429570: dd df b4 fe ff 20 04  call    0x48414a4f, [a2], 4
48429577: f8 bf 14              movhu   (0x14, sp), d3
4842957a: fc de 7c 75 00 50     mov     0x5000757c, a2
48429580: 1b                    exth    d3
48429581: 80 38                 mov     0x38, d0
48429583: cb                    nop
48429584: cb                    nop
48429585: f2 4c                 mul     d3, d0
48429587: f1 58                 add     a2, d0
48429589: f1 e0                 mov     d0, a0
4842958b: f8 04 0c              mov     (0xc, a0), d1
4842958e: 80 38                 mov     0x38, d0
48429590: cb                    nop
48429591: cb                    nop
48429592: f2 4c                 mul     d3, d0
48429594: f1 e0                 mov     d0, a0
48429596: f1 78                 add     a2, a0
48429598: f8 00 0c              mov     (0xc, a0), d0
4842959b: f8 c5 10              lsr     16, d1
4842959e: 1d                    exthu   d1
4842959f: f8 c1 04              asl     4, d1
484295a2: f1 e4                 mov     d1, a0
484295a4: fc dd ac fa 11 50     mov     0x5011faac, a1
484295aa: f1 74                 add     a1, a0
484295ac: f8 20 0c              mov     (0xc, a0), a0
484295af: 1c                    exthu   d0
484295b0: 85 18                 mov     0x18, d1
484295b2: cb                    nop
484295b3: cb                    nop
484295b4: f2 54                 mulu    d1, d0
484295b6: f1 60                 add     d0, a0
484295b8: f8 08 04              mov     (4, a0), d2
484295bb: 00                    clr     d0
484295bc: aa ff                 cmp     -1, d2
484295be: c8 4b                 beq     0x48429609
484295c0: 80 38                 mov     0x38, d0
484295c2: cb                    nop
484295c3: cb                    nop
484295c4: f2 4c                 mul     d3, d0
484295c6: f1 e0                 mov     d0, a0
484295c8: f1 78                 add     a2, a0
484295ca: f8 2c 0c              mov     (0xc, a0), a3
484295cd: 80 38                 mov     0x38, d0
484295cf: cb                    nop
484295d0: cb                    nop
484295d1: f2 43                 mul     d0, d3
484295d3: f1 5b                 add     a2, d3
484295d5: f1 ec                 mov     d3, a0
484295d7: f8 18 0c              mov     d2, (0xc, a0)
484295da: 88                    mov     d2, d0
484295db: f8 c4 10              lsr     16, d0
484295de: 1c                    exthu   d0
484295df: f8 c0 04              asl     4, d0
484295e2: f1 61                 add     d0, a1
484295e4: f8 21 0c              mov     (0xc, a1), a0
484295e7: 1e                    exthu   d2
484295e8: cb                    nop
484295e9: cb                    nop
484295ea: f2 56                 mulu    d1, d2
484295ec: f3 98                 mov     (d2, a0), a1
484295ee: 5c 38                 mov     (0x38, sp), a0
484295f0: 8a 38                 mov     0x38, d2
484295f2: 43 10                 mov     a0, (0x10, sp)
484295f4: 58 30                 mov     (0x30, sp), d0
484295f6: 59 34                 mov     (0x34, sp), d1
484295f8: f0 f1                 calls   (a1)
484295fa: f8 bd 14              movhu   (0x14, sp), d1
484295fd: 19                    exth    d1
484295fe: cb                    nop
484295ff: cb                    nop
48429600: f2 49                 mul     d2, d1
48429602: f1 59                 add     a2, d1
48429604: f1 e4                 mov     d1, a0
48429606: f8 3c 0c              mov     a3, (0xc, a0)
48429609: df f0 28              ret     [d2,d3,a2,a3], 0x28

KillApTimer:
4842960c: f8 fe f0              add     -0x10, sp
4842960f: 3c                    mov     sp, a0
48429610: 20 0c                 add     0xc, a0
48429612: dd 3d b4 fe ff 20 04  call    0x48414a4f, [a2], 4
48429619: f8 bc 0c              movhu   (0xc, sp), d0
4842961c: 85 38                 mov     0x38, d1
4842961e: 18                    exth    d0
4842961f: cb                    nop
48429620: cb                    nop
48429621: f2 44                 mul     d1, d0
48429623: fc c0 7c 75 00 50     add     0x5000757c, d0
48429629: f1 e0                 mov     d0, a0
4842962b: f8 00 14              mov     (0x14, a0), d0
4842962e: df 00 10              ret     0, 0x10

GetRootObject:
48429631: f8 fe f0              add     -0x10, sp
48429634: 3c                    mov     sp, a0
48429635: 20 0c                 add     0xc, a0
48429637: dd 18 b4 fe ff 20 04  call    0x48414a4f, [a2], 4
4842963e: f8 bc 0c              movhu   (0xc, sp), d0
48429641: 85 38                 mov     0x38, d1
48429643: 18                    exth    d0
48429644: cb                    nop
48429645: cb                    nop
48429646: f2 44                 mul     d1, d0
48429648: fc c0 7c 75 00 50     add     0x5000757c, d0
4842964e: f1 e0                 mov     d0, a0
48429650: f8 00 18              mov     (0x18, a0), d0
48429653: df 00 10              ret     0, 0x10

GetRootEvent:
48429656: f8 fe f0              add     -0x10, sp
48429659: 3c                    mov     sp, a0
4842965a: 20 0c                 add     0xc, a0
4842965c: dd f3 b3 fe ff 20 04  call    0x48414a4f, [a2], 4
48429663: f8 bc 0c              movhu   (0xc, sp), d0
48429666: 85 38                 mov     0x38, d1
48429668: 18                    exth    d0
48429669: cb                    nop
4842966a: cb                    nop
4842966b: f2 44                 mul     d1, d0
4842966d: fc c0 7c 75 00 50     add     0x5000757c, d0
48429673: f1 e0                 mov     d0, a0
48429675: f8 00 1c              mov     (0x1c, a0), d0
48429678: df 00 10              ret     0, 0x10

SetAutoInc:
4842967b: cf 40                 movm    [d3], (sp)
4842967d: f8 fe f0              add     -0x10, sp
48429680: 3c                    mov     sp, a0
48429681: 20 0c                 add     0xc, a0
48429683: 83                    mov     d0, d3
48429684: dd cb b3 fe ff 20 04  call    0x48414a4f, [a2], 4
4842968b: f8 bc 0c              movhu   (0xc, sp), d0
4842968e: 85 38                 mov     0x38, d1
48429690: 18                    exth    d0
48429691: cb                    nop
48429692: cb                    nop
48429693: f2 44                 mul     d1, d0
48429695: fc c0 7c 75 00 50     add     0x5000757c, d0
4842969b: f1 e0                 mov     d0, a0
4842969d: f8 1c 14              mov     d3, (0x14, a0)
484296a0: df 40 14              ret     [d3], 0x14

InitDrawTask:
484296a3: cf 40                 movm    [d3], (sp)
484296a5: f8 fe f0              add     -0x10, sp
484296a8: 3c                    mov     sp, a0
484296a9: 20 0c                 add     0xc, a0
484296ab: 83                    mov     d0, d3
484296ac: dd a3 b3 fe ff 20 04  call    0x48414a4f, [a2], 4
484296b3: f8 bc 0c              movhu   (0xc, sp), d0
484296b6: 85 38                 mov     0x38, d1
484296b8: 18                    exth    d0
484296b9: cb                    nop
484296ba: cb                    nop
484296bb: f2 44                 mul     d1, d0
484296bd: fc c0 7c 75 00 50     add     0x5000757c, d0
484296c3: f1 e0                 mov     d0, a0
484296c5: f8 1c 18              mov     d3, (0x18, a0)
484296c8: df 40 14              ret     [d3], 0x14

SetRootEvent:
484296cb: cf 40                 movm    [d3], (sp)
484296cd: f8 fe f0              add     -0x10, sp
484296d0: 3c                    mov     sp, a0
484296d1: 20 0c                 add     0xc, a0
484296d3: 83                    mov     d0, d3
484296d4: dd 7b b3 fe ff 20 04  call    0x48414a4f, [a2], 4
484296db: f8 bc 0c              movhu   (0xc, sp), d0
484296de: 85 38                 mov     0x38, d1
484296e0: 18                    exth    d0
484296e1: cb                    nop
484296e2: cb                    nop
484296e3: f2 44                 mul     d1, d0
484296e5: fc c0 7c 75 00 50     add     0x5000757c, d0
484296eb: f1 e0                 mov     d0, a0
484296ed: f8 1c 1c              mov     d3, (0x1c, a0)
484296f0: df 40 14              ret     [d3], 0x14

SetRootObject:
484296f3: f8 fe f0              add     -0x10, sp
484296f6: 3c                    mov     sp, a0
484296f7: 20 0c                 add     0xc, a0
484296f9: dd 56 b3 fe ff 20 04  call    0x48414a4f, [a2], 4
48429700: f8 bc 0c              movhu   (0xc, sp), d0
48429703: 85 38                 mov     0x38, d1
48429705: 18                    exth    d0
48429706: cb                    nop
48429707: cb                    nop
48429708: f2 44                 mul     d1, d0
4842970a: fc c0 7c 75 00 50     add     0x5000757c, d0
48429710: f1 e0                 mov     d0, a0
48429712: f8 00 20              mov     (0x20, a0), d0
48429715: df 00 10              ret     0, 0x10

GetFocusObject:
48429718: f8 fe f0              add     -0x10, sp
4842971b: 3c                    mov     sp, a0
4842971c: 20 0c                 add     0xc, a0
4842971e: dd 31 b3 fe ff 20 04  call    0x48414a4f, [a2], 4
48429725: f8 bc 0c              movhu   (0xc, sp), d0
48429728: 85 38                 mov     0x38, d1
4842972a: 18                    exth    d0
4842972b: cb                    nop
4842972c: cb                    nop
4842972d: f2 44                 mul     d1, d0
4842972f: fc c0 7c 75 00 50     add     0x5000757c, d0
48429735: f1 e0                 mov     d0, a0
48429737: f8 00 24              mov     (0x24, a0), d0
4842973a: df 00 10              ret     0, 0x10

GetFocusEvent:
4842973d: f8 fe f0              add     -0x10, sp
48429740: 3c                    mov     sp, a0
48429741: 20 0c                 add     0xc, a0
48429743: dd 0c b3 fe ff 20 04  call    0x48414a4f, [a2], 4
4842974a: f8 bc 0c              movhu   (0xc, sp), d0
4842974d: 85 38                 mov     0x38, d1
4842974f: 18                    exth    d0
48429750: cb                    nop
48429751: cb                    nop
48429752: f2 44                 mul     d1, d0
48429754: fc c0 7c 75 00 50     add     0x5000757c, d0
4842975a: f1 e0                 mov     d0, a0
4842975c: f8 00 28              mov     (0x28, a0), d0
4842975f: df 00 10              ret     0, 0x10

GetPaletteRGB:
48429762: cf 40                 movm    [d3], (sp)
48429764: f8 fe f0              add     -0x10, sp
48429767: 3c                    mov     sp, a0
48429768: 20 0c                 add     0xc, a0
4842976a: 83                    mov     d0, d3
4842976b: dd e4 b2 fe ff 20 04  call    0x48414a4f, [a2], 4
48429772: f8 bc 0c              movhu   (0xc, sp), d0
48429775: 85 38                 mov     0x38, d1
48429777: 18                    exth    d0
48429778: cb                    nop
48429779: cb                    nop
4842977a: f2 44                 mul     d1, d0
4842977c: fc c0 7c 75 00 50     add     0x5000757c, d0
48429782: f1 e0                 mov     d0, a0
48429784: f8 1c 20              mov     d3, (0x20, a0)
48429787: df 40 14              ret     [d3], 0x14

SetFocusObject:
4842978a: cf 40                 movm    [d3], (sp)
4842978c: f8 fe f0              add     -0x10, sp
4842978f: 3c                    mov     sp, a0
48429790: 20 0c                 add     0xc, a0
48429792: 83                    mov     d0, d3
48429793: dd bc b2 fe ff 20 04  call    0x48414a4f, [a2], 4
4842979a: f8 bc 0c              movhu   (0xc, sp), d0
4842979d: 85 38                 mov     0x38, d1
4842979f: 18                    exth    d0
484297a0: cb                    nop
484297a1: cb                    nop
484297a2: f2 44                 mul     d1, d0
484297a4: fc c0 7c 75 00 50     add     0x5000757c, d0
484297aa: f1 e0                 mov     d0, a0
484297ac: f8 1c 24              mov     d3, (0x24, a0)
484297af: df 40 14              ret     [d3], 0x14

SetFocusEvent:
484297b2: cf 40                 movm    [d3], (sp)
484297b4: f8 fe f0              add     -0x10, sp
484297b7: 3c                    mov     sp, a0
484297b8: 20 0c                 add     0xc, a0
484297ba: 83                    mov     d0, d3
484297bb: dd 94 b2 fe ff 20 04  call    0x48414a4f, [a2], 4
484297c2: f8 bc 0c              movhu   (0xc, sp), d0
484297c5: 85 38                 mov     0x38, d1
484297c7: 18                    exth    d0
484297c8: cb                    nop
484297c9: cb                    nop
484297ca: f2 44                 mul     d1, d0
484297cc: fc c0 7c 75 00 50     add     0x5000757c, d0
484297d2: f1 e0                 mov     d0, a0
484297d4: f8 1c 28              mov     d3, (0x28, a0)
484297d7: df 40 14              ret     [d3], 0x14

SetCurrentTarget:
484297da: f8 fe f4           add     -0xc, sp
484297dd: fc ac 60 3c 0d 50  movhu   (0x500d3c60), d0
484297e3: 18                 exth    d0
484297e4: cd 5f f4 f0 44     call    0x48428c43, [d2,d3,a2,a3], 0x44
484297e9: df 00 0c           ret     0, 0xc

MainDispatchEvent:
484297ec: cf 80              movm    [d2], (sp)
484297ee: f8 fe e8           add     -0x18, sp
484297f1: 5c 2c              mov     (0x2c, sp), a0
484297f3: 82                 mov     d0, d2
484297f4: 43 10              mov     a0, (0x10, sp)
484297f6: fc ac 60 3c 0d 50  movhu   (0x500d3c60), d0
484297fc: 18                 exth    d0
484297fd: 42 14              mov     d0, (0x14, sp)
484297ff: 88                 mov     d2, d0
48429800: cd 55 ed f0 28     call    0x48428555, [d2,d3,a2,a3], 0x28
48429805: df 80 1c           ret     [d2], 0x1c

MainSendEvent:
48429808: cf 80              movm    [d2], (sp)
4842980a: f8 fe e8           add     -0x18, sp
4842980d: 5c 2c              mov     (0x2c, sp), a0
4842980f: 82                 mov     d0, d2
48429810: 43 10              mov     a0, (0x10, sp)
48429812: fc ac 60 3c 0d 50  movhu   (0x500d3c60), d0
48429818: 18                 exth    d0
48429819: 42 14              mov     d0, (0x14, sp)
4842981b: 88                 mov     d2, d0
4842981c: cd c8 ed f0 38     call    0x484285e4, [d2,d3,a2,a3], 0x38
48429821: df 80 1c           ret     [d2], 0x1c

MainPostEvent:
48429824: f8 fe e8           add     -0x18, sp
48429827: 81                 mov     d0, d1
48429828: fc ac 60 3c 0d 50  movhu   (0x500d3c60), d0
4842982e: 18                 exth    d0
4842982f: cd 63 ef f0 2c     call    0x48428792, [d2,d3,a2,a3], 0x2c
48429834: 80 01              mov     1, d0
48429836: df 00 18           ret     0, 0x18

MainDeleteSpecificEvent:
48429839: cf 80              movm    [d2], (sp)
4842983b: f8 fe ec           add     -0x14, sp
4842983e: 82                 mov     d0, d2
4842983f: fc ac 60 3c 0d 50  movhu   (0x500d3c60), d0
48429845: 18                 exth    d0
48429846: 42 10              mov     d0, (0x10, sp)
48429848: 88                 mov     d2, d0
48429849: cd 68 f0 f0 54     call    0x484288b1, [d2,d3,a2,a3], 0x54
4842984e: df 80 18           ret     [d2], 0x18

DrawFunc:
48429851: cf 80              movm    [d2], (sp)
48429853: f8 fe e8           add     -0x18, sp
48429856: 5c 2c              mov     (0x2c, sp), a0
48429858: 82                 mov     d0, d2
48429859: 43 10              mov     a0, (0x10, sp)
4842985b: fc ac 60 3c 0d 50  movhu   (0x500d3c60), d0
48429861: 18                 exth    d0
48429862: 42 14              mov     d0, (0x14, sp)
48429864: 88                 mov     d2, d0
48429865: cd 07 f2 f0 58     call    0x48428a6c, [d2,d3,a2,a3], 0x58
4842986a: df 80 1c           ret     [d2], 0x1c

MainAddM3Em:
4842986d: f8 fe f4           add     -0xc, sp
48429870: fc ac 5c 3c 0d 50  movhu   (0x500d3c5c), d0
48429876: 18                 exth    d0
48429877: cd cc f3 f0 44     call    0x48428c43, [d2,d3,a2,a3], 0x44
4842987c: df 00 0c           ret     0, 0xc

ApDispatchEvent:
4842987f: cf 80              movm    [d2], (sp)
48429881: f8 fe e8           add     -0x18, sp
48429884: 5c 2c              mov     (0x2c, sp), a0
48429886: 82                 mov     d0, d2
48429887: 43 10              mov     a0, (0x10, sp)
48429889: fc ac 5c 3c 0d 50  movhu   (0x500d3c5c), d0
4842988f: 18                 exth    d0
48429890: 42 14              mov     d0, (0x14, sp)
48429892: 88                 mov     d2, d0
48429893: cd c2 ec f0 28     call    0x48428555, [d2,d3,a2,a3], 0x28
48429898: df 80 1c           ret     [d2], 0x1c

MainGetEvent:
4842989b: cf 80              movm    [d2], (sp)
4842989d: f8 fe e8           add     -0x18, sp
484298a0: 5c 2c              mov     (0x2c, sp), a0
484298a2: 82                 mov     d0, d2
484298a3: 43 10              mov     a0, (0x10, sp)
484298a5: fc ac 5c 3c 0d 50  movhu   (0x500d3c5c), d0
484298ab: 18                 exth    d0
484298ac: 42 14              mov     d0, (0x14, sp)
484298ae: 88                 mov     d2, d0
484298af: cd 35 ed f0 38     call    0x484285e4, [d2,d3,a2,a3], 0x38
484298b4: df 80 1c           ret     [d2], 0x1c

RefreshApTask:
484298b7: cf e0                 movm    [d2,d3,a2], (sp)
484298b9: f8 fe ec              add     -0x14, sp
484298bc: 87                    mov     d1, d3
484298bd: 82                    mov     d0, d2
484298be: aa ff                 cmp     -1, d2
484298c0: c9 0d                 bne     0x484298cd
484298c2: 5c 30                 mov     (0x30, sp), a0
484298c4: 43 10                 mov     a0, (0x10, sp)
484298c6: cd da ff 80 1c        call    0x484298a0, [d2], 0x1c
484298cb: ca 33                 bra     0x484298fe
484298cd: 80 0c                 mov     0xc, d0
484298cf: dd 5b cd fe ff b0 28  call    0x4841662a, [d2,a2,a3], 0x28
484298d6: 92                    mov     a0, a2
484298d7: 6a                    mov     d2, (a2)
484298d8: f8 1e 04              mov     d3, (4, a2)
484298db: 5d 30                 mov     (0x30, sp), a1
484298dd: 80 ff                 mov     -1, d0
484298df: f8 36 08              mov     a1, (8, a2)
484298e2: 43 10                 mov     a0, (0x10, sp)
484298e4: fc cd 2f 00 05 00     mov     0x0005002f, d1
484298ea: cd b6 ff 80 1c        call    0x484298a0, [d2], 0x1c
484298ef: 4b 10                 mov     a2, (0x10, sp)
484298f1: 80 ff                 mov     -1, d0
484298f3: fc cd 23 00 06 00     mov     0x00060023, d1
484298f9: cd a7 ff 80 1c        call    0x484298a0, [d2], 0x1c
484298fe: df e0 20              ret     [d2,d3,a2], 0x20

ApSendEvent:
48429901: cf 80              movm    [d2], (sp)
48429903: f8 fe ec           add     -0x14, sp
48429906: 82                 mov     d0, d2
48429907: fc ac 5c 3c 0d 50  movhu   (0x500d3c5c), d0
4842990d: 18                 exth    d0
4842990e: 42 10              mov     d0, (0x10, sp)
48429910: 88                 mov     d2, d0
48429911: cd a0 ef f0 54     call    0x484288b1, [d2,d3,a2,a3], 0x54
48429916: df 80 18           ret     [d2], 0x18

ApDeleteEvent:
48429919: cf 80              movm    [d2], (sp)
4842991b: f8 fe e8           add     -0x18, sp
4842991e: 5c 2c              mov     (0x2c, sp), a0
48429920: 82                 mov     d0, d2
48429921: 43 10              mov     a0, (0x10, sp)
48429923: fc ac 5c 3c 0d 50  movhu   (0x500d3c5c), d0
48429929: 18                 exth    d0
4842992a: 42 14              mov     d0, (0x14, sp)
4842992c: 88                 mov     d2, d0
4842992d: cd 3f f1 f0 58     call    0x48428a6c, [d2,d3,a2,a3], 0x58
48429932: df 80 1c           ret     [d2], 0x1c

PsWideToggleProc:
48429935: cf 80           movm    [d2], (sp)
48429937: f8 fe f4        add     -0xc, sp
4842993a: 00              clr     d0
4842993b: 08              clr     d2
4842993c: 18              exth    d0
4842993d: cd 14 00 f0 14  call    0x48429951, [d2,d3,a2,a3], 0x14
48429942: 48              inc     d2
48429943: 88              mov     d2, d0
48429944: 1e              exthu   d2
48429945: aa 04           cmp     4, d2
48429947: c0 f5           blt     0x4842993c
48429949: df 80 10        ret     [d2], 0x10

SetMmmFilter:
4842994c: cf f0              movm    [d2,d3,a2,a3], (sp)
4842994e: f8 fe fc           add     -4, sp
48429951: 83                 mov     d0, d3
48429952: 1b                 exth    d3
48429953: 8c                 mov     d3, d0
48429954: 54                 asl2    d0
48429955: 04                 clr     d1
48429956: fc dc 8c fa 11 50  mov     0x5011fa8c, a0
4842995c: f3 50              mov     d1, (d0, a0)
4842995e: fc dd 7c 75 00 50  mov     0x5000757c, a1
48429964: 80 38              mov     0x38, d0
48429966: cb                 nop
48429967: cb                 nop
48429968: f2 4c              mul     d3, d0
4842996a: f1 e0              mov     d0, a0
4842996c: f1 74              add     a1, a0
4842996e: 80 ff              mov     -1, d0
48429970: f8 70 30           movhu   d0, (0x30, a0)
48429973: 80 38              mov     0x38, d0
48429975: cb                 nop
48429976: cb                 nop
48429977: f2 4c              mul     d3, d0
48429979: f1 54              add     a1, d0
4842997b: f1 e0              mov     d0, a0
4842997d: f8 64 32           movhu   (0x32, a0), d1
48429980: 08                 clr     d2
48429981: 19                 exth    d1
48429982: a9                 cmp     d2, d1
48429983: 9a 00              mov     0, a2
48429985: c3 69              ble     0x484299ee
48429987: 80 38              mov     0x38, d0
48429989: cb                 nop
4842998a: cb                 nop
4842998b: f2 4c              mul     d3, d0
4842998d: f1 54              add     a1, d0
4842998f: 28 34              add     0x34, d0
48429991: 42 00              mov     d0, (0, sp)
48429993: 80 38              mov     0x38, d0
48429995: cb                 nop
48429996: cb                 nop
48429997: f2 4c              mul     d3, d0
48429999: f1 d5              mov     a1, d1
4842999b: e1                 add     d0, d1
4842999c: 29 34              add     0x34, d1
4842999e: 80 38              mov     0x38, d0
484299a0: cb                 nop
484299a1: cb                 nop
484299a2: f2 4c              mul     d3, d0
484299a4: f1 54              add     a1, d0
484299a6: 9f 34              mov     0x34, a3
484299a8: f1 63              add     d0, a3
484299aa: 80 38              mov     0x38, d0
484299ac: cb                 nop
484299ad: cb                 nop
484299ae: f2 43              mul     d0, d3
484299b0: f1 d4              mov     a1, d0
484299b2: ec                 add     d3, d0
484299b3: 95 32              mov     0x32, a1
484299b5: f1 61              add     d0, a1
484299b7: db                 setlb
484299b8: 8f ff              mov     -1, d3
484299ba: 5c 00              mov     (0, sp), a0
484299bc: 1e                 exthu   d2
484299bd: f0 00              mov     (a0), a0
484299bf: 80 18              mov     0x18, d0
484299c1: cb                 nop
484299c2: cb                 nop
484299c3: f2 58              mulu    d2, d0
484299c5: f4                 movhu   d3, (d0, a0)
484299c6: f0 f1              calls   (a1)
484299c8: e4                 add     d1, d0
484299c9: f0 00              mov     (a0), a0
484299cb: 80 18              mov     0x18, d0
484299cd: cb                 nop
484299ce: cb                 nop
484299cf: f2 58              mulu    d2, d0
484299d1: f1 60              add     d0, a0
484299d3: f8 7c 02           movhu   d3, (2, a0)
484299d6: f0 03              mov     (a3), a0
484299d8: 80 18              mov     0x18, d0
484299da: cb                 nop
484299db: cb                 nop
484299dc: f2 52              mulu    d0, d2
484299de: f1 68              add     d2, a0
484299e0: f8 1c 08           mov     d3, (8, a0)
484299e3: f0 61              movhu   (a1), d0
484299e5: f1 da              mov     a2, d2
484299e7: 48                 inc     d2
484299e8: 1e                 exthu   d2
484299e9: f1 ea              mov     d2, a2
484299eb: 18                 exth    d0
484299ec: a2                 cmp     d0, d2
484299ed: d0                 llt
484299ee: df f0 14           ret     [d2,d3,a2,a3], 0x14

InitializeTimer:
484299f1: cf f0                 movm    [d2,d3,a2,a3], (sp)
484299f3: f8 fe e0              add     -0x20, sp
484299f6: 3c                    mov     sp, a0
484299f7: 20 1c                 add     0x1c, a0
484299f9: dd 56 b0 fe ff 20 04  call    0x48414a4f, [a2], 4
48429a00: f8 be 1c              movhu   (0x1c, sp), d2
48429a03: fc cf 7c 75 00 50     mov     0x5000757c, d3
48429a09: 1a                    exth    d2
48429a0a: 80 38                 mov     0x38, d0
48429a0c: cb                    nop
48429a0d: cb                    nop
48429a0e: f2 48                 mul     d2, d0
48429a10: ec                    add     d3, d0
48429a11: f1 e0                 mov     d0, a0
48429a13: f8 60 30              movhu   (0x30, a0), d0
48429a16: 18                    exth    d0
48429a17: a0 ff                 cmp     -1, d0
48429a19: c9 05                 bne     0x48429a1e
48429a1b: cc 69 02              jmp     0x48429c84
48429a1e: 80 38                 mov     0x38, d0
48429a20: cb                    nop
48429a21: cb                    nop
48429a22: f2 48                 mul     d2, d0
48429a24: ec                    add     d3, d0
48429a25: f1 e0                 mov     d0, a0
48429a27: f8 20 34              mov     (0x34, a0), a0
48429a2a: 80 38                 mov     0x38, d0
48429a2c: cb                    nop
48429a2d: cb                    nop
48429a2e: f2 48                 mul     d2, d0
48429a30: ec                    add     d3, d0
48429a31: f1 e1                 mov     d0, a1
48429a33: f8 61 30              movhu   (0x30, a1), d0
48429a36: 85 18                 mov     0x18, d1
48429a38: 18                    exth    d0
48429a39: cb                    nop
48429a3a: cb                    nop
48429a3b: f2 44                 mul     d1, d0
48429a3d: f1 60                 add     d0, a0
48429a3f: f8 04 04              mov     (4, a0), d1
48429a42: 88                    mov     d2, d0
48429a43: 54                    asl2    d0
48429a44: fc dc 8c fa 11 50     mov     0x5011fa8c, a0
48429a4a: f3 00                 mov     (d0, a0), d0
48429a4c: a1                    cmp     d0, d1
48429a4d: c7 05                 bls     0x48429a52
48429a4f: cc 35 02              jmp     0x48429c84
48429a52: 80 38                 mov     0x38, d0
48429a54: cb                    nop
48429a55: cb                    nop
48429a56: f2 48                 mul     d2, d0
48429a58: ec                    add     d3, d0
48429a59: f1 e1                 mov     d0, a1
48429a5b: f8 65 30              movhu   (0x30, a1), d1
48429a5e: 80 18                 mov     0x18, d0
48429a60: 19                    exth    d1
48429a61: cb                    nop
48429a62: cb                    nop
48429a63: f2 41                 mul     d0, d1
48429a65: 80 38                 mov     0x38, d0
48429a67: cb                    nop
48429a68: cb                    nop
48429a69: f2 48                 mul     d2, d0
48429a6b: f1 e1                 mov     d0, a1
48429a6d: f1 6d                 add     d3, a1
48429a6f: 80 38                 mov     0x38, d0
48429a71: cb                    nop
48429a72: cb                    nop
48429a73: f2 48                 mul     d2, d0
48429a75: ec                    add     d3, d0
48429a76: f1 e0                 mov     d0, a0
48429a78: 80 38                 mov     0x38, d0
48429a7a: cb                    nop
48429a7b: cb                    nop
48429a7c: f2 48                 mul     d2, d0
48429a7e: ec                    add     d3, d0
48429a7f: f8 20 34              mov     (0x34, a0), a0
48429a82: f1 64                 add     d1, a0
48429a84: 85 18                 mov     0x18, d1
48429a86: f8 2c 0c              mov     (0xc, a0), a3
48429a89: f1 e0                 mov     d0, a0
48429a8b: f8 20 34              mov     (0x34, a0), a0
48429a8e: f8 61 30              movhu   (0x30, a1), d0
48429a91: 18                    exth    d0
48429a92: cb                    nop
48429a93: cb                    nop
48429a94: f2 44                 mul     d1, d0
48429a96: f1 60                 add     d0, a0
48429a98: f8 00 10              mov     (0x10, a0), d0
48429a9b: 42 14                 mov     d0, (0x14, sp)
48429a9d: 80 38                 mov     0x38, d0
48429a9f: cb                    nop
48429aa0: cb                    nop
48429aa1: f2 48                 mul     d2, d0
48429aa3: ec                    add     d3, d0
48429aa4: f1 e0                 mov     d0, a0
48429aa6: f8 24 34              mov     (0x34, a0), a1
48429aa9: 80 38                 mov     0x38, d0
48429aab: cb                    nop
48429aac: cb                    nop
48429aad: f2 48                 mul     d2, d0
48429aaf: f1 e0                 mov     d0, a0
48429ab1: f1 6c                 add     d3, a0
48429ab3: f8 60 30              movhu   (0x30, a0), d0
48429ab6: 18                    exth    d0
48429ab7: cb                    nop
48429ab8: cb                    nop
48429ab9: f2 44                 mul     d1, d0
48429abb: f1 61                 add     d0, a1
48429abd: f8 29 14              mov     (0x14, a1), a2
48429ac0: fc db ff ff ff ff     cmp     0xffffffff, a3
48429ac6: c9 0e                 bne     0x48429ad4
48429ac8: 80 38                 mov     0x38, d0
48429aca: cb                    nop
48429acb: cb                    nop
48429acc: f2 48                 mul     d2, d0
48429ace: ec                    add     d3, d0
48429acf: f1 e0                 mov     d0, a0
48429ad1: f8 2c 10              mov     (0x10, a0), a3
48429ad4: 80 38                 mov     0x38, d0
48429ad6: cb                    nop
48429ad7: cb                    nop
48429ad8: f2 48                 mul     d2, d0
48429ada: f1 e0                 mov     d0, a0
48429adc: f1 6c                 add     d3, a0
48429ade: f8 24 34              mov     (0x34, a0), a1
48429ae1: 80 38                 mov     0x38, d0
48429ae3: cb                    nop
48429ae4: cb                    nop
48429ae5: f2 48                 mul     d2, d0
48429ae7: f1 e0                 mov     d0, a0
48429ae9: f1 6c                 add     d3, a0
48429aeb: f8 60 30              movhu   (0x30, a0), d0
48429aee: 18                    exth    d0
48429aef: cb                    nop
48429af0: cb                    nop
48429af1: f2 44                 mul     d1, d0
48429af3: f1 61                 add     d0, a1
48429af5: f8 61 02              movhu   (2, a1), d0
48429af8: f8 93 18              movhu   d0, (0x18, sp)
48429afb: 80 38                 mov     0x38, d0
48429afd: cb                    nop
48429afe: cb                    nop
48429aff: f2 48                 mul     d2, d0
48429b01: ec                    add     d3, d0
48429b02: f1 e0                 mov     d0, a0
48429b04: f8 24 34              mov     (0x34, a0), a1
48429b07: 80 38                 mov     0x38, d0
48429b09: cb                    nop
48429b0a: cb                    nop
48429b0b: f2 48                 mul     d2, d0
48429b0d: f1 e0                 mov     d0, a0
48429b0f: f1 6c                 add     d3, a0
48429b11: f8 60 30              movhu   (0x30, a0), d0
48429b14: 18                    exth    d0
48429b15: cb                    nop
48429b16: cb                    nop
48429b17: f2 44                 mul     d1, d0
48429b19: 85 ff                 mov     -1, d1
48429b1b: f4                    movhu   d1, (d0, a1)
48429b1c: d1                    lgt
48429b1d: f8 bc 1c              movhu   (0x1c, sp), d0
48429b20: 85 38                 mov     0x38, d1
48429b22: 18                    exth    d0
48429b23: cb                    nop
48429b24: cb                    nop
48429b25: f2 44                 mul     d1, d0
48429b27: ec                    add     d3, d0
48429b28: f1 e0                 mov     d0, a0
48429b2a: f8 bc 1c              movhu   (0x1c, sp), d0
48429b2d: f8 20 34              mov     (0x34, a0), a0
48429b30: 18                    exth    d0
48429b31: cb                    nop
48429b32: cb                    nop
48429b33: f2 44                 mul     d1, d0
48429b35: ec                    add     d3, d0
48429b36: f1 e1                 mov     d0, a1
48429b38: f8 65 30              movhu   (0x30, a1), d1
48429b3b: 80 18                 mov     0x18, d0
48429b3d: 19                    exth    d1
48429b3e: cb                    nop
48429b3f: cb                    nop
48429b40: f2 41                 mul     d0, d1
48429b42: f1 64                 add     d1, a0
48429b44: 80 ff                 mov     -1, d0
48429b46: f8 70 02              movhu   d0, (2, a0)
48429b49: f8 bc 1c              movhu   (0x1c, sp), d0
48429b4c: 85 38                 mov     0x38, d1
48429b4e: 18                    exth    d0
48429b4f: cb                    nop
48429b50: cb                    nop
48429b51: f2 44                 mul     d1, d0
48429b53: ec                    add     d3, d0
48429b54: f1 e0                 mov     d0, a0
48429b56: f8 bc 1c              movhu   (0x1c, sp), d0
48429b59: f8 20 34              mov     (0x34, a0), a0
48429b5c: 18                    exth    d0
48429b5d: cb                    nop
48429b5e: cb                    nop
48429b5f: f2 44                 mul     d1, d0
48429b61: ec                    add     d3, d0
48429b62: f1 e1                 mov     d0, a1
48429b64: f8 61 30              movhu   (0x30, a1), d0
48429b67: 85 18                 mov     0x18, d1
48429b69: 18                    exth    d0
48429b6a: cb                    nop
48429b6b: cb                    nop
48429b6c: f2 44                 mul     d1, d0
48429b6e: f1 60                 add     d0, a0
48429b70: 80 ff                 mov     -1, d0
48429b72: f8 10 08              mov     d0, (8, a0)
48429b75: f8 be 1c              movhu   (0x1c, sp), d2
48429b78: f8 bd 18              movhu   (0x18, sp), d1
48429b7b: 1a                    exth    d2
48429b7c: 80 38                 mov     0x38, d0
48429b7e: cb                    nop
48429b7f: cb                    nop
48429b80: f2 48                 mul     d2, d0
48429b82: ec                    add     d3, d0
48429b83: f1 e0                 mov     d0, a0
48429b85: f8 74 30              movhu   d1, (0x30, a0)
48429b88: fc db ff ff ff ff     cmp     0xffffffff, a3
48429b8e: c9 3d                 bne     0x48429bcb
48429b90: 80 38                 mov     0x38, d0
48429b92: cb                    nop
48429b93: cb                    nop
48429b94: f2 48                 mul     d2, d0
48429b96: ec                    add     d3, d0
48429b97: f1 e0                 mov     d0, a0
48429b99: f8 64 30              movhu   (0x30, a0), d1
48429b9c: 19                    exth    d1
48429b9d: a5 ff                 cmp     -1, d1
48429b9f: c9 05                 bne     0x48429ba4
48429ba1: cc e3 00              jmp     0x48429c84
48429ba4: 80 38                 mov     0x38, d0
48429ba6: cb                    nop
48429ba7: cb                    nop
48429ba8: f2 48                 mul     d2, d0
48429baa: f1 e0                 mov     d0, a0
48429bac: f1 6c                 add     d3, a0
48429bae: f8 20 34              mov     (0x34, a0), a0
48429bb1: 80 38                 mov     0x38, d0
48429bb3: cb                    nop
48429bb4: cb                    nop
48429bb5: f2 42                 mul     d0, d2
48429bb7: ee                    add     d3, d2
48429bb8: f1 e9                 mov     d2, a1
48429bba: f8 65 30              movhu   (0x30, a1), d1
48429bbd: 80 18                 mov     0x18, d0
48429bbf: 19                    exth    d1
48429bc0: cb                    nop
48429bc1: cb                    nop
48429bc2: f2 41                 mul     d0, d1
48429bc4: 80 ff                 mov     -1, d0
48429bc6: f4                    movhu   d0, (d1, a0)
48429bc7: c4 cc                 bcs     0x48429b93
48429bc9: 84                    mov     d1, d0
48429bca: 00                    clr     d0
48429bcb: 80 38                 mov     0x38, d0
48429bcd: cb                    nop
48429bce: cb                    nop
48429bcf: f2 48                 mul     d2, d0
48429bd1: f1 e0                 mov     d0, a0
48429bd3: f1 6c                 add     d3, a0
48429bd5: f8 60 30              movhu   (0x30, a0), d0
48429bd8: 18                    exth    d0
48429bd9: a0 ff                 cmp     -1, d0
48429bdb: c8 25                 beq     0x48429c00
48429bdd: 80 38                 mov     0x38, d0
48429bdf: cb                    nop
48429be0: cb                    nop
48429be1: f2 48                 mul     d2, d0
48429be3: ec                    add     d3, d0
48429be4: f1 e0                 mov     d0, a0
48429be6: f8 20 34              mov     (0x34, a0), a0
48429be9: 80 38                 mov     0x38, d0
48429beb: cb                    nop
48429bec: cb                    nop
48429bed: f2 42                 mul     d0, d2
48429bef: ee                    add     d3, d2
48429bf0: f1 e9                 mov     d2, a1
48429bf2: f8 65 30              movhu   (0x30, a1), d1
48429bf5: 80 18                 mov     0x18, d0
48429bf7: 19                    exth    d1
48429bf8: cb                    nop
48429bf9: cb                    nop
48429bfa: f2 41                 mul     d0, d1
48429bfc: 80 ff                 mov     -1, d0
48429bfe: f4                    movhu   d0, (d1, a0)
48429bff: c4 f8                 bcs     0x48429bf7
48429c01: bc                    cmp     a3, a0
48429c02: 1c                    exthu   d0
48429c03: 85 38                 mov     0x38, d1
48429c05: 18                    exth    d0
48429c06: cb                    nop
48429c07: cb                    nop
48429c08: f2 41                 mul     d0, d1
48429c0a: f1 e4                 mov     d1, a0
48429c0c: f1 6c                 add     d3, a0
48429c0e: f8 3c 14              mov     a3, (0x14, a0)
48429c11: 5a 14                 mov     (0x14, sp), d2
48429c13: 85 38                 mov     0x38, d1
48429c15: cb                    nop
48429c16: cb                    nop
48429c17: f2 41                 mul     d0, d1
48429c19: ed                    add     d3, d1
48429c1a: f1 e4                 mov     d1, a0
48429c1c: f8 18 18              mov     d2, (0x18, a0)
48429c1f: 85 38                 mov     0x38, d1
48429c21: cb                    nop
48429c22: cb                    nop
48429c23: f2 44                 mul     d1, d0
48429c25: ec                    add     d3, d0
48429c26: f1 e0                 mov     d0, a0
48429c28: f8 38 1c              mov     a2, (0x1c, a0)
48429c2b: 4b 10                 mov     a2, (0x10, sp)
48429c2d: f1 dc                 mov     a3, d0
48429c2f: 59 14                 mov     (0x14, sp), d1
48429c31: cd 60 f8 f0 30        call    0x48429491, [d2,d3,a2,a3], 0x30
48429c36: f8 be 1c              movhu   (0x1c, sp), d2
48429c39: 80 38                 mov     0x38, d0
48429c3b: 1a                    exth    d2
48429c3c: cb                    nop
48429c3d: cb                    nop
48429c3e: f2 48                 mul     d2, d0
48429c40: f1 e0                 mov     d0, a0
48429c42: f1 6c                 add     d3, a0
48429c44: f8 60 30              movhu   (0x30, a0), d0
48429c47: 18                    exth    d0
48429c48: a0 ff                 cmp     -1, d0
48429c4a: c8 3a                 beq     0x48429c84
48429c4c: f8 be 1c              movhu   (0x1c, sp), d2
48429c4f: 80 38                 mov     0x38, d0
48429c51: 1a                    exth    d2
48429c52: cb                    nop
48429c53: cb                    nop
48429c54: f2 48                 mul     d2, d0
48429c56: ec                    add     d3, d0
48429c57: f1 e0                 mov     d0, a0
48429c59: f8 24 34              mov     (0x34, a0), a1
48429c5c: 80 38                 mov     0x38, d0
48429c5e: cb                    nop
48429c5f: cb                    nop
48429c60: f2 48                 mul     d2, d0
48429c62: ec                    add     d3, d0
48429c63: f1 e0                 mov     d0, a0
48429c65: f8 64 30              movhu   (0x30, a0), d1
48429c68: 80 18                 mov     0x18, d0
48429c6a: 19                    exth    d1
48429c6b: cb                    nop
48429c6c: cb                    nop
48429c6d: f2 44                 mul     d1, d0
48429c6f: f1 61                 add     d0, a1
48429c71: f8 05 04              mov     (4, a1), d1
48429c74: 88                    mov     d2, d0
48429c75: 54                    asl2    d0
48429c76: fc dc 8c fa 11 50     mov     0x5011fa8c, a0
48429c7c: f3 00                 mov     (d0, a0), d0
48429c7e: a1                    cmp     d0, d1
48429c7f: c5 05                 bhi     0x48429c84
48429c81: cc d1 fd              jmp     0x48429a52
48429c84: fc dc 8c fa 11 50     mov     0x5011fa8c, a0
48429c8a: 88                    mov     d2, d0
48429c8b: 54                    asl2    d0
48429c8c: f3 00                 mov     (d0, a0), d0
48429c8e: 56                    asl2    d2
48429c8f: 40                    inc     d0
48429c90: f3 48                 mov     d0, (d2, a0)
48429c92: df f0 30              ret     [d2,d3,a2,a3], 0x30

ApTimer:
48429c95: cf f0                 movm    [d2,d3,a2,a3], (sp)
48429c97: f8 fe dc              add     -0x24, sp
48429c9a: 3c                    mov     sp, a0
48429c9b: 20 1c                 add     0x1c, a0
48429c9d: f1 e7                 mov     d1, a3
48429c9f: f1 e2                 mov     d0, a2
48429ca1: dd ae ad fe ff 20 04  call    0x48414a4f, [a2], 4
48429ca8: 00                    clr     d0
48429ca9: f8 93 1a              movhu   d0, (0x1a, sp)
48429cac: 42 14                 mov     d0, (0x14, sp)
48429cae: f8 bf 1c              movhu   (0x1c, sp), d3
48429cb1: 80 38                 mov     0x38, d0
48429cb3: 1b                    exth    d3
48429cb4: cb                    nop
48429cb5: cb                    nop
48429cb6: f2 4c                 mul     d3, d0
48429cb8: f1 e0                 mov     d0, a0
48429cba: fc d0 7c 75 00 50     add     0x5000757c, a0
48429cc0: f8 60 32              movhu   (0x32, a0), d0
48429cc3: 18                    exth    d0
48429cc4: a0 00                 cmp     0, d0
48429cc6: c1 05                 bgt     0x48429ccb
48429cc8: cc b9 02              jmp     0x48429f81
48429ccb: 80 38                 mov     0x38, d0
48429ccd: cb                    nop
48429cce: cb                    nop
48429ccf: f2 4c                 mul     d3, d0
48429cd1: fc c0 7c 75 00 50     add     0x5000757c, d0
48429cd7: f1 e1                 mov     d0, a1
48429cd9: f8 69 32              movhu   (0x32, a1), d2
48429cdc: 80 38                 mov     0x38, d0
48429cde: cb                    nop
48429cdf: cb                    nop
48429ce0: f2 4c                 mul     d3, d0
48429ce2: fc c0 7c 75 00 50     add     0x5000757c, d0
48429ce8: f1 e0                 mov     d0, a0
48429cea: f8 20 34              mov     (0x34, a0), a0
48429ced: 1a                    exth    d2
48429cee: db                    setlb
48429cef: 85 18                 mov     0x18, d1
48429cf1: f8 bc 1a              movhu   (0x1a, sp), d0
48429cf4: 42 10                 mov     d0, (0x10, sp)
48429cf6: cb                    nop
48429cf7: cb                    nop
48429cf8: f2 54                 mulu    d1, d0
48429cfa: f1 50                 add     a0, d0
48429cfc: f1 e1                 mov     d0, a1
48429cfe: f8 01 08              mov     (8, a1), d0
48429d01: a0 ff                 cmp     -1, d0
48429d03: c8 05                 beq     0x48429d08
48429d05: cc 6f 02              jmp     0x48429f74
48429d08: 80 38                 mov     0x38, d0
48429d0a: cb                    nop
48429d0b: cb                    nop
48429d0c: f2 4c                 mul     d3, d0
48429d0e: f1 e0                 mov     d0, a0
48429d10: fc d0 7c 75 00 50     add     0x5000757c, a0
48429d16: f8 20 34              mov     (0x34, a0), a0
48429d19: 57                    asl2    d3
48429d1a: 58 10                 mov     (0x10, sp), d0
48429d1c: fc dd 8c fa 11 50     mov     0x5011fa8c, a1
48429d22: f3 1d                 mov     (d3, a1), d1
48429d24: 8a 18                 mov     0x18, d2
48429d26: f1 59                 add     a2, d1
48429d28: cb                    nop
48429d29: cb                    nop
48429d2a: f2 58                 mulu    d2, d0
48429d2c: f1 60                 add     d0, a0
48429d2e: f8 14 04              mov     d1, (4, a0)
48429d31: f8 bc 1c              movhu   (0x1c, sp), d0
48429d34: 85 38                 mov     0x38, d1
48429d36: 18                    exth    d0
48429d37: cb                    nop
48429d38: cb                    nop
48429d39: f2 44                 mul     d1, d0
48429d3b: fc c0 7c 75 00 50     add     0x5000757c, d0
48429d41: f1 e0                 mov     d0, a0
48429d43: f8 20 34              mov     (0x34, a0), a0
48429d46: 58 10                 mov     (0x10, sp), d0
48429d48: 85 38                 mov     0x38, d1
48429d4a: cb                    nop
48429d4b: cb                    nop
48429d4c: f2 58                 mulu    d2, d0
48429d4e: f1 60                 add     d0, a0
48429d50: f8 3c 08              mov     a3, (8, a0)
48429d53: f8 bc 1c              movhu   (0x1c, sp), d0
48429d56: 5d 44                 mov     (0x44, sp), a1
48429d58: 18                    exth    d0
48429d59: cb                    nop
48429d5a: cb                    nop
48429d5b: f2 41                 mul     d0, d1
48429d5d: f1 e4                 mov     d1, a0
48429d5f: fc d0 7c 75 00 50     add     0x5000757c, a0
48429d65: f8 20 34              mov     (0x34, a0), a0
48429d68: 58 10                 mov     (0x10, sp), d0
48429d6a: 85 38                 mov     0x38, d1
48429d6c: cb                    nop
48429d6d: cb                    nop
48429d6e: f2 58                 mulu    d2, d0
48429d70: f1 60                 add     d0, a0
48429d72: f8 34 0c              mov     a1, (0xc, a0)
48429d75: f8 bc 1c              movhu   (0x1c, sp), d0
48429d78: 5d 48                 mov     (0x48, sp), a1
48429d7a: 18                    exth    d0
48429d7b: cb                    nop
48429d7c: cb                    nop
48429d7d: f2 41                 mul     d0, d1
48429d7f: f1 e4                 mov     d1, a0
48429d81: fc d0 7c 75 00 50     add     0x5000757c, a0
48429d87: f8 20 34              mov     (0x34, a0), a0
48429d8a: 58 10                 mov     (0x10, sp), d0
48429d8c: 85 38                 mov     0x38, d1
48429d8e: cb                    nop
48429d8f: cb                    nop
48429d90: f2 58                 mulu    d2, d0
48429d92: f1 60                 add     d0, a0
48429d94: f8 34 10              mov     a1, (0x10, a0)
48429d97: f8 bc 1c              movhu   (0x1c, sp), d0
48429d9a: 5d 4c                 mov     (0x4c, sp), a1
48429d9c: 18                    exth    d0
48429d9d: cb                    nop
48429d9e: cb                    nop
48429d9f: f2 41                 mul     d0, d1
48429da1: f1 e4                 mov     d1, a0
48429da3: fc d0 7c 75 00 50     add     0x5000757c, a0
48429da9: f8 20 34              mov     (0x34, a0), a0
48429dac: 58 10                 mov     (0x10, sp), d0
48429dae: cb                    nop
48429daf: cb                    nop
48429db0: f2 58                 mulu    d2, d0
48429db2: f1 60                 add     d0, a0
48429db4: f8 34 14              mov     a1, (0x14, a0)
48429db7: f8 bf 1c              movhu   (0x1c, sp), d3
48429dba: 80 38                 mov     0x38, d0
48429dbc: 1b                    exth    d3
48429dbd: cb                    nop
48429dbe: cb                    nop
48429dbf: f2 4c                 mul     d3, d0
48429dc1: f1 e0                 mov     d0, a0
48429dc3: fc d0 7c 75 00 50     add     0x5000757c, a0
48429dc9: f8 60 30              movhu   (0x30, a0), d0
48429dcc: 18                    exth    d0
48429dcd: a0 ff                 cmp     -1, d0
48429dcf: c9 05                 bne     0x48429dd4
48429dd1: cc 8d 01              jmp     0x48429f5e
48429dd4: 80 ff                 mov     -1, d0
48429dd6: f8 93 18              movhu   d0, (0x18, sp)
48429dd9: 80 38                 mov     0x38, d0
48429ddb: cb                    nop
48429ddc: cb                    nop
48429ddd: f2 4c                 mul     d3, d0
48429ddf: fc c0 7c 75 00 50     add     0x5000757c, d0
48429de5: f1 e0                 mov     d0, a0
48429de7: f8 64 30              movhu   (0x30, a0), d1
48429dea: 80 38                 mov     0x38, d0
48429dec: cb                    nop
48429ded: cb                    nop
48429dee: f2 4c                 mul     d3, d0
48429df0: f1 e0                 mov     d0, a0
48429df2: fc d0 7c 75 00 50     add     0x5000757c, a0
48429df8: f8 20 34              mov     (0x34, a0), a0
48429dfb: 86                    mov     d1, d2
48429dfc: 80 18                 mov     0x18, d0
48429dfe: 1a                    exth    d2
48429dff: cb                    nop
48429e00: cb                    nop
48429e01: f2 48                 mul     d2, d0
48429e03: f1 60                 add     d0, a0
48429e05: 80 38                 mov     0x38, d0
48429e07: cb                    nop
48429e08: cb                    nop
48429e09: f2 4c                 mul     d3, d0
48429e0b: fc c0 7c 75 00 50     add     0x5000757c, d0
48429e11: f1 e7                 mov     d1, a3
48429e13: f8 04 04              mov     (4, a0), d1
48429e16: f1 e0                 mov     d0, a0
48429e18: f8 24 34              mov     (0x34, a0), a1
48429e1b: 58 10                 mov     (0x10, sp), d0
48429e1d: 4e 20                 mov     d3, (0x20, sp)
48429e1f: 8f 18                 mov     0x18, d3
48429e21: cb                    nop
48429e22: cb                    nop
48429e23: f2 53                 mulu    d0, d3
48429e25: f1 ec                 mov     d3, a0
48429e27: f1 71                 add     a0, a1
48429e29: f8 01 04              mov     (4, a1), d0
48429e2c: 5b 20                 mov     (0x20, sp), d3
48429e2e: a1                    cmp     d0, d1
48429e2f: c5 6f                 bhi     0x48429e9e
48429e31: 80 38                 mov     0x38, d0
48429e33: cb                    nop
48429e34: cb                    nop
48429e35: f2 4c                 mul     d3, d0
48429e37: fc c0 7c 75 00 50     add     0x5000757c, d0
48429e3d: f1 e0                 mov     d0, a0
48429e3f: f8 04 34              mov     (0x34, a0), d1
48429e42: 58 10                 mov     (0x10, sp), d0
48429e44: 46 0c                 mov     d1, (0xc, sp)
48429e46: 85 18                 mov     0x18, d1
48429e48: cb                    nop
48429e49: cb                    nop
48429e4a: f2 51                 mulu    d0, d1
48429e4c: 80 38                 mov     0x38, d0
48429e4e: cb                    nop
48429e4f: cb                    nop
48429e50: f2 4c                 mul     d3, d0
48429e52: fc c0 7c 75 00 50     add     0x5000757c, d0
48429e58: f1 e0                 mov     d0, a0
48429e5a: f8 24 34              mov     (0x34, a0), a1
48429e5d: 80 38                 mov     0x38, d0
48429e5f: cb                    nop
48429e60: cb                    nop
48429e61: f2 4c                 mul     d3, d0
48429e63: f1 e0                 mov     d0, a0
48429e65: fc d0 7c 75 00 50     add     0x5000757c, a0
48429e6b: f8 28 34              mov     (0x34, a0), a2
48429e6e: f1 65                 add     d1, a1
48429e70: f8 05 04              mov     (4, a1), d1
48429e73: db                    setlb
48429e74: f1 dc                 mov     a3, d0
48429e76: f8 93 18              movhu   d0, (0x18, sp)
48429e79: 80 18                 mov     0x18, d0
48429e7b: cb                    nop
48429e7c: cb                    nop
48429e7d: f2 42                 mul     d0, d2
48429e7f: 58 0c                 mov     (0xc, sp), d0
48429e81: e2                    add     d0, d2
48429e82: f1 e8                 mov     d2, a0
48429e84: f8 60 02              movhu   (2, a0), d0
48429e87: f1 e3                 mov     d0, a3
48429e89: 82                    mov     d0, d2
48429e8a: 1a                    exth    d2
48429e8b: aa ff                 cmp     -1, d2
48429e8d: c8 11                 beq     0x48429e9e
48429e8f: 80 18                 mov     0x18, d0
48429e91: cb                    nop
48429e92: cb                    nop
48429e93: f2 48                 mul     d2, d0
48429e95: f1 e0                 mov     d0, a0
48429e97: f1 78                 add     a2, a0
48429e99: f8 00 04              mov     (4, a0), d0
48429e9c: a4                    cmp     d1, d0
48429e9d: d7                    lls
48429e9e: 80 38                 mov     0x38, d0
48429ea0: cb                    nop
48429ea1: cb                    nop
48429ea2: f2 43                 mul     d0, d3
48429ea4: fc c3 7c 75 00 50     add     0x5000757c, d3
48429eaa: f1 ec                 mov     d3, a0
48429eac: f8 20 34              mov     (0x34, a0), a0
48429eaf: 58 10                 mov     (0x10, sp), d0
48429eb1: 85 18                 mov     0x18, d1
48429eb3: cb                    nop
48429eb4: cb                    nop
48429eb5: f2 54                 mulu    d1, d0
48429eb7: f8 bd 18              movhu   (0x18, sp), d1
48429eba: f4                    movhu   d1, (d0, a0)
48429ebb: d0                    llt
48429ebc: f8 bc 1c              movhu   (0x1c, sp), d0
48429ebf: 85 38                 mov     0x38, d1
48429ec1: 18                    exth    d0
48429ec2: cb                    nop
48429ec3: cb                    nop
48429ec4: f2 44                 mul     d1, d0
48429ec6: fc c0 7c 75 00 50     add     0x5000757c, d0
48429ecc: f1 e0                 mov     d0, a0
48429ece: f8 20 34              mov     (0x34, a0), a0
48429ed1: 58 10                 mov     (0x10, sp), d0
48429ed3: 85 18                 mov     0x18, d1
48429ed5: cb                    nop
48429ed6: cb                    nop
48429ed7: f2 54                 mulu    d1, d0
48429ed9: f1 60                 add     d0, a0
48429edb: f1 dc                 mov     a3, d0
48429edd: f8 70 02              movhu   d0, (2, a0)
48429ee0: f8 bc 18              movhu   (0x18, sp), d0
48429ee3: 18                    exth    d0
48429ee4: a0 ff                 cmp     -1, d0
48429ee6: c8 25                 beq     0x48429f0b
48429ee8: f8 bd 1c              movhu   (0x1c, sp), d1
48429eeb: 8f 38                 mov     0x38, d3
48429eed: 19                    exth    d1
48429eee: cb                    nop
48429eef: cb                    nop
48429ef0: f2 4d                 mul     d3, d1
48429ef2: fc c1 7c 75 00 50     add     0x5000757c, d1
48429ef8: f1 e4                 mov     d1, a0
48429efa: f8 20 34              mov     (0x34, a0), a0
48429efd: 85 18                 mov     0x18, d1
48429eff: cb                    nop
48429f00: cb                    nop
48429f01: f2 44                 mul     d1, d0
48429f03: f1 60                 add     d0, a0
48429f05: f8 bc 1a              movhu   (0x1a, sp), d0
48429f08: f8 70 02              movhu   d0, (2, a0)
48429f0b: aa ff                 cmp     -1, d2
48429f0d: c8 22                 beq     0x48429f2f
48429f0f: f8 bc 1c              movhu   (0x1c, sp), d0
48429f12: 85 38                 mov     0x38, d1
48429f14: 18                    exth    d0
48429f15: cb                    nop
48429f16: cb                    nop
48429f17: f2 44                 mul     d1, d0
48429f19: fc c0 7c 75 00 50     add     0x5000757c, d0
48429f1f: f1 e0                 mov     d0, a0
48429f21: f8 20 34              mov     (0x34, a0), a0
48429f24: f8 bd 1a              movhu   (0x1a, sp), d1
48429f27: 80 18                 mov     0x18, d0
48429f29: cb                    nop
48429f2a: cb                    nop
48429f2b: f2 48                 mul     d2, d0
48429f2d: f4                    movhu   d1, (d0, a0)
48429f2e: d0                    llt
48429f2f: f8 bf 1c              movhu   (0x1c, sp), d3
48429f32: 80 38                 mov     0x38, d0
48429f34: 1b                    exth    d3
48429f35: cb                    nop
48429f36: cb                    nop
48429f37: f2 4c                 mul     d3, d0
48429f39: fc c0 7c 75 00 50     add     0x5000757c, d0
48429f3f: f1 e0                 mov     d0, a0
48429f41: f8 64 30              movhu   (0x30, a0), d1
48429f44: 19                    exth    d1
48429f45: a6                    cmp     d1, d2
48429f46: c9 3b                 bne     0x48429f81
48429f48: 80 38                 mov     0x38, d0
48429f4a: cb                    nop
48429f4b: cb                    nop
48429f4c: f2 4c                 mul     d3, d0
48429f4e: fc c0 7c 75 00 50     add     0x5000757c, d0
48429f54: f8 bd 1a              movhu   (0x1a, sp), d1
48429f57: f1 e0                 mov     d0, a0
48429f59: f8 74 30              movhu   d1, (0x30, a0)
48429f5c: ca 25                 bra     0x48429f81
48429f5e: 80 38                 mov     0x38, d0
48429f60: cb                    nop
48429f61: cb                    nop
48429f62: f2 4c                 mul     d3, d0
48429f64: fc c0 7c 75 00 50     add     0x5000757c, d0
48429f6a: f8 bd 1a              movhu   (0x1a, sp), d1
48429f6d: f1 e0                 mov     d0, a0
48429f6f: f8 74 30              movhu   d1, (0x30, a0)
48429f72: ca 0f                 bra     0x48429f81
48429f74: 58 14                 mov     (0x14, sp), d0
48429f76: 40                    inc     d0
48429f77: f8 93 1a              movhu   d0, (0x1a, sp)
48429f7a: f8 bc 1a              movhu   (0x1a, sp), d0
48429f7d: 42 14                 mov     d0, (0x14, sp)
48429f7f: a8                    cmp     d2, d0
48429f80: d0                    llt
48429f81: 59 14                 mov     (0x14, sp), d1
48429f83: 80 38                 mov     0x38, d0
48429f85: cb                    nop
48429f86: cb                    nop
48429f87: f2 43                 mul     d0, d3
48429f89: f1 ec                 mov     d3, a0
48429f8b: fc d0 7c 75 00 50     add     0x5000757c, a0
48429f91: f8 60 32              movhu   (0x32, a0), d0
48429f94: 18                    exth    d0
48429f95: a1                    cmp     d0, d1
48429f96: c9 04                 bne     0x48429f9a
48429f98: ca 00                 bra     0x48429f98
48429f9a: df f0 34              ret     [d2,d3,a2,a3], 0x34

SetApTimer:
48429f9d: cf f0           movm    [d2,d3,a2,a3], (sp)
48429f9f: f8 fe e4        add     -0x1c, sp
48429fa2: 46 38           mov     d1, (0x38, sp)
48429fa4: 5a 3c           mov     (0x3c, sp), d2
48429fa6: 83              mov     d0, d3
48429fa7: 4a 10           mov     d2, (0x10, sp)
48429fa9: 5f 40           mov     (0x40, sp), a3
48429fab: 4f 14           mov     a3, (0x14, sp)
48429fad: 5e 44           mov     (0x44, sp), a2
48429faf: 4b 18           mov     a2, (0x18, sp)
48429fb1: cd 24 00 f0 30  call    0x48429fd5, [d2,d3,a2,a3], 0x30
48429fb6: a0 00           cmp     0, d0
48429fb8: c8 14           beq     0x48429fcc
48429fba: 4a 10           mov     d2, (0x10, sp)
48429fbc: 4f 14           mov     a3, (0x14, sp)
48429fbe: 4b 18           mov     a2, (0x18, sp)
48429fc0: 59 38           mov     (0x38, sp), d1
48429fc2: 8c              mov     d3, d0
48429fc3: cd d7 fc f0 34  call    0x48429c9a, [d2,d3,a2,a3], 0x34
48429fc8: 80 01           mov     1, d0
48429fca: ca 03           bra     0x48429fcd
48429fcc: 00              clr     d0
48429fcd: df f0 2c        ret     [d2,d3,a2,a3], 0x2c

ResetApTimer:
48429fd0: cf f0                 movm    [d2,d3,a2,a3], (sp)
48429fd2: f8 fe e0              add     -0x20, sp
48429fd5: 3c                    mov     sp, a0
48429fd6: 46 3c                 mov     d1, (0x3c, sp)
48429fd8: 20 1c                 add     0x1c, a0
48429fda: dd 75 aa fe ff 20 04  call    0x48414a4f, [a2], 4
48429fe1: f8 be 1c              movhu   (0x1c, sp), d2
48429fe4: fc df 7c 75 00 50     mov     0x5000757c, a3
48429fea: 1a                    exth    d2
48429feb: 80 38                 mov     0x38, d0
48429fed: cb                    nop
48429fee: cb                    nop
48429fef: f2 48                 mul     d2, d0
48429ff1: f1 5c                 add     a3, d0
48429ff3: f1 e0                 mov     d0, a0
48429ff5: f8 6c 30              movhu   (0x30, a0), d3
48429ff8: 1b                    exth    d3
48429ff9: af ff                 cmp     -1, d3
48429ffb: c9 05                 bne     0x4842a000
48429ffd: cc 07 02              jmp     0x4842a204
4842a000: 80 38                 mov     0x38, d0
4842a002: cb                    nop
4842a003: cb                    nop
4842a004: f2 48                 mul     d2, d0
4842a006: f1 e0                 mov     d0, a0
4842a008: f1 7c                 add     a3, a0
4842a00a: f8 00 34              mov     (0x34, a0), d0
4842a00d: 42 18                 mov     d0, (0x18, sp)
4842a00f: 80 38                 mov     0x38, d0
4842a011: cb                    nop
4842a012: cb                    nop
4842a013: f2 48                 mul     d2, d0
4842a015: f1 5c                 add     a3, d0
4842a017: f1 e0                 mov     d0, a0
4842a019: f8 04 34              mov     (0x34, a0), d1
4842a01c: 80 38                 mov     0x38, d0
4842a01e: 46 14                 mov     d1, (0x14, sp)
4842a020: cb                    nop
4842a021: cb                    nop
4842a022: f2 48                 mul     d2, d0
4842a024: f1 e0                 mov     d0, a0
4842a026: f1 7c                 add     a3, a0
4842a028: f8 00 34              mov     (0x34, a0), d0
4842a02b: 42 10                 mov     d0, (0x10, sp)
4842a02d: 80 38                 mov     0x38, d0
4842a02f: cb                    nop
4842a030: cb                    nop
4842a031: f2 48                 mul     d2, d0
4842a033: f1 e0                 mov     d0, a0
4842a035: f1 7c                 add     a3, a0
4842a037: f8 00 34              mov     (0x34, a0), d0
4842a03a: 42 0c                 mov     d0, (0xc, sp)
4842a03c: 80 38                 mov     0x38, d0
4842a03e: cb                    nop
4842a03f: cb                    nop
4842a040: f2 48                 mul     d2, d0
4842a042: f1 e0                 mov     d0, a0
4842a044: f1 7c                 add     a3, a0
4842a046: f8 28 34              mov     (0x34, a0), a2
4842a049: db                    setlb
4842a04a: 59 18                 mov     (0x18, sp), d1
4842a04c: 80 18                 mov     0x18, d0
4842a04e: cb                    nop
4842a04f: cb                    nop
4842a050: f2 4c                 mul     d3, d0
4842a052: e4                    add     d1, d0
4842a053: f1 e0                 mov     d0, a0
4842a055: f8 04 08              mov     (8, a0), d1
4842a058: 58 3c                 mov     (0x3c, sp), d0
4842a05a: a1                    cmp     d0, d1
4842a05b: c8 05                 beq     0x4842a060
4842a05d: cc 96 01              jmp     0x4842a1f3
4842a060: 59 14                 mov     (0x14, sp), d1
4842a062: 80 18                 mov     0x18, d0
4842a064: cb                    nop
4842a065: cb                    nop
4842a066: f2 4c                 mul     d3, d0
4842a068: e4                    add     d1, d0
4842a069: f1 e0                 mov     d0, a0
4842a06b: f8 24 0c              mov     (0xc, a0), a1
4842a06e: 5c 40                 mov     (0x40, sp), a0
4842a070: b1                    cmp     a0, a1
4842a071: c8 05                 beq     0x4842a076
4842a073: cc 80 01              jmp     0x4842a1f3
4842a076: 59 10                 mov     (0x10, sp), d1
4842a078: 80 18                 mov     0x18, d0
4842a07a: cb                    nop
4842a07b: cb                    nop
4842a07c: f2 4c                 mul     d3, d0
4842a07e: e4                    add     d1, d0
4842a07f: f1 e0                 mov     d0, a0
4842a081: f8 24 10              mov     (0x10, a0), a1
4842a084: 5c 44                 mov     (0x44, sp), a0
4842a086: b1                    cmp     a0, a1
4842a087: c8 05                 beq     0x4842a08c
4842a089: cc 6a 01              jmp     0x4842a1f3
4842a08c: 59 0c                 mov     (0xc, sp), d1
4842a08e: 80 18                 mov     0x18, d0
4842a090: cb                    nop
4842a091: cb                    nop
4842a092: f2 4c                 mul     d3, d0
4842a094: e4                    add     d1, d0
4842a095: f1 e0                 mov     d0, a0
4842a097: f8 24 14              mov     (0x14, a0), a1
4842a09a: 5c 48                 mov     (0x48, sp), a0
4842a09c: b1                    cmp     a0, a1
4842a09d: c8 05                 beq     0x4842a0a2
4842a09f: cc 54 01              jmp     0x4842a1f3
4842a0a2: 80 38                 mov     0x38, d0
4842a0a4: cb                    nop
4842a0a5: cb                    nop
4842a0a6: f2 48                 mul     d2, d0
4842a0a8: f1 5c                 add     a3, d0
4842a0aa: f1 e0                 mov     d0, a0
4842a0ac: f8 20 34              mov     (0x34, a0), a0
4842a0af: 80 18                 mov     0x18, d0
4842a0b1: cb                    nop
4842a0b2: cb                    nop
4842a0b3: f2 4c                 mul     d3, d0
4842a0b5: f1 60                 add     d0, a0
4842a0b7: f8 60 02              movhu   (2, a0), d0
4842a0ba: 18                    exth    d0
4842a0bb: a0 ff                 cmp     -1, d0
4842a0bd: c8 45                 beq     0x4842a102
4842a0bf: 80 38                 mov     0x38, d0
4842a0c1: cb                    nop
4842a0c2: cb                    nop
4842a0c3: f2 48                 mul     d2, d0
4842a0c5: f1 e0                 mov     d0, a0
4842a0c7: f1 7c                 add     a3, a0
4842a0c9: f8 20 34              mov     (0x34, a0), a0
4842a0cc: 80 18                 mov     0x18, d0
4842a0ce: cb                    nop
4842a0cf: cb                    nop
4842a0d0: f2 4c                 mul     d3, d0
4842a0d2: f4                    movhu   (d0, a0), d1
4842a0d3: 90 80                 mov     0x80, a0
4842a0d5: 38 cb cb              movhu   (0xcbcb), d0
4842a0d8: f2 48                 mul     d2, d0
4842a0da: f1 e0                 mov     d0, a0
4842a0dc: 80 38                 mov     0x38, d0
4842a0de: cb                    nop
4842a0df: cb                    nop
4842a0e0: f2 42                 mul     d0, d2
4842a0e2: f1 5e                 add     a3, d2
4842a0e4: f1 7c                 add     a3, a0
4842a0e6: f8 28 34              mov     (0x34, a0), a2
4842a0e9: f1 e8                 mov     d2, a0
4842a0eb: f8 24 34              mov     (0x34, a0), a1
4842a0ee: 80 18                 mov     0x18, d0
4842a0f0: cb                    nop
4842a0f1: cb                    nop
4842a0f2: f2 4c                 mul     d3, d0
4842a0f4: f1 61                 add     d0, a1
4842a0f6: f8 61 02              movhu   (2, a1), d0
4842a0f9: 8a 18                 mov     0x18, d2
4842a0fb: 18                    exth    d0
4842a0fc: cb                    nop
4842a0fd: cb                    nop
4842a0fe: f2 48                 mul     d2, d0
4842a100: f4                    movhu   d1, (d0, a2)
4842a101: d2                    lge
4842a102: f8 bd 1c              movhu   (0x1c, sp), d1
4842a105: 80 38                 mov     0x38, d0
4842a107: 19                    exth    d1
4842a108: cb                    nop
4842a109: cb                    nop
4842a10a: f2 44                 mul     d1, d0
4842a10c: f1 5c                 add     a3, d0
4842a10e: f1 e0                 mov     d0, a0
4842a110: f8 20 34              mov     (0x34, a0), a0
4842a113: 80 18                 mov     0x18, d0
4842a115: cb                    nop
4842a116: cb                    nop
4842a117: f2 4c                 mul     d3, d0
4842a119: f4                    movhu   (d0, a0), d0
4842a11a: 80 18                 mov     0x18, d0
4842a11c: a0 ff                 cmp     -1, d0
4842a11e: c8 48                 beq     0x4842a166
4842a120: 80 38                 mov     0x38, d0
4842a122: cb                    nop
4842a123: cb                    nop
4842a124: f2 44                 mul     d1, d0
4842a126: f1 e0                 mov     d0, a0
4842a128: f1 7c                 add     a3, a0
4842a12a: f8 20 34              mov     (0x34, a0), a0
4842a12d: 80 18                 mov     0x18, d0
4842a12f: cb                    nop
4842a130: cb                    nop
4842a131: f2 4c                 mul     d3, d0
4842a133: f1 60                 add     d0, a0
4842a135: f8 68 02              movhu   (2, a0), d2
4842a138: 80 38                 mov     0x38, d0
4842a13a: cb                    nop
4842a13b: cb                    nop
4842a13c: f2 44                 mul     d1, d0
4842a13e: f1 5c                 add     a3, d0
4842a140: f1 e0                 mov     d0, a0
4842a142: 80 38                 mov     0x38, d0
4842a144: cb                    nop
4842a145: cb                    nop
4842a146: f2 41                 mul     d0, d1
4842a148: f1 5d                 add     a3, d1
4842a14a: f8 24 34              mov     (0x34, a0), a1
4842a14d: f1 e4                 mov     d1, a0
4842a14f: f8 20 34              mov     (0x34, a0), a0
4842a152: 80 18                 mov     0x18, d0
4842a154: cb                    nop
4842a155: cb                    nop
4842a156: f2 4c                 mul     d3, d0
4842a158: f4                    movhu   (d0, a0), d0
4842a159: 80 85                 mov     -0x7b, d0
4842a15b: 18                    exth    d0
4842a15c: 18                    exth    d0
4842a15d: cb                    nop
4842a15e: cb                    nop
4842a15f: f2 44                 mul     d1, d0
4842a161: f1 61                 add     d0, a1
4842a163: f8 79 02              movhu   d2, (2, a1)
4842a166: f8 bd 1c              movhu   (0x1c, sp), d1
4842a169: 80 38                 mov     0x38, d0
4842a16b: 19                    exth    d1
4842a16c: cb                    nop
4842a16d: cb                    nop
4842a16e: f2 44                 mul     d1, d0
4842a170: f1 5c                 add     a3, d0
4842a172: f1 e0                 mov     d0, a0
4842a174: f8 60 30              movhu   (0x30, a0), d0
4842a177: 18                    exth    d0
4842a178: a3                    cmp     d0, d3
4842a179: c9 27                 bne     0x4842a1a0
4842a17b: 80 38                 mov     0x38, d0
4842a17d: cb                    nop
4842a17e: cb                    nop
4842a17f: f2 44                 mul     d1, d0
4842a181: f1 e0                 mov     d0, a0
4842a183: f1 7c                 add     a3, a0
4842a185: f8 20 34              mov     (0x34, a0), a0
4842a188: 80 18                 mov     0x18, d0
4842a18a: cb                    nop
4842a18b: cb                    nop
4842a18c: f2 4c                 mul     d3, d0
4842a18e: f1 60                 add     d0, a0
4842a190: f8 68 02              movhu   (2, a0), d2
4842a193: 80 38                 mov     0x38, d0
4842a195: cb                    nop
4842a196: cb                    nop
4842a197: f2 44                 mul     d1, d0
4842a199: f1 5c                 add     a3, d0
4842a19b: f1 e0                 mov     d0, a0
4842a19d: f8 78 30              movhu   d2, (0x30, a0)
4842a1a0: 80 38                 mov     0x38, d0
4842a1a2: cb                    nop
4842a1a3: cb                    nop
4842a1a4: f2 44                 mul     d1, d0
4842a1a6: f1 e0                 mov     d0, a0
4842a1a8: f1 7c                 add     a3, a0
4842a1aa: f8 20 34              mov     (0x34, a0), a0
4842a1ad: 80 18                 mov     0x18, d0
4842a1af: cb                    nop
4842a1b0: cb                    nop
4842a1b1: f2 4c                 mul     d3, d0
4842a1b3: f1 60                 add     d0, a0
4842a1b5: 80 ff                 mov     -1, d0
4842a1b7: f8 10 08              mov     d0, (8, a0)
4842a1ba: f8 bc 1c              movhu   (0x1c, sp), d0
4842a1bd: 85 38                 mov     0x38, d1
4842a1bf: 18                    exth    d0
4842a1c0: cb                    nop
4842a1c1: cb                    nop
4842a1c2: f2 44                 mul     d1, d0
4842a1c4: f1 5c                 add     a3, d0
4842a1c6: f1 e0                 mov     d0, a0
4842a1c8: f8 24 34              mov     (0x34, a0), a1
4842a1cb: 85 ff                 mov     -1, d1
4842a1cd: 80 18                 mov     0x18, d0
4842a1cf: cb                    nop
4842a1d0: cb                    nop
4842a1d1: f2 4c                 mul     d3, d0
4842a1d3: f1 61                 add     d0, a1
4842a1d5: f8 75 02              movhu   d1, (2, a1)
4842a1d8: f8 bc 1c              movhu   (0x1c, sp), d0
4842a1db: 8a 38                 mov     0x38, d2
4842a1dd: 18                    exth    d0
4842a1de: cb                    nop
4842a1df: cb                    nop
4842a1e0: f2 48                 mul     d2, d0
4842a1e2: f1 63                 add     d0, a3
4842a1e4: f8 23 34              mov     (0x34, a3), a0
4842a1e7: 80 18                 mov     0x18, d0
4842a1e9: cb                    nop
4842a1ea: cb                    nop
4842a1eb: f2 43                 mul     d0, d3
4842a1ed: f4                    movhu   d1, (d3, a0)
4842a1ee: dc 80 01 ca 14        jmp     0x5d0ca36e
4842a1f3: 80 18                 mov     0x18, d0
4842a1f5: cb                    nop
4842a1f6: cb                    nop
4842a1f7: f2 4c                 mul     d3, d0
4842a1f9: f1 e0                 mov     d0, a0
4842a1fb: f1 78                 add     a2, a0
4842a1fd: f8 6c 02              movhu   (2, a0), d3
4842a200: 1b                    exth    d3
4842a201: af ff                 cmp     -1, d3
4842a203: d9                    lne
4842a204: 00                    clr     d0
4842a205: df f0 30              ret     [d2,d3,a2,a3], 0x30

DrawStringAlignment:
4842a208: cf f0                 movm    [d2,d3,a2,a3], (sp)
4842a20a: fa fe 68 ff           add     -0x98, sp
4842a20e: 87                    mov     d1, d3
4842a20f: 42 b0                 mov     d0, (0xb0, sp)
4842a211: 42 14                 mov     d0, (0x14, sp)
4842a213: f8 c4 10              lsr     16, d0
4842a216: 1c                    exthu   d0
4842a217: f8 c0 04              asl     4, d0
4842a21a: f1 e0                 mov     d0, a0
4842a21c: fc d0 ac fa 11 50     add     0x5011faac, a0
4842a222: f8 20 04              mov     (4, a0), a0
4842a225: 00                    clr     d0
4842a226: 42 10                 mov     d0, (0x10, sp)
4842a228: 58 b0                 mov     (0xb0, sp), d0
4842a22a: fc cd 00 00 06 00     mov     0x00060000, d1
4842a230: f0 f0                 calls   (a0)
4842a232: 82                    mov     d0, d2
4842a233: fc cb 10 00 06 00     cmp     0x60010, d3
4842a239: c2 05                 bge     0x4842a23e
4842a23b: cc 9b 02              jmp     0x4842a4d6
4842a23e: fc cb 23 00 06 00     cmp     0x60023, d3
4842a244: c3 05                 ble     0x4842a249
4842a246: cc 90 02              jmp     0x4842a4d6
4842a249: 8c                    mov     d3, d0
4842a24a: fc c4 10 00 06 00     sub     0x60010, d0
4842a250: 54                    asl2    d0
4842a251: fc dc 90 df 5a 48     mov     0x485adf90, a0
4842a257: f3 80                 mov     (d0, a0), a0
4842a259: f0 f4                 jmp     (a0)
4842a25b: 88                    mov     d2, d0
4842a25c: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a25f: 5c b8                 mov     (0xb8, sp), a0
4842a261: 88                    mov     d2, d0
4842a262: 43 10                 mov     a0, (0x10, sp)
4842a264: fc cd 01 00 06 00     mov     0x00060001, d1
4842a26a: cd 9a 05 f0 10        call    0x4842a804, [d2,d3,a2,a3], 0x10
4842a26f: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a272: 5c b8                 mov     (0xb8, sp), a0
4842a274: 88                    mov     d2, d0
4842a275: 43 10                 mov     a0, (0x10, sp)
4842a277: fc cd 02 00 06 00     mov     0x00060002, d1
4842a27d: cd 87 05 f0 10        call    0x4842a804, [d2,d3,a2,a3], 0x10
4842a282: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a285: 5c b8                 mov     (0xb8, sp), a0
4842a287: 88                    mov     d2, d0
4842a288: 43 10                 mov     a0, (0x10, sp)
4842a28a: fc cd 03 00 06 00     mov     0x00060003, d1
4842a290: cd 74 05 f0 10        call    0x4842a804, [d2,d3,a2,a3], 0x10
4842a295: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a298: 5c b8                 mov     (0xb8, sp), a0
4842a29a: 88                    mov     d2, d0
4842a29b: 43 10                 mov     a0, (0x10, sp)
4842a29d: fc cd 15 00 06 00     mov     0x00060015, d1
4842a2a3: cd 61 05 f0 10        call    0x4842a804, [d2,d3,a2,a3], 0x10
4842a2a8: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a2ab: 5c b8                 mov     (0xb8, sp), a0
4842a2ad: 88                    mov     d2, d0
4842a2ae: 43 10                 mov     a0, (0x10, sp)
4842a2b0: fc cd 04 00 06 00     mov     0x00060004, d1
4842a2b6: cd 4e 05 f0 10        call    0x4842a804, [d2,d3,a2,a3], 0x10
4842a2bb: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a2be: 5c b8                 mov     (0xb8, sp), a0
4842a2c0: 00                    clr     d0
4842a2c1: 92                    mov     a0, a2
4842a2c2: f0 52                 movbu   d0, (a2)
4842a2c4: fc cd 05 00 06 00     mov     0x00060005, d1
4842a2ca: 43 10                 mov     a0, (0x10, sp)
4842a2cc: 88                    mov     d2, d0
4842a2cd: cd 37 05 f0 10        call    0x4842a804, [d2,d3,a2,a3], 0x10
4842a2d2: 82                    mov     d0, d2
4842a2d3: fc cc 11 00 04 00     mov     0x00040011, d0
4842a2d9: 42 10                 mov     d0, (0x10, sp)
4842a2db: 58 b0                 mov     (0xb0, sp), d0
4842a2dd: fc cd 14 00 06 00     mov     0x00060014, d1
4842a2e3: cd aa f0 c0 24        call    0x4842938d, [d2,d3], 0x24
4842a2e8: a0 00                 cmp     0, d0
4842a2ea: c8 10                 beq     0x4842a2fa
4842a2ec: fc dd 2c df 5a 48     mov     0x485adf2c, a1
4842a2f2: 98                    mov     a2, a0
4842a2f3: dd 94 96 bd 03 20 04  call    0x4c003987, [a2], 4
4842a2fa: 88                    mov     d2, d0
4842a2fb: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a2fe: 5c b8                 mov     (0xb8, sp), a0
4842a300: 88                    mov     d2, d0
4842a301: 43 10                 mov     a0, (0x10, sp)
4842a303: fc cd 06 00 06 00     mov     0x00060006, d1
4842a309: cd fb 04 f0 10        call    0x4842a804, [d2,d3,a2,a3], 0x10
4842a30e: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a311: 3e                    mov     sp, a2
4842a312: 22 18                 add     0x18, a2
4842a314: 4b 10                 mov     a2, (0x10, sp)
4842a316: 58 b0                 mov     (0xb0, sp), d0
4842a318: fc cd 19 00 06 00     mov     0x00060019, d1
4842a31e: cd 6f f0 c0 24        call    0x4842938d, [d2,d3], 0x24
4842a323: 5f b8                 mov     (0xb8, sp), a3
4842a325: 9c                    mov     a3, a0
4842a326: 70                    mov     (a0), d0
4842a327: f4                    movbu   (d0, a2), d0
4842a328: 02 a0 59              movbu   d0, (0x59a0)
4842a32b: c9 16                 bne     0x4842a341
4842a32d: f8 20 04              mov     (4, a0), a0
4842a330: fc dd 30 df 5a 48     mov     0x485adf30, a1
4842a336: dd 1b 8d bd 03 20 04  call    0x4c003051, [a2], 4
4842a33d: 00                    clr     d0
4842a33e: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a341: 70                    mov     (a0), d0
4842a342: f4                    movbu   (d0, a2), d0
4842a343: 02 a0 5a              movbu   d0, (0x5aa0)
4842a346: c9 16                 bne     0x4842a35c
4842a348: f8 20 04              mov     (4, a0), a0
4842a34b: fc dd 38 df 5a 48     mov     0x485adf38, a1
4842a351: dd 00 8d bd 03 20 04  call    0x4c003051, [a2], 4
4842a358: 00                    clr     d0
4842a359: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a35c: f8 20 04              mov     (4, a0), a0
4842a35f: fc dd 40 df 5a 48     mov     0x485adf40, a1
4842a365: dd ec 8c bd 03 20 04  call    0x4c003051, [a2], 4
4842a36c: 4f 10                 mov     a3, (0x10, sp)
4842a36e: fc cd 07 00 06 00     mov     0x00060007, d1
4842a374: 88                    mov     d2, d0
4842a375: cd 8f 04 f0 10        call    0x4842a804, [d2,d3,a2,a3], 0x10
4842a37a: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a37d: 5f b8                 mov     (0xb8, sp), a3
4842a37f: 3e                    mov     sp, a2
4842a380: 22 18                 add     0x18, a2
4842a382: 4b 10                 mov     a2, (0x10, sp)
4842a384: 58 b0                 mov     (0xb0, sp), d0
4842a386: fc cd 19 00 06 00     mov     0x00060019, d1
4842a38c: cd 01 f0 c0 24        call    0x4842938d, [d2,d3], 0x24
4842a391: f8 63 08              movhu   (8, a3), d0
4842a394: fc cd 08 00 06 00     mov     0x00060008, d1
4842a39a: f4                    movbu   (d0, a2), d2
4842a39b: 22 4f                 add     0x4f, a2
4842a39d: 10                    extb    d0
4842a39e: 2a bf                 add     -0x41, d2
4842a3a0: fc c2 00 00 0d 00     add     0xd0000, d2
4842a3a6: 88                    mov     d2, d0
4842a3a7: cd e6 ef c0 24        call    0x4842938d, [d2,d3], 0x24
4842a3ac: 00                    clr     d0
4842a3ad: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a3b0: 5e b8                 mov     (0xb8, sp), a2
4842a3b2: 3f                    mov     sp, a3
4842a3b3: 23 18                 add     0x18, a3
4842a3b5: 4f 10                 mov     a3, (0x10, sp)
4842a3b7: 58 b0                 mov     (0xb0, sp), d0
4842a3b9: fc cd 19 00 06 00     mov     0x00060019, d1
4842a3bf: cd ce ef c0 24        call    0x4842938d, [d2,d3], 0x24
4842a3c4: 58 14                 mov     (0x14, sp), d0
4842a3c6: fc cd 09 00 06 00     mov     0x00060009, d1
4842a3cc: f8 12 08              mov     d0, (8, a2)
4842a3cf: 72                    mov     (a2), d0
4842a3d0: f4                    movbu   (d0, a3), d2
4842a3d1: 23 58                 add     0x58, a3
4842a3d3: b8                    cmp     a2, a0
4842a3d4: 2a bf                 add     -0x41, d2
4842a3d6: 42 10                 mov     d0, (0x10, sp)
4842a3d8: fc c2 00 00 0d 00     add     0xd0000, d2
4842a3de: 88                    mov     d2, d0
4842a3df: cd ae ef c0 24        call    0x4842938d, [d2,d3], 0x24
4842a3e4: 00                    clr     d0
4842a3e5: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a3e8: 5f b8                 mov     (0xb8, sp), a3
4842a3ea: 3e                    mov     sp, a2
4842a3eb: 22 18                 add     0x18, a2
4842a3ed: 4b 10                 mov     a2, (0x10, sp)
4842a3ef: 58 b0                 mov     (0xb0, sp), d0
4842a3f1: fc cd 19 00 06 00     mov     0x00060019, d1
4842a3f7: cd 96 ef c0 24        call    0x4842938d, [d2,d3], 0x24
4842a3fc: 58 14                 mov     (0x14, sp), d0
4842a3fe: fc cd 0a 00 06 00     mov     0x0006000a, d1
4842a404: f8 13 08              mov     d0, (8, a3)
4842a407: 73                    mov     (a3), d0
4842a408: f4                    movbu   (d0, a2), d2
4842a409: 22 58                 add     0x58, a2
4842a40b: b8                    cmp     a2, a0
4842a40c: 2a bf                 add     -0x41, d2
4842a40e: 42 10                 mov     d0, (0x10, sp)
4842a410: fc c2 00 00 0d 00     add     0xd0000, d2
4842a416: 88                    mov     d2, d0
4842a417: cd 76 ef c0 24        call    0x4842938d, [d2,d3], 0x24
4842a41c: 00                    clr     d0
4842a41d: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a420: 5f b8                 mov     (0xb8, sp), a3
4842a422: 3e                    mov     sp, a2
4842a423: 22 18                 add     0x18, a2
4842a425: 4b 10                 mov     a2, (0x10, sp)
4842a427: 58 b0                 mov     (0xb0, sp), d0
4842a429: fc cd 19 00 06 00     mov     0x00060019, d1
4842a42f: cd 5e ef c0 24        call    0x4842938d, [d2,d3], 0x24
4842a434: 58 14                 mov     (0x14, sp), d0
4842a436: fc cd 0b 00 06 00     mov     0x0006000b, d1
4842a43c: f8 13 08              mov     d0, (8, a3)
4842a43f: 73                    mov     (a3), d0
4842a440: f4                    movbu   (d0, a2), d2
4842a441: 22 58                 add     0x58, a2
4842a443: b8                    cmp     a2, a0
4842a444: 2a bf                 add     -0x41, d2
4842a446: 42 10                 mov     d0, (0x10, sp)
4842a448: fc c2 00 00 0d 00     add     0xd0000, d2
4842a44e: 88                    mov     d2, d0
4842a44f: cd 3e ef c0 24        call    0x4842938d, [d2,d3], 0x24
4842a454: 00                    clr     d0
4842a455: df f0 a8              ret     [d2,d3,a2,a3], 0xa8
4842a458: 5f b8                 mov     (0xb8, sp), a3
4842a45a: 3e                    mov     sp, a2
4842a45b: 22 18                 add     0x18, a2
4842a45d: 4b 10                 mov     a2, (0x10, sp)
4842a45f: 58 b0                 mov     (0xb0, sp), d0
4842a461: fc cd 19 00 06 00     mov     0x00060019, d1
4842a467: cd 26 ef c0 24        call    0x4842938d, [d2,d3], 0x24
4842a46c: 58 14                 mov     (0x14, sp), d0
4842a46e: fc cd 0c 00 06 00     mov     0x0006000c, d1
4842a474: f8 13 08              mov     d0, (8, a3)
4842a477: 73                    mov     (a3), d0
4842a478: f4                    movbu   (d0, a2), d2
4842a479: 22 58                 add     0x58, a2
4842a47b: b8                    cmp     a2, a0
4842a47c: 2a bf                 add     -0x41, d2
4842a47e: 42 10                 mov     d0, (0x10, sp)
4842a480: fc c2 00 00 0d 00     add     0xd0000, d2
4842a486: 88                    mov     d2, d0
4842a487: cd 06 ef c0 24        call    0x4842938d, [d2,d3], 0x24
4842a48c: ca 56                 bra     0x4842a4e2
4842a48e: 5c b8                 mov     (0xb8, sp), a0
4842a490: 88                    mov     d2, d0
4842a491: 43 10                 mov     a0, (0x10, sp)
4842a493: fc cd 0d 00 06 00     mov     0x0006000d, d1
4842a499: cd 6b 03 f0 10        call    0x4842a804, [d2,d3,a2,a3], 0x10
4842a49e: ca 44                 bra     0x4842a4e2
4842a4a0: 5c b8                 mov     (0xb8, sp), a0
4842a4a2: 88                    mov     d2, d0
4842a4a3: 43 10                 mov     a0, (0x10, sp)
4842a4a5: fc cd 0e 00 06 00     mov     0x0006000e, d1
4842a4ab: cd 59 03 f0 10        call    0x4842a804, [d2,d3,a2,a3], 0x10
4842a4b0: ca 32                 bra     0x4842a4e2
4842a4b2: 3e                    mov     sp, a2
4842a4b3: 22 18                 add     0x18, a2
4842a4b5: 4b 10                 mov     a2, (0x10, sp)
4842a4b7: 58 b0                 mov     (0xb0, sp), d0
4842a4b9: fc cd 19 00 06 00     mov     0x00060019, d1
4842a4bf: cd ce ee c0 24        call    0x4842938d, [d2,d3], 0x24
4842a4c4: 58 b8                 mov     (0xb8, sp), d0
4842a4c6: f4                    movbu   (d0, a2), d0
4842a4c7: 02 ca 1a              movbu   d0, (0x1aca)
4842a4ca: 5c b8                 mov     (0xb8, sp), a0
4842a4cc: dd 12 c2 fe ff f0 2c  call    0x484166de, [d2,d3,a2,a3], 0x2c
4842a4d3: 00                    clr     d0
4842a4d4: ca 0e                 bra     0x4842a4e2
4842a4d6: 5c b8                 mov     (0xb8, sp), a0
4842a4d8: 8d                    mov     d3, d1
4842a4d9: 43 10                 mov     a0, (0x10, sp)
4842a4db: 58 b0                 mov     (0xb0, sp), d0
4842a4dd: cd 8c f0 f0 28        call    0x48429569, [d2,d3,a2,a3], 0x28
4842a4e2: df f0 a8              ret     [d2,d3,a2,a3], 0xa8

InheritedProc:
4842a4e5: cf c0                 movm    [d2,d3], (sp)
4842a4e7: f8 fe ec              add     -0x14, sp
4842a4ea: 04                    clr     d1
4842a4eb: 08                    clr     d2
4842a4ec: fc dd ac fa 11 50     mov     0x5011faac, a1
4842a4f2: db                    setlb
4842a4f3: 1d                    exthu   d1
4842a4f4: 84                    mov     d1, d0
4842a4f5: f8 c0 04              asl     4, d0
4842a4f8: 8f ff                 mov     -1, d3
4842a4fa: f3 71                 mov     d3, (d0, a1)
4842a4fc: 84                    mov     d1, d0
4842a4fd: f8 c0 04              asl     4, d0
4842a500: f1 54                 add     a1, d0
4842a502: 0c                    clr     d3
4842a503: f1 e0                 mov     d0, a0
4842a505: f8 1c 04              mov     d3, (4, a0)
4842a508: 84                    mov     d1, d0
4842a509: f8 c0 04              asl     4, d0
4842a50c: f1 e0                 mov     d0, a0
4842a50e: f1 74                 add     a1, a0
4842a510: 00                    clr     d0
4842a511: f8 70 08              movhu   d0, (8, a0)
4842a514: f8 c1 04              asl     4, d1
4842a517: f1 55                 add     a1, d1
4842a519: f1 e4                 mov     d1, a0
4842a51b: f8 10 0c              mov     d0, (0xc, a0)
4842a51e: 48                    inc     d2
4842a51f: 89                    mov     d2, d1
4842a520: 1e                    exthu   d2
4842a521: fa ca 00 03           cmp     0x300, d2
4842a525: d0                    llt
4842a526: cd 3f ef 40 14        call    0x48429465, [d3], 0x14
4842a52b: cd 6a 71 f0 30        call    0x48431695, [d2,d3,a2,a3], 0x30
4842a530: cd af 40 00 20        call    0x4842e5df, 0, 0x20
4842a535: dd f0 ce 05 00 f0 3c  call    0x48487425, [d2,d3,a2,a3], 0x3c
4842a53c: dd a7 e7 05 00 f0 3c  call    0x48488ce3, [d2,d3,a2,a3], 0x3c
4842a543: dd 3d 8d 06 00 f0 3c  call    0x48493280, [d2,d3,a2,a3], 0x3c
4842a54a: dd 93 ff 05 00 f0 3c  call    0x4848a4dd, [d2,d3,a2,a3], 0x3c
4842a551: dd 67 f7 05 00 f0 3c  call    0x48489cb8, [d2,d3,a2,a3], 0x3c
4842a558: dd 9e cc 06 00 f0 3c  call    0x484971f6, [d2,d3,a2,a3], 0x3c
4842a55f: dd 5e 04 06 00 f0 3c  call    0x4848a9bd, [d2,d3,a2,a3], 0x3c
4842a566: dd b8 25 07 00 f0 3c  call    0x4849cb1e, [d2,d3,a2,a3], 0x3c
4842a56d: dd 15 cf 0d 00 f0 3c  call    0x48507482, [d2,d3,a2,a3], 0x3c
4842a574: dd 3b 68 0e 00 f0 3c  call    0x48510daf, [d2,d3,a2,a3], 0x3c
4842a57b: dd ec c5 0d 00 f0 3c  call    0x48506b67, [d2,d3,a2,a3], 0x3c
4842a582: dd 23 bc 13 00 f0 3c  call    0x485661a5, [d2,d3,a2,a3], 0x3c
4842a589: dd 03 2b 14 00 f0 3c  call    0x4856d08c, [d2,d3,a2,a3], 0x3c
4842a590: dd 75 9c 10 00 f0 3c  call    0x48534205, [d2,d3,a2,a3], 0x3c
4842a597: dd 2f 79 15 00 f0 3c  call    0x48581ec6, [d2,d3,a2,a3], 0x3c
4842a59e: dd c2 52 07 00 f0 3c  call    0x4849f860, [d2,d3,a2,a3], 0x3c
4842a5a5: dd d0 e3 07 00 f0 3c  call    0x484a8975, [d2,d3,a2,a3], 0x3c
4842a5ac: dd 8f b8 07 00 f0 3c  call    0x484a5e3b, [d2,d3,a2,a3], 0x3c
4842a5b3: dd e9 f2 0c 00 f0 3c  call    0x484f989c, [d2,d3,a2,a3], 0x3c
4842a5ba: dd b1 c2 0e 00 f0 3c  call    0x4851686b, [d2,d3,a2,a3], 0x3c
4842a5c1: dd 03 07 05 00 f0 3c  call    0x4847acc4, [d2,d3,a2,a3], 0x3c
4842a5c8: dd dd 48 07 00 f0 3c  call    0x4849eea5, [d2,d3,a2,a3], 0x3c
4842a5cf: dd 8f 36 0d 00 f0 3c  call    0x484fdc5e, [d2,d3,a2,a3], 0x3c
4842a5d6: dd a7 49 0a 00 f0 3c  call    0x484cef7d, [d2,d3,a2,a3], 0x3c
4842a5dd: dd 76 ae 0a 00 f0 3c  call    0x484d5453, [d2,d3,a2,a3], 0x3c
4842a5e4: dd 39 b9 0a 00 f0 3c  call    0x484d5f1d, [d2,d3,a2,a3], 0x3c
4842a5eb: dd d7 d5 0a 00 f0 3c  call    0x484d7bc2, [d2,d3,a2,a3], 0x3c
4842a5f2: dd be 32 12 00 f0 3c  call    0x4854d8b0, [d2,d3,a2,a3], 0x3c
4842a5f9: dd 0a bf 0e 00 f0 3c  call    0x48516503, [d2,d3,a2,a3], 0x3c
4842a600: cd b6 76 00 00        call    0x48431cb6, 0, 0
4842a605: cd b4 76 00 00        call    0x48431cb9, 0, 0
4842a60a: dd f7 3d 12 00 f0 3c  call    0x4854e401, [d2,d3,a2,a3], 0x3c
4842a611: dd 20 44 12 00 f0 3c  call    0x4854ea31, [d2,d3,a2,a3], 0x3c
4842a618: dd 33 89 14 00 f0 3c  call    0x48572f4b, [d2,d3,a2,a3], 0x3c
4842a61f: dd 76 37 15 00 f0 3c  call    0x4857dd95, [d2,d3,a2,a3], 0x3c
4842a626: cd 96 76 00 00        call    0x48431cbc, 0, 0
4842a62b: cd 94 76 00 00        call    0x48431cbf, 0, 0
4842a630: cd 92 76 00 00        call    0x48431cc2, 0, 0
4842a635: cd 90 76 00 00        call    0x48431cc5, 0, 0
4842a63a: dd d1 8f 15 00 f0 3c  call    0x4858360b, [d2,d3,a2,a3], 0x3c
4842a641: dd af 9e 15 00 f0 3c  call    0x485844f0, [d2,d3,a2,a3], 0x3c
4842a648: cd 80 76 00 00        call    0x48431cc8, 0, 0
4842a64d: cd 7e 76 00 00        call    0x48431ccb, 0, 0
4842a652: cd 7c 76 00 00        call    0x48431cce, 0, 0
4842a657: cd 7a 76 00 00        call    0x48431cd1, 0, 0
4842a65c: cd 78 76 00 00        call    0x48431cd4, 0, 0
4842a661: cd 76 76 00 00        call    0x48431cd7, 0, 0
4842a666: cd 8d 74 f0 3c        call    0x48431af3, [d2,d3,a2,a3], 0x3c
4842a66b: 00                    clr     d0
4842a66c: 42 10                 mov     d0, (0x10, sp)
4842a66e: 8e                    mov     d3, d2
4842a66f: fc c2 00 00 0e 00     add     0xe0000, d2
4842a675: fc cd 2c 00 06 00     mov     0x0006002c, d1
4842a67b: 88                    mov     d2, d0
4842a67c: cd 11 ed c0 24        call    0x4842938d, [d2,d3], 0x24
4842a681: 04                    clr     d1
4842a682: 46 10                 mov     d1, (0x10, sp)
4842a684: fc cd b5 00 06 00     mov     0x000600b5, d1
4842a68a: cd bb 06 e0 24        call    0x4842ad45, [d2,d3,a2], 0x24
4842a68f: 4c                    inc     d3
4842a690: 1f                    exthu   d3
4842a691: af 20                 cmp     0x20, d3
4842a693: c0 d8                 blt     0x4842a66b
4842a695: 0c                    clr     d3
4842a696: 00                    clr     d0
4842a697: 42 10                 mov     d0, (0x10, sp)
4842a699: 8e                    mov     d3, d2
4842a69a: fc c2 00 00 0f 00     add     0xf0000, d2
4842a6a0: fc cd 32 00 06 00     mov     0x00060032, d1
4842a6a6: 88                    mov     d2, d0
4842a6a7: cd e6 ec c0 24        call    0x4842938d, [d2,d3], 0x24
4842a6ac: 04                    clr     d1
4842a6ad: 46 10                 mov     d1, (0x10, sp)
4842a6af: fc cd b5 00 06 00     mov     0x000600b5, d1
4842a6b5: cd 90 06 e0 24        call    0x4842ad45, [d2,d3,a2], 0x24
4842a6ba: 4c                    inc     d3
4842a6bb: 1f                    exthu   d3
4842a6bc: fa cb 40 01           cmp     0x140, d3
4842a6c0: c0 d6                 blt     0x4842a696
4842a6c2: df c0 1c              ret     [d2,d3], 0x1c

UnRegisterObject:
4842a6c5: cf c0              movm    [d2,d3], (sp)
4842a6c7: 86                 mov     d1, d2
4842a6c8: 04                 clr     d1
4842a6c9: 83                 mov     d0, d3
4842a6ca: 1f                 exthu   d3
4842a6cb: 1e                 exthu   d2
4842a6cc: f1 e9              mov     d2, a1
4842a6ce: ab                 cmp     d2, d3
4842a6cf: c1 1a              bgt     0x4842a6e9
4842a6d1: db                 setlb
4842a6d2: 1c                 exthu   d0
4842a6d3: f8 c0 04           asl     4, d0
4842a6d6: f1 e0              mov     d0, a0
4842a6d8: fc d0 ac fa 11 50  add     0x5011faac, a0
4842a6de: f8 68 08           movhu   (8, a0), d2
4842a6e1: 1d                 exthu   d1
4842a6e2: e9                 add     d2, d1
4842a6e3: 4c                 inc     d3
4842a6e4: 8c                 mov     d3, d0
4842a6e5: 1f                 exthu   d3
4842a6e6: f1 97              cmp     a1, d3
4842a6e8: d3                 lle
4842a6e9: 84                 mov     d1, d0
4842a6ea: de c0 08           retf    [d2,d3], 8

CountObject:
4842a6ed: 81                 mov     d0, d1
4842a6ee: f8 c5 10           lsr     16, d1
4842a6f1: 1d                 exthu   d1
4842a6f2: f8 c1 04           asl     4, d1
4842a6f5: f1 e4              mov     d1, a0
4842a6f7: fc d0 ac fa 11 50  add     0x5011faac, a0
4842a6fd: f8 20 0c           mov     (0xc, a0), a0
4842a700: b0 00              cmp     0, a0
4842a702: c9 05              bne     0x4842a707
4842a704: 00                 clr     d0
4842a705: ca 0f              bra     0x4842a714
4842a707: 1c                 exthu   d0
4842a708: 54                 asl2    d0
4842a709: f3 00              mov     (d0, a0), d0
4842a70b: a0 00              cmp     0, d0
4842a70d: c9 05              bne     0x4842a712
4842a70f: 00                 clr     d0
4842a710: ca 04              bra     0x4842a714
4842a712: 80 01              mov     1, d0
4842a714: de 00 00           retf    0, 0

InitializeObjectTable:
4842a717: 81                 mov     d0, d1
4842a718: 1c                 exthu   d0
4842a719: fa c8 ff 02        cmp     0x2ff, d0
4842a71d: c1 17              bgt     0x4842a734
4842a71f: 1d                 exthu   d1
4842a720: f8 c1 04           asl     4, d1
4842a723: f1 e5              mov     d1, a1
4842a725: fc d1 ac fa 11 50  add     0x5011faac, a1
4842a72b: 80 fc              mov     -4, d0
4842a72d: db                 setlb
4842a72e: 74                 mov     (a0), d1
4842a72f: 50                 inc4    a0
4842a730: 65                 mov     d1, (a1)
4842a731: 51                 inc4    a1
4842a732: 40                 inc     d0
4842a733: d9                 lne
4842a734: de 00 00           retf    0, 0

RegisterObjectTable:
4842a737: cf f0              movm    [d2,d3,a2,a3], (sp)
4842a739: f8 fe f8           add     -8, sp
4842a73c: 42 20              mov     d0, (0x20, sp)
4842a73e: 93                 mov     a0, a3
4842a73f: cd ff ec 00 10     call    0x4842943e, 0, 0x10
4842a744: 81                 mov     d0, d1
4842a745: f8 c5 10           lsr     16, d1
4842a748: 1d                 exthu   d1
4842a749: f1 e6              mov     d1, a2
4842a74b: fc dd ac fa 11 50  mov     0x5011faac, a1
4842a751: 84                 mov     d1, d0
4842a752: f8 c0 04           asl     4, d0
4842a755: f1 54              add     a1, d0
4842a757: f1 e0              mov     d0, a0
4842a759: f8 20 0c           mov     (0xc, a0), a0
4842a75c: 00                 clr     d0
4842a75d: 0c                 clr     d3
4842a75e: db                 setlb
4842a75f: 82                 mov     d0, d2
4842a760: 1e                 exthu   d2
4842a761: 88                 mov     d2, d0
4842a762: 54                 asl2    d0
4842a763: f3 00              mov     (d0, a0), d0
4842a765: a0 00              cmp     0, d0
4842a767: c9 3e              bne     0x4842a7a5
4842a769: 88                 mov     d2, d0
4842a76a: 54                 asl2    d0
4842a76b: f3 f0              mov     a3, (d0, a0)
4842a76d: 58 20              mov     (0x20, sp), d0
4842a76f: 1d                 exthu   d1
4842a770: 63                 mov     d0, (a3)
4842a771: f8 c1 04           asl     4, d1
4842a774: 94                 mov     a1, a0
4842a775: f1 64              add     d1, a0
4842a777: fa 20 8c 00        mov     (0x8c, a0), a0
4842a77b: 56                 asl2    d2
4842a77c: fc cc 44 df 5a 48  mov     0x485adf44, d0
4842a782: f3 48              mov     d0, (d2, a0)
4842a784: f1 d8              mov     a2, d0
4842a786: f8 c0 04           asl     4, d0
4842a789: f1 54              add     a1, d0
4842a78b: f1 e0              mov     d0, a0
4842a78d: f8 68 08           movhu   (8, a0), d2
4842a790: f1 d9              mov     a2, d1
4842a792: f8 c1 04           asl     4, d1
4842a795: f1 55              add     a1, d1
4842a797: 48                 inc     d2
4842a798: f1 e4              mov     d1, a0
4842a79a: f8 78 08           movhu   d2, (8, a0)
4842a79d: f1 d8              mov     a2, d0
4842a79f: f8 c0 10           asl     16, d0
4842a7a2: ec                 add     d3, d0
4842a7a3: ca 0c              bra     0x4842a7af
4842a7a5: 4c                 inc     d3
4842a7a6: 8c                 mov     d3, d0
4842a7a7: 1f                 exthu   d3
4842a7a8: fa cb 00 10        cmp     0x1000, d3
4842a7ac: d0                 llt
4842a7ad: 80 ff              mov     -1, d0
4842a7af: df f0 18           ret     [d2,d3,a2,a3], 0x18

RegisterObject:
4842a7b2: cf e0              movm    [d2,d3,a2], (sp)
4842a7b4: 82                 mov     d0, d2
4842a7b5: f8 c6 10           lsr     16, d2
4842a7b8: 1e                 exthu   d2
4842a7b9: f1 e9              mov     d2, a1
4842a7bb: fc cf ac fa 11 50  mov     0x5011faac, d3
4842a7c1: 89                 mov     d2, d1
4842a7c2: f8 c1 04           asl     4, d1
4842a7c5: ed                 add     d3, d1
4842a7c6: f1 e4              mov     d1, a0
4842a7c8: f8 20 0c           mov     (0xc, a0), a0
4842a7cb: 1c                 exthu   d0
4842a7cc: 81                 mov     d0, d1
4842a7cd: 55                 asl2    d1
4842a7ce: 9a 00              mov     0, a2
4842a7d0: f3 e4              mov     a2, (d1, a0)
4842a7d2: 1e                 exthu   d2
4842a7d3: 89                 mov     d2, d1
4842a7d4: f8 c1 04           asl     4, d1
4842a7d7: ed                 add     d3, d1
4842a7d8: f1 e4              mov     d1, a0
4842a7da: fa 20 8c 00        mov     (0x8c, a0), a0
4842a7de: 54                 asl2    d0
4842a7df: fc cd 48 df 5a 48  mov     0x485adf48, d1
4842a7e5: f3 50              mov     d1, (d0, a0)
4842a7e7: f1 d4              mov     a1, d0
4842a7e9: f8 c0 04           asl     4, d0
4842a7ec: ec                 add     d3, d0
4842a7ed: f1 e0              mov     d0, a0
4842a7ef: f8 68 08           movhu   (8, a0), d2
4842a7f2: f1 d4              mov     a1, d0
4842a7f4: f8 c0 04           asl     4, d0
4842a7f7: e3                 add     d0, d3
4842a7f8: 2a ff              add     -1, d2
4842a7fa: f1 ec              mov     d3, a0
4842a7fc: f8 78 08           movhu   d2, (8, a0)
4842a7ff: de e0 0c           retf    [d2,d3,a2], 0xc
