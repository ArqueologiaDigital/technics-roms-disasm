/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);

/* cc900-module: TVF_Clamp_Cutoff */
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    unsigned char *t;
    unsigned char s;
    int d, k;
    t = (*(unsigned char **)((v) + (23)));
    s = t[16];
    d = (char)s;
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        d >>= 5;
        c += (unsigned int)d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
