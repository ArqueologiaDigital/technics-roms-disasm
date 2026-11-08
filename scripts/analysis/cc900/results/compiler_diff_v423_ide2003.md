## run 2026-11-08-7-micro, O3XS

| file           | function | first difference: v423 | ide2003    |
|----------------|----------|------------------------|------------|
| micro/ctrl.asm | _c_do    | djnz IZ,L1             | sub IZ,0x1 |
| micro/mem.asm  | _m_gps_a | add WA,0xc             | ld BC,WA   |

micro/ctrl.asm: 1 of 21 functions differ
micro/mem.asm: 1 of 21 functions differ
TOTAL 2 of 674 functions differ (v423 vs ide2003, O3XS)

## run 2026-11-08-7-micro, O3XSXr

| file           | function | first difference: v423 | ide2003    |
|----------------|----------|------------------------|------------|
| micro/ctrl.asm | .c_do    | djnz IZ,L1             | sub IZ,0x1 |
| micro/mem.asm  | .m_gps_a | add WA,0xc             | ld BC,WA   |

micro/ctrl.asm: 1 of 21 functions differ
micro/mem.asm: 1 of 21 functions differ
TOTAL 2 of 674 functions differ (v423 vs ide2003, O3XSXr)

## run 2026-11-08-8-micro-ra, O3XS

| file              | function    | first difference: v423 | ide2003    |
|-------------------|-------------|------------------------|------------|
| micro/ra_call.asm | _rc_dowhile | djnz IZ,L1             | sub IZ,0x1 |

micro/ra_call.asm: 1 of 19 functions differ
TOTAL 1 of 42 functions differ (v423 vs ide2003, O3XS)

## run 2026-11-08-8-micro-ra, O3XSXr

| file              | function    | first difference: v423 | ide2003    |
|-------------------|-------------|------------------------|------------|
| micro/ra_call.asm | .rc_dowhile | djnz IZ,L1             | sub IZ,0x1 |

micro/ra_call.asm: 1 of 19 functions differ
TOTAL 1 of 42 functions differ (v423 vs ide2003, O3XSXr)

## run 2026-11-08-9-micro-optloops, O3XS

| file | function | first difference: v423 | ide2003 |
|------|----------|------------------------|---------|


## run 2026-11-08-9-micro-optloops, O3XSXr

| file | function | first difference: v423 | ide2003 |
|------|----------|------------------------|---------|


