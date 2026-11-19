/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern int __near ram_2940;
extern unsigned int ram_451a0;
extern unsigned int ram_451a2;
extern unsigned int ram_451a4;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void Voice_Level_ComputeTriplet(unsigned char *v);
void TVF_Build_Full(unsigned char *v);
void Voice_PitchPack_Mode2(unsigned char *v);
void Voice_PitchPack_Mode3(unsigned char *v);
void Voice_PitchPack_Mode4_Single(unsigned char *v);
void TVF_Build_Full(unsigned char *v);
void Voice_Level_ComputeTriplet(unsigned char *v);
void Voice_PitchPack_Mode2(unsigned char *v);
void Voice_PitchPack_Mode3(unsigned char *v);
void Voice_PitchPack_Mode4_Single(unsigned char *v);

/* cc900-module: Detune_ScaleSymmetric Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale TVF_Bias_Clamp_Amount TVF_Build_Full TVF_Calc_Cutoff TVF_Lookup_Depth_Amount Voice_Level_ComputeTriplet Voice_PitchPack_Mode2 Voice_PitchPack_Mode3 Voice_PitchPack_Mode4_Single */
void TVF_Build_Full(unsigned char *v)
{
    unsigned char *z;
    int r;
    unsigned int x;
    z = (*(unsigned char **)((v) + (23)));
    r = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
    r = TVF_Calc_Cutoff(v, r, (char)z[55], (char)z[60]);
    x = ((unsigned int)z[78] << 13) | 0x400;
    (*(int *)((v) + (66))) = r | x;
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (2))) & 0x200) {
        r = TVF_Bias_Clamp_Amount(0x48);
        (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(0x8d);
    } else {
        r = TVF_Bias_Clamp_Amount(z[79]);
        (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(z[80]);
    }
}

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
    ram_451a0 = (l1 << 8) | (d1 & 0xff);
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
    ram_451a2 = (l2 << 8) | (d2 & 0xff);
    ram_451a4 = (l3 << 8) | (d3 & 0xff);
}

void Voice_PitchPack_Mode2(unsigned char *v)
{
    unsigned char *z;
    int r;
    unsigned int x;
    z = (*(unsigned char **)((v) + (23)));
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (2))) & 0x200) {
        r = (int)z[77] - (char)(*(unsigned char **)((v) + (35)))[103];
        r = TVF_Calc_Cutoff(v, r, (char)z[55], (char)z[60]);
        x = ((unsigned int)z[78] << 13) | 0x400;
        (*(int *)((v) + (66))) = (r | x) | 0x80;
        r = TVF_Bias_Clamp_Amount(0x48);
        (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(0x8d);
    } else {
        r = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
        r = TVF_Calc_Cutoff(v, r, (char)z[55], (char)z[60]);
        x = ((unsigned int)z[78] << 13) | 0x400;
        (*(int *)((v) + (66))) = (r | x) | 0x80;
        r = TVF_Bias_Clamp_Amount(z[79]);
        (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(z[80]);
    }
}

void Voice_PitchPack_Mode3(unsigned char *v)
{
    unsigned char *z;
    int r;
    unsigned int x;
    z = (*(unsigned char **)((v) + (23)));
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (2))) & 0x200) {
        r = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
        r = TVF_Calc_Cutoff(v, r, (char)z[55], (char)z[60]);
        x = ((unsigned int)z[78] << 13) | 0x400;
        (*(int *)((v) + (66))) = r | x;
        r = TVF_Bias_Clamp_Amount(0x48);
        (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(0x8d);
    } else {
        r = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
        r = TVF_Calc_Cutoff(v, r, (char)z[55], (char)z[60]);
        x = ((unsigned int)z[78] << 13) | ((unsigned int)z[78] << 10);
        (*(int *)((v) + (66))) = r | x;
        (*(int *)((v) + (68))) = r;
        ram_2940 = 0;
    }
}

void Voice_PitchPack_Mode4_Single(unsigned char *v)
{
    unsigned char *z;
    int c;
    unsigned int x;
    z = (*(unsigned char **)((v) + (23)));
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (2))) & 0x200) c = z[77];
    else c = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
    c = TVF_Calc_Cutoff(v, c, (char)z[55], (char)z[60]);
    x = ((unsigned int)z[78] << 13) | ((unsigned int)z[78] << 10);
    (*(int *)((v) + (66))) = (c | x) | 0x80;
    (*(int *)((v) + (68))) = c | 0x80;
    ram_2940 = 0;
}
