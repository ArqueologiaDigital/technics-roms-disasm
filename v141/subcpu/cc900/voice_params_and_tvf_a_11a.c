/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern int __near ram_2940;
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);

/* cc900-module: TVF_Calc_Cutoff */
void Voice_PitchPack_Mode5_Dual(unsigned char *v)
{
    unsigned char *z;
    int c1, c2;
    unsigned int x;
    z = (*(unsigned char **)((v) + (23)));
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (2))) & 0x200) {
        c1 = z[77];
        c2 = z[79];
    } else {
        c1 = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
        c2 = (int)z[79] + (char)(*(unsigned char **)((v) + (35)))[103];
    }
    c1 = TVF_Calc_Cutoff(v, c1, (char)z[55], (char)z[60]);
    c2 = TVF_Calc_Cutoff(v, c2, (char)z[55], (char)z[60]);
    x = ((unsigned int)z[78] << 13) | ((unsigned int)z[80] << 10);
    (*(int *)((v) + (66))) = (c1 | x) | 0x80;
    (*(int *)((v) + (68))) = c2;
    ram_2940 = 0;
}
