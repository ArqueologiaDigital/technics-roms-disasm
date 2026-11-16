/* Functions of core/09_dsp_algo_select.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_451c4[];
extern unsigned char *ram_452c4;
struct dspc { char pad[68]; unsigned long o68; unsigned long o72; unsigned long o76; unsigned long o80;
              unsigned long o84; unsigned long o88; unsigned long o92; unsigned long o96; unsigned long o100; };
extern struct dspc *ram_452c8;

void DSP_CopyCoeffs_TypeA(unsigned int row)
{
    unsigned char (*t)[16];
    unsigned int i, n;
    unsigned long off;
    off = ram_452c8->o80;
    t = (unsigned char (*)[16])(ram_452c4 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_451c4[i + 6] = t[row][i];
}

void DSP_CopyCoeffs_TypeB(unsigned int row)
{
    unsigned char (*t)[16];
    unsigned int i, n;
    unsigned long off;
    off = ram_452c8->o100;
    t = (unsigned char (*)[16])(ram_452c4 + off);
    n = 13;
    for (i = 0; i < n; i++)
        ram_451c4[i + 6] = t[row][i];
}
