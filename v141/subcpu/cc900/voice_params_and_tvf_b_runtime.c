/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
   Held back from subcpu/cc900/ (2026-11-16): these call the C runtime (C9H_mulls / C9H_divls ...), whose
   names the build does not map to the payload's Math_Multiply32 / Long_SignedDiv yet.
*/

extern unsigned int EGEnv_ValueCurve_Simple[];
extern unsigned char ram_44236[];

unsigned long EGEnv_Compute_A_Simple(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = &ram_44236[(int)n * 27];
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (r > 0x3fff) r = 0x3fff;
    return r;
}

unsigned long EGEnv_Compute_A_Simple_Dup(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = &ram_44236[(int)n * 27];
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (r > 0x3fff) r = 0x3fff;
    return r;
}
