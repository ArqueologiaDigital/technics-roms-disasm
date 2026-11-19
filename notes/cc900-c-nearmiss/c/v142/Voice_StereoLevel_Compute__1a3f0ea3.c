/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_23b.c (2026-11-19-18-sub-r23r-apdsp)
   sha256 1a3f0ea3ac41eaafba6d717c9a830ae8415599bef6258604a10ecb2aad062d93 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
void Voice_StereoLevel_Compute(unsigned char *v)
{
    unsigned char *p;
    unsigned char *s;
    int l[3];
    int k, t, d;
    p = *(unsigned char **)(v + 23);
    s = p;
    if (p[71] != 0) {
        k = PitchBend_Scale((char)s[71], v[12], 4);
        if (s[63] != 0) l[0] = k + Voice_EnvelopeLevel_Curve[s[63]];
        else l[0] = Voice_EnvelopeLevel_Curve[s[63]];
        if (s[65] != 0) l[1] = k + Voice_EnvelopeLevel_Curve[s[65]];
        else l[1] = Voice_EnvelopeLevel_Curve[s[65]];
        if (s[67] != 0) l[2] = Voice_EnvelopeLevel_Curve[s[67]] + k;
        else l[2] = Voice_EnvelopeLevel_Curve[s[67]];
    } else {
        l[0] = Voice_EnvelopeLevel_Curve[s[63]];
        l[1] = Voice_EnvelopeLevel_Curve[s[65]];
        l[2] = Voice_EnvelopeLevel_Curve[s[67]];
    }
    if (s[74] != 0) l[0] += Pan_ScaleWithVelocity(*(int *)(v + 8), s[73], 0, 0x7f, (char)s[74]);
    l[0] = Int_ClampSignedToRange(l[0], 0xff, 0);
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[64] + (int)(char)s[61], 50, -50));
    ram_451f2 = (l[0] << 8) | (d & 0xff);
    if (s[75] != 0) {
        t = Pan_ScaleWithVelocity(*(int *)(v + 8), s[73], 0, 0x7f, (char)s[75]);
        l[1] = Int_ClampSignedToRange(l[1] + t, 0xff, 0);
        l[2] = Int_ClampSignedToRange(l[2] + t, 0xff, 0);
    } else {
        l[1] = Int_ClampSignedToRange(l[1], 0xff, 0);
        l[2] = Int_ClampSignedToRange(l[2], 0xff, 0);
    }
    t = Int_ClampSignedToRange((int)(char)s[66] + (int)(char)s[61], 50, -50);
    t = Detune_ScaleSymmetric(t);
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[68] + (int)(char)s[61], 50, -50));
    ram_451f4 = (l[1] << 8) | (t & 0xff);
    ram_451f6 = (l[2] << 8) | (d & 0xff);
}
