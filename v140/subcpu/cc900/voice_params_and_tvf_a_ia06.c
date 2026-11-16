/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void TVF_Build_Short(unsigned char *v);
void Voice_PitchPack_RouteB(unsigned char *v);

/* cc900-module: TVF_Bias_Clamp_Amount TVF_Calc_Cutoff_NoKeyFollow TVF_Lookup_Depth_Amount */
void TVF_Build_Short(unsigned char *v)
{
    unsigned char *t;
    unsigned char *u;
    int r;
    unsigned int x;
    u = (*(unsigned char **)((v) + (23)));
    t = u;
    r = TVF_Calc_Cutoff_NoKeyFollow(v, u[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    (*(int *)((v) + (66))) = r | x;
    r = TVF_Bias_Clamp_Amount(t[19]);
    (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(t[20]);
}

void Voice_PitchPack_RouteB(unsigned char *v)
{
    unsigned char *t;
    unsigned char *u;
    int r;
    unsigned int x;
    u = (*(unsigned char **)((v) + (23)));
    t = u;
    r = TVF_Calc_Cutoff_NoKeyFollow(v, u[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    (*(int *)((v) + (66))) = (r | x) | 0x80;
    r = TVF_Bias_Clamp_Amount(t[19]);
    (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(t[20]);
}
