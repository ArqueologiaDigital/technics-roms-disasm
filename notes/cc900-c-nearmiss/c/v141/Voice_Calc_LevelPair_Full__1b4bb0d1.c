/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_envelopes_and_channels_ag_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 1b4bb0d186058d9acd2018736b641e21f68bf71d32d6b7249cfa49e3ef574558 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int ram_451cc;
extern unsigned int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned char Voice_LevelPair_AttackCurve[];
extern unsigned char Voice_LevelPair_Bit11Default;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvelopeRate_Table[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
void Voice_Calc_LevelPair_Full(unsigned char *v)
{
    unsigned char *p;
    int lv;
    int t;
    int d;
    int l1, l2;
    int w, r, y;
    int k;
    p = *(unsigned char **)(v + 23);
    if ((*(unsigned char **)(v + 19))[16] & 0x10) *(unsigned int *)(v + 1) &= 0x7fff;
    else *(unsigned int *)(v + 1) |= 0x8000;
    if (*(unsigned int *)(v + 1) & 0x800) {
        k = Voice_LevelPair_Bit11Default;
        lv = k;
    } else {
        lv = Int_ClampSignedToRange((int)p[39] + (int)(*(char **)(v + 35))[268], 100, 0);
        k = Voice_LevelPair_AttackCurve[(unsigned char)lv];
        lv = k;
        if (p[51] != 0) {
            t = Pan_ScaleWithVelocity(*(int *)(v + 8), p[48], p[49], p[50], (char)p[51]);
            if (p[46] != 0) {
                d = PitchBend_Scale((char)p[46], v[12], 4);
                lv = Int_ClampSignedToRange(lv + t + d, 0xff, 0);
            } else lv = Int_ClampSignedToRange(lv + t, 0xff, 0);
        } else if (p[46] != 0) {
            d = PitchBend_Scale((char)p[46], v[12], 4);
            lv = Int_ClampSignedToRange(lv + d, 0xff, 0);
        }
    }
    if (**(unsigned char **)(v + 31) & 1) {
        k = lv;
        if (k == 0xff) lv--;
    }
    w = (lv << 8) | ((int)Voice_EnvelopeRate_Table[p[40]] & 0xff);
    ram_451cc = w;
    *(unsigned int *)(v + 60) = w;
    l1 = Voice_EnvelopeLevel_Curve[p[41]];
    l2 = Voice_EnvelopeLevel_Curve[p[43]];
    if (p[52] != 0) {
        t = Pan_ScaleWithVelocity(*(int *)(v + 8), p[48], p[49], p[50], (char)p[52]);
        if (p[47] != 0) {
            d = PitchBend_Scale((char)p[47], v[12], 4);
            l1 = Int_ClampSignedToRange(l1 + t + d, 0xff, 0);
            l2 = Int_ClampSignedToRange(l2 + t + d, 0xff, 0);
        } else {
            l1 = Int_ClampSignedToRange(l1 + t, 0xff, 0);
            l2 = Int_ClampSignedToRange(l2 + t, 0xff, 0);
        }
    } else if (p[47] != 0) {
        d = PitchBend_Scale((char)p[47], v[12], 4);
        l1 = Int_ClampSignedToRange(l1 + d, 0xff, 0);
        l2 = Int_ClampSignedToRange(l2 + d, 0xff, 0);
    }
    k = Voice_EnvelopeRate_Table[p[42]];
    r = k;
    r = r < 4 ? 4 : r;
    k = Voice_EnvelopeRate_Table[p[44]];
    y = k;
    ram_451ce = (l1 << 8) | (r & 0xff);
    ram_451d0 = (l2 << 8) | (y & 0xff);
}
