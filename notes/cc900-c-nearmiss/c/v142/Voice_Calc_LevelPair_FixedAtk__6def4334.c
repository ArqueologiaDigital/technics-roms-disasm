/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_10a.c (2026-11-16-90-sub-r10)
   sha256 6def4334393a34554eac6ed8e6a3f038b85a58ba9862378261f0ef33018b0276 (name+funcs); compiled at -Xr */
extern unsigned int ram_451e4;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int PitchBend_Scale(int a, int b, int c);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v)
{
    unsigned char *f, *s;
    int lv, t, a, b, r;
    f = *(unsigned char **)(v + 19);
    s = *(unsigned char **)(v + 23);
    *(unsigned int *)(v + 1) |= 0x8000;
    t = Voice_LevelPair_AttackCurve[s[8]];
    lv = t;
    if (s[14] != 0) {
        lv += PitchBend_Scale((char)s[14], v[12], 4);
        lv = Int_ClampSignedToRange(lv, 0xff, 0);
    }
    *(unsigned int *)(v + 60) = ram_451e4 = (lv << 8) | 0x7f;
    a = Voice_EnvelopeLevel_Curve[s[9]];
    b = Voice_EnvelopeLevel_Curve[s[11]];
    r = Voice_EnvelopeRate_Table[s[10]];
    r = r < 4 ? 4 : r;
    *(unsigned int *)(v + 62) = (a << 8) | (r & 0xff);
    if (f[13] & 0x20) {
        *(unsigned int *)(v + 64) = (b << 8) | ((int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}
