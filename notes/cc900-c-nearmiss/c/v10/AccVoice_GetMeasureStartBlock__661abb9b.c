/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-30-p6-r1)
   sha256 661abb9b1607433d32862ee68a6f8b4ea5a2c002087e5a7b864f5b7e199c0570 (tar-sha256); compiled at -Xr */
struct mcell { unsigned int blk, off; };
struct mrow { struct mcell c[8]; };
struct mrec { struct mrow r[5]; };
unsigned int AccVoice_GetMeasureStartBlock(unsigned char a, unsigned char b, unsigned char c)
{
    return ((struct mrec *)0x95440)[a].r[b].c[c].blk;
}
