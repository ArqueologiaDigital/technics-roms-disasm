/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char ram_451cc[];
extern unsigned char ram_4308e[];
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void Voice_ComputeVolume_CappedLFO(unsigned char *v);
void Voice_Calc_LevelPair_EGA(unsigned char *v);
void Voice_Calc_LevelPair_EGB(unsigned char *v);
void Voice_Calc_LevelPair_EGC(unsigned char *v);
void Voice_Cut(unsigned char n)
{
    unsigned char *v;
    unsigned char *s;
    unsigned int w;
    v = &ram_4308e[n * 71];
    s = P(v, 35);
    v[5] &= 0x7f;
    w = W(s, 10);
    if (v[3] == 3) W(s, 10) &= ~1;
    if (((unsigned long)W(v, 1) & 0x8000) || !(W(P(v, 35), 10) & 1)) {
        if (v[3] < 3) Voice_ComputeVolume_CappedLFO(v);
        else Voice_Calc_LevelPair_EGA(v);
        Voice_Calc_LevelPair_EGB(v);
        Voice_Calc_LevelPair_EGC(v);
        ToneGen_WriteLevelBurst(n, ram_451cc);
    }
    W(s, 10) = w;
}
