/* lane_sub helper AR, round 39, form c (KN5000 sub-CPU payload v1.42, core/05_voice_params_and_tvf.s).
   The pool's "Voice_Level_ComputeTriplet" (1,389 B) is five functions: span_refs.py shows that TVF_Build_Full,
   Voice_PitchPack_Mode2, Voice_PitchPack_Mode3 and Voice_PitchPack_Mode4_Single are named from outside the span
   (TVF_Build_Dispatch's calr), the other 20 inner labels are inner-only.  So this file holds all five, never
   compiled before:
     Voice_Level_ComputeTriplet   561 B  (from the built sibling Voice_StereoLevel_Compute, voice_params_and_tvf_ap_24b.c)
     TVF_Build_Full               180 B  (from the built TVF_Build_Short, voice_params_and_tvf_a_ia06.c)
     Voice_PitchPack_Mode2        269 B  (TVF_Build_Short / Voice_PitchPack_RouteB, the cutoff sum of Mode5_Dual)
     Voice_PitchPack_Mode3        251 B  (as Mode2; its second path the field pair of Mode5_Dual)
     Voice_PitchPack_Mode4_Single 128 B  (from the built Voice_PitchPack_Mode5_Dual, voice_params_and_tvf_a_11a.c)
   The ROM: ComputeTriplet keeps the record pointer in XIZ for its first half and the second tremolo value in IZ
   after it (V4.23 shares the family between locals whose lives do not overlap, as in AudioChannel_Handler_Cmd04_07);
   the three detunes and three levels are in the frame in that order (declaration order, ascending).  Full / Mode2 /
   Mode3 keep the cutoff r in IZ and the record pointer in the frame; Mode4 keeps the pointer in XIZ and the cutoff
   c in HL (no frame slot).
   Form a: the plain spelling: one record pointer local declared first (p / z), then the ints.
   Form c (what changes against form a):
   - ComputeTriplet: the second tremolo value t is a block-local of the `if (p[21] != 0)` branch, so its life
     cannot overlap the record pointer's (the ROM has p in XIZ, then t in IZ).
   - Full / Mode2 / Mode3: the cutoff `int r;` declared BEFORE the record pointer z (r is the ROM's IZ value).
   - Mode4: no x local; the field pair written inline in the +66 store.
   cc900-options: -Xr
*/

extern int __near ram_2940;
extern unsigned int ram_451ec;
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
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

/* cc900-module: Detune_ScaleSymmetric Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale TVF_Bias_Clamp_Amount TVF_Build_Full TVF_Calc_Cutoff TVF_Lookup_Depth_Amount Voice_Level_ComputeTriplet Voice_PitchPack_Mode2 Voice_PitchPack_Mode3 Voice_PitchPack_Mode4_Single */
void Voice_Level_ComputeTriplet(unsigned char *v)
{
    unsigned char *p;
    int d1, d2, d3;
    int l1, l2, l3;
    int k;
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
        int t;
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

void TVF_Build_Full(unsigned char *v)
{
    int r;
    unsigned char *z;
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

void Voice_PitchPack_Mode2(unsigned char *v)
{
    int r;
    unsigned char *z;
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
    int r;
    unsigned char *z;
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
    z = (*(unsigned char **)((v) + (23)));
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (2))) & 0x200) c = z[77];
    else c = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
    c = TVF_Calc_Cutoff(v, c, (char)z[55], (char)z[60]);
    (*(int *)((v) + (66))) = (c | (((unsigned int)z[78] << 13) | ((unsigned int)z[78] << 10))) | 0x80;
    (*(int *)((v) + (68))) = c | 0x80;
    ram_2940 = 0;
}
