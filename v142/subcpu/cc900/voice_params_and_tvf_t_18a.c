/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_44257[];
extern unsigned int EGEnv_BaseCurve_B[];
extern int EGEnv_ModeBits_Table[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);

/* cc900-module: EnvDepth_Cap */
unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = ram_44257 + (int)n * 27;
    p = u;
    w = EGEnv_BaseCurve_B[u[1]];
    x = w;
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}
