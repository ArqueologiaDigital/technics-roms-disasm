/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-31-p6-r1b)
   sha256 3f150caa4e8af344bb960480c9e2d9301aeff28c615c172cb13fb76c7a3f84d7 (tar-sha256); compiled at -Xr */
struct mcell { unsigned int blk, off; };
struct mrow { struct mcell c[8]; };
struct mrec { struct mrow r[5]; };
unsigned int AccVoice_GetMeasureStartBlock(unsigned char a, unsigned char b, unsigned char c)
{
    return ((struct mrec *)0x95440)[a].r[b].c[c].blk;
}
