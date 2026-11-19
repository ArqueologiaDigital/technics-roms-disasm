/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AR_39a.c (2026-11-19-84-sub-r39r)
   sha256 2103e71b9b99cb10996fb18388a6d3195fa891b82022ede544f65b9919caffea (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int ram_451ec;
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
void Voice_Level_ComputeTriplet(unsigned char *v)
{
    unsigned char *p;
    int d1, d2, d3;
    int l1, l2, l3;
    int k, t;
    p = *(unsigned char **)(v + 23);
    if (((char *)p)[7] < 0) {
        d1 = ~(int)(char)p[10] + 1;
        d2 = ~(int)(char)p[12] + 1;
        d3 = ~(int)(char)p[14] + 1;
    } else {
        d1 = (char)p[10];
        d2 = (char)p[12];
        d3 = (char)p[14];
    }
    if (p[17] != 0) {
        k = PitchBend_Scale((char)p[17], v[12], 4);
        if (p[9] != 0) l1 = Voice_EnvelopeLevel_Curve[p[9]] + (unsigned int)k;
        else l1 = Voice_EnvelopeLevel_Curve[p[9]];
        if (p[11] != 0) l2 = Voice_EnvelopeLevel_Curve[p[11]] + (unsigned int)k;
        else l2 = Voice_EnvelopeLevel_Curve[p[11]];
        if (p[13] != 0) l3 = k + Voice_EnvelopeLevel_Curve[p[13]];
        else l3 = Voice_EnvelopeLevel_Curve[p[13]];
    } else {
        l1 = Voice_EnvelopeLevel_Curve[p[9]];
        l2 = Voice_EnvelopeLevel_Curve[p[11]];
        l3 = Voice_EnvelopeLevel_Curve[p[13]];
    }
    if (p[20] != 0) l1 += Pan_ScaleWithVelocity(*(int *)(v + 8), p[19], 0, 0x7f, (char)p[20]);
    l1 = Int_ClampSignedToRange(l1, 0xff, 0);
    d1 = Detune_ScaleSymmetric(d1);
    ram_451ec = (l1 << 8) | (d1 & 0xff);
    if (p[21] != 0) {
        t = Pan_ScaleWithVelocity(*(int *)(v + 8), p[19], 0, 0x7f, (char)p[21]);
        l2 = Int_ClampSignedToRange(l2 + t, 0xff, 0);
        l3 = Int_ClampSignedToRange(l3 + t, 0xff, 0);
    } else {
        l2 = Int_ClampSignedToRange(l2, 0xff, 0);
        l3 = Int_ClampSignedToRange(l3, 0xff, 0);
    }
    d2 = Detune_ScaleSymmetric(d2);
    d3 = Detune_ScaleSymmetric(d3);
    ram_451ee = (l2 << 8) | (d2 & 0xff);
    ram_451f0 = (l3 << 8) | (d3 & 0xff);
}
