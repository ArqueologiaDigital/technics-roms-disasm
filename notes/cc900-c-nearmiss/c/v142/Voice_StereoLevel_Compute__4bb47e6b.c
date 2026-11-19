/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_23c.c (2026-11-19-18-sub-r23r-apdsp)
   sha256 4bb47e6b1f423e635d51a32314f6d326c8f5e602a1de1990e6490e2ab9aef8e9 (name+funcs); compiled at -Xr
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
    unsigned char *s;
    int l1, l2, l3;
    int k, t, d;
    if ((s = *(unsigned char **)(v + 23))[71] != 0) {
        k = PitchBend_Scale((char)s[71], v[12], 4);
        if (s[63] != 0) l1 = Voice_EnvelopeLevel_Curve[s[63]] + k;
        else l1 = Voice_EnvelopeLevel_Curve[s[63]];
        if (s[65] != 0) l2 = Voice_EnvelopeLevel_Curve[s[65]] + k;
        else l2 = Voice_EnvelopeLevel_Curve[s[65]];
        if (s[67] != 0) l3 = k + Voice_EnvelopeLevel_Curve[s[67]];
        else l3 = Voice_EnvelopeLevel_Curve[s[67]];
    } else {
        l1 = Voice_EnvelopeLevel_Curve[s[63]];
        l2 = Voice_EnvelopeLevel_Curve[s[65]];
        l3 = Voice_EnvelopeLevel_Curve[s[67]];
    }
    if (s[74] != 0) l1 += Pan_ScaleWithVelocity(*(int *)(v + 8), s[73], 0, 0x7f, (char)s[74]);
    l1 = Int_ClampSignedToRange(l1, 0xff, 0);
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[64] + (int)(char)s[61], 50, -50));
    ram_451f2 = (l1 << 8) | (d & 0xff);
    if (s[75] != 0) {
        t = Pan_ScaleWithVelocity(*(int *)(v + 8), s[73], 0, 0x7f, (char)s[75]);
        l2 = Int_ClampSignedToRange(l2 + t, 0xff, 0);
        l3 = Int_ClampSignedToRange(l3 + t, 0xff, 0);
    } else {
        l2 = Int_ClampSignedToRange(l2, 0xff, 0);
        l3 = Int_ClampSignedToRange(l3, 0xff, 0);
    }
    t = Int_ClampSignedToRange((int)(char)s[66] + (int)(char)s[61], 50, -50);
    t = Detune_ScaleSymmetric(t);
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[68] + (int)(char)s[61], 50, -50));
    ram_451f4 = (l2 << 8) | (t & 0xff);
    ram_451f6 = (l3 << 8) | (d & 0xff);
}
