/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_28a.c (2026-11-19-41-sub-r28a)
   sha256 171dfa2c8ce14025eecb1a203d19a14d1d04c0b671a74452bb1e26cc67652723 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int Voice_Clamp_Byte_HL(int a);
void Voice_Calc_LevelPair_EGA(unsigned char *v)
{
    unsigned char *s;
    int lv, t;
    int k;
    s = *(unsigned char **)(v + 23);
    lv = Int_ClampSignedToRange((int)s[45] + (int)(*(char **)(v + 35))[108], 100, 0);
    k = Voice_EnvelopeLevel_Curve[(unsigned char)lv];
    lv = k;
    if ((*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) && !(*(unsigned int *)(v + 1) & 0x100)) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if (t <= lv) lv = t;
    }
    if (s[53] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[48], s[49], s[50], (char)s[53]);
        lv = Voice_Clamp_Byte_HL(lv);
    }
    ram_451f8 = (lv << 8) | 0x80;
    ram_451fa = lv << 8;
}
