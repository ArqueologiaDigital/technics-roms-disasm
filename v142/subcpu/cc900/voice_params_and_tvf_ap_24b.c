/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
void Voice_StereoLevel_Compute(unsigned char *v);

/* cc900-module: Detune_ScaleSymmetric Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Voice_StereoLevel_Compute */
void Voice_StereoLevel_Compute(unsigned char *v)
{
    unsigned char *p;
    unsigned char *s;
    int l1, l2, l3;
    int k, t, d;
    p = *(unsigned char **)(v + 23);
    s = p;
    if (p[71] != 0) {
        k = PitchBend_Scale((char)s[71], v[12], 4);
        if (s[63] != 0) l1 = Voice_EnvelopeLevel_Curve[s[63]] + (unsigned int)k;
        else l1 = Voice_EnvelopeLevel_Curve[s[63]];
        if (s[65] != 0) l2 = Voice_EnvelopeLevel_Curve[s[65]] + (unsigned int)k;
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
