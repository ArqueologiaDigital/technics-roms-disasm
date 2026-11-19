/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_27a.c (2026-11-19-35-sub-r27a)
   sha256 acd294a39250b0a4dd4b4b3f38b1768b9323a40ceaec4a1bb6dcbe3ccec2ba4c (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int ram_451e4;
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
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
    t = lv << 8;
    r = t;
    r |= 0x7f;
    ram_451e4 = r;
    *(unsigned int *)(v + 60) = r;
    t = Voice_EnvelopeLevel_Curve[s[9]];
    a = t;
    t = Voice_EnvelopeLevel_Curve[s[11]];
    b = t;
    t = Voice_EnvelopeRate_Table[s[10]];
    r = t;
    t = r < 4 ? 4 : r;
    r = t;
    *(unsigned int *)(v + 62) = (a << 8) | (t & 0xff);
    if (f[13] & 0x20) {
        b = (b << 8) | ((int)Voice_EnvelopeRate_Table[s[12]] & 0xff);
        *(unsigned int *)(v + 64) = b;
        t = Voice_EnvelopeLevel_Curve[s[13]];
        v[70] = t;
    } else {
        *(unsigned int *)(v + 64) = b << 8;
        v[70] = 0;
    }
}
