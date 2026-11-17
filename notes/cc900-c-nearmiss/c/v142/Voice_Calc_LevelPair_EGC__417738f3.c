/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_11a.c (2026-11-16-94-sub-r11)
   sha256 417738f3d62e20bf0e2a89fd727dcb7d7fab4dcb3644db259e9daf07323b4c99 (name+funcs); compiled at -Xr */
extern unsigned int ram_45200;
extern unsigned int ram_45202;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
void Voice_Calc_LevelPair_EGC(unsigned char *v)
{
    unsigned char *s;
    int lv, t, d;
    unsigned char *p;
    p = *(unsigned char **)(v + 23);
    s = p;
    t = Voice_EnvelopeLevel_Curve[p[69]];
    lv = t;
    if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if (t <= lv) lv = t;
    }
    if (s[76] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[73], 0, 0x7f, (char)s[76]);
        if (s[71] != 0) {
            lv += PitchBend_Scale((char)s[71], v[12], 4);
            lv = Int_ClampSignedToRange(lv, 0xff, 0);
        } else lv = Int_ClampSignedToRange(lv, 0xff, 0);
    } else if (s[71] != 0) {
        lv += PitchBend_Scale((char)s[71], v[12], 4);
        lv = Int_ClampSignedToRange(lv, 0xff, 0);
    }
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[61] + (int)(char)s[70], 50, -50));
    t = (lv << 8) | (d & 0xff);
    ram_45200 = t;
    ram_45202 = t;
}
