/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17c.c (2026-11-16-126-sub-r17)
   sha256 50a987cbc6cdbc37c89132eff20ee2e3fdc579b48bf25a3767fa1b68170ec996 (name+funcs); compiled at -Xr */
extern unsigned int ram_451e4;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int PitchBend_Scale(int a, int b, int c);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v)
{
    unsigned char *f, *s;
    int x, lv, t, a, b, r;
    f = *(unsigned char **)(v + 19);
    s = *(unsigned char **)(v + 23);
    *(unsigned int *)(v + 1) |= 0x8000;
    t = Voice_LevelPair_AttackCurve[s[8]];
    lv = t;
    if (s[14] != 0) {
        lv += PitchBend_Scale((char)s[14], v[12], 4);
        lv = Int_ClampSignedToRange(lv, 0xff, 0);
    }
    t = lv << 8;
    x = t;
    x |= 0x7f;
    ram_451e4 = x;
    *(unsigned int *)(v + 60) = x;
    t = Voice_EnvelopeLevel_Curve[s[9]];
    a = t;
    t = Voice_EnvelopeLevel_Curve[s[11]];
    b = t;
    t = Voice_EnvelopeRate_Table[s[10]];
    r = t;
    t = 4;
    if (r >= 4) t = r;
    r = t;
    *(unsigned int *)(v + 62) = (a << 8) | (t & 0xff);
    if (f[13] & 0x20) {
        *(unsigned int *)(v + 64) = (b << 8) | ((int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}
