/* Functions of core/09_dsp_algo_select.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_451f8[];
extern unsigned char *ram_452f8;
struct dspc { char pad[68]; unsigned long o68; unsigned long o72; unsigned long o76; unsigned long o80;
              unsigned long o84; unsigned long o88; unsigned long o92; unsigned long o96; unsigned long o100; };
extern struct dspc *ram_452fc;

void DSP_CopyCoeffs_TypeA(unsigned int row)
{
    unsigned char (*t)[16];
    unsigned int i, n;
    unsigned long off;
    off = ram_452fc->o80;
    t = (unsigned char (*)[16])(ram_452f8 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_451f8[i + 6] = t[row][i];
}

void DSP_CopyCoeffs_TypeB(unsigned int row)
{
    unsigned char (*t)[16];
    unsigned int i, n;
    unsigned long off;
    off = ram_452fc->o100;
    t = (unsigned char (*)[16])(ram_452f8 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_451f8[i + 6] = t[row][i];
}

void DSP_RouteCoeffs_TypeA(unsigned int a, unsigned int c)
{
    unsigned int s, row;
    unsigned long off;
    unsigned char (*t)[16];
    unsigned int n, i;
    a &= 0x7f;
    s = c;
    c &= 0x0f;
    switch (s & 0xc0) {
    case 0: off = ram_452fc->o68; break;
    case 0x40: off = ram_452fc->o76; break;
    case 0x80: off = ram_452fc->o72; break;
    case 0xc0: off = ram_452fc->o68; break;
    }
    row = *(unsigned long *)(((c << 7) + a) * 2 + off + ram_452f8);
    off = ram_452fc->o80;
    t = (unsigned char (*)[16])(ram_452f8 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_451f8[i + 6] = t[row][i];
}

void DSP_RouteCoeffs_TypeB(unsigned int a, unsigned int c)
{
    unsigned int s, row;
    unsigned long off;
    unsigned char (*t)[16];
    unsigned int n, i;
    a &= 0x7f;
    s = c;
    c &= 0x0f;
    switch (s & 0xc0) {
    case 0: off = ram_452fc->o88; break;
    case 0x40: off = ram_452fc->o96; break;
    case 0x80: off = ram_452fc->o92; break;
    case 0xc0: off = ram_452fc->o88; break;
    }
    row = *(unsigned long *)(((c << 7) + a) * 2 + off + ram_452f8);
    off = ram_452fc->o100;
    t = (unsigned char (*)[16])(ram_452f8 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_451f8[i + 6] = t[row][i];
}
