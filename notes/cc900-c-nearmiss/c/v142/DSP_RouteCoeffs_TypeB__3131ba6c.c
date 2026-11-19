/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w3a.c (2026-11-19-10-sub-r23w-asm)
   sha256 3131ba6ce52619a70fd697c12df6ce15b0df07ab4801545fe99e86ef6e816881 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_45210[];
extern unsigned char *ram_45310;
struct dspc { char pad[68]; unsigned long o68; unsigned long o72; unsigned long o76; unsigned long o80;
              unsigned long o84; unsigned long o88; unsigned long o92; unsigned long o96; unsigned long o100; };
extern struct dspc *ram_45314;
void DSP_RouteCoeffs_TypeB(unsigned int a, unsigned int c)
{
    unsigned int s, row;
    unsigned long off;
    unsigned char (*t)[16];
    unsigned int i, n;
    a &= 0x7f;
    s = c;
    c &= 0x0f;
    switch (s & 0xc0) {
    case 0: off = ram_45314->o88; break;
    case 0x40: off = ram_45314->o96; break;
    case 0x80: off = ram_45314->o92; break;
    case 0xc0: off = ram_45314->o88; break;
    }
    row = *(unsigned long *)(((c << 7) + a) * 2 + off + ram_45310);
    off = ram_45314->o100;
    t = (unsigned char (*)[16])(ram_45310 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = t[row][i];
}
