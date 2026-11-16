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
extern unsigned int ram_451ba;
extern unsigned int ram_451be;
extern unsigned int EGEnv_ValueCurve_Simple[];
extern unsigned char ram_44214[];
extern unsigned char __near ram_1e4d[];
extern unsigned char __near ram_2126[];
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
void VoiceRow_FetchPair_WA_SP(int a);
void VoiceRow_FetchPair_DE_WA(int a, int c);
void VoiceSlot_UpdateNoteSource(unsigned char a, unsigned char c, unsigned char e);
void Voice_Freq_WriteRight(unsigned char n);
void Voice_PitchPack_RouteD(unsigned char *v);
void Voice_PitchPack_RouteE(unsigned char *v);

/* cc900-module: TVF_Calc_Cutoff_NoKeyFollow VoiceRow_FetchPair_DE_WA VoiceRow_FetchPair_WA_SP */
void VoiceSlot_UpdateNoteSource(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *s;
    unsigned char *r;
    unsigned char k;
    s = &ram_2126[(int)a * 5];
    r = &ram_1e4d[(int)s[2] * 27];
    k = s[3];
    if (r[k] == a) {
        if (s[0] != a) r[k] = s[0];
        else r[k] = 0xff;
    }
    r = &ram_1e4d[(int)c * 27];
    if (r[e] > 0xc0) {
        r[e] = a;
        VoiceRow_FetchPair_WA_SP(a);
    } else VoiceRow_FetchPair_DE_WA(a, r[e]);
    s[2] = c;
    s[3] = e;
}

void Voice_Freq_WriteRight(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = (unsigned char *)(void *)(ram_44214 + (int)n * 27);
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (n < 0x40) {
        if (r > 0x3fff) r = 0x3fff;
        if (p[0] & 0x20) {
            r |= 0x8000;
            ram_451ba = r;
        } else ram_451ba = r;
    } else {
        if (r > 0x3fff) r = 0x3fff;
        ram_451be = r;
    }
}

void Voice_PitchPack_RouteD(unsigned char *v)
{
    unsigned char *t;
    unsigned int r, x;
    t = (*(unsigned char **)((v) + (23)));
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    x = ((unsigned int)t[18] << 13) | ((unsigned int)t[18] << 10);
    (*(int *)((v) + (66))) = (r | x) | 0x80;
    r |= 0x80;
    (*(int *)((v) + (68))) = r;
    ram_2940 = 0;
}

void Voice_PitchPack_RouteE(unsigned char *v)
{
    unsigned char *t;
    unsigned int r1, r2, x;
    t = (*(unsigned char **)((v) + (23)));
    r1 = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    r2 = TVF_Calc_Cutoff_NoKeyFollow(v, t[19]);
    x = ((unsigned int)t[18] << 13) | ((unsigned int)t[20] << 10);
    (*(int *)((v) + (66))) = (r1 | x) | 0x80;
    (*(int *)((v) + (68))) = r2;
    ram_2940 = 0;
}
