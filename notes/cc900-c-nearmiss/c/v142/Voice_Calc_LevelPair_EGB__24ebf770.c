/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_10b.c (2026-11-16-90-sub-r10)
   sha256 24ebf7703374f0d36c1b8e8151e4a71dec75b1d509bf03c2cb1c85687b785c4a (name+funcs); compiled at -Xr */
extern unsigned int ram_451fc;
extern unsigned int ram_451fe;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
void Voice_Calc_LevelPair_EGB(unsigned char *v)
{
    unsigned char *s;
    int lv, t, d;
    t = Voice_EnvelopeLevel_Curve[(s = *(unsigned char **)(v + 23))[15]];
    lv = t;
    if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if (t <= lv) lv = t;
    }
    if (s[22] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[19], 0, 0x7f, (char)s[22]);
        if (s[17] != 0) {
            lv += PitchBend_Scale((char)s[17], v[12], 4);
            lv = Int_ClampSignedToRange(lv, 0xff, 0);
        } else lv = Int_ClampSignedToRange(lv, 0xff, 0);
    } else if (s[17] != 0) {
        lv += PitchBend_Scale((char)s[17], v[12], 4);
        lv = Int_ClampSignedToRange(lv, 0xff, 0);
    }
    if ((char)s[7] < 0) d = Detune_ScaleSymmetric(~(int)(char)s[16] + 1);
    else d = Detune_ScaleSymmetric((char)s[16]);
    t = (lv << 8) | (d & 0xff);
    ram_451fc = t;
    ram_451fe = t;
}
