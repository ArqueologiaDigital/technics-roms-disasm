/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_3a.c (2026-11-16-58-sub-r3)
   sha256 99e952f60a590931da21e8c6184efc818dce0d30099b96db61b5a5c174d03956 (name+funcs); compiled at -Xr */
extern unsigned char ram_45210[];
extern unsigned char *ram_45310;
struct dspc { char pad[68]; unsigned long o68; unsigned long o72; unsigned long o76; unsigned long o80;
              unsigned long o84; unsigned long o88; unsigned long o92; unsigned long o96; unsigned long o100; };
extern struct dspc *ram_45314;
void DSP_RouteCoeffs_TypeA(unsigned int a, unsigned int c)
{
    unsigned long off;
    unsigned int s, row, i, n;
    unsigned char (*t)[16];
    a &= 0x7f;
    s = c;
    c &= 0x0f;
    switch (s & 0xc0) {
    case 0: off = ram_45314->o68; break;
    case 0x40: off = ram_45314->o76; break;
    case 0x80: off = ram_45314->o72; break;
    case 0xc0: off = ram_45314->o68; break;
    }
    row = *(unsigned long *)(((c << 7) + a) * 2 + off + ram_45310);
    off = ram_45314->o80;
    t = (unsigned char (*)[16])(ram_45310 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = t[row][i];
}
