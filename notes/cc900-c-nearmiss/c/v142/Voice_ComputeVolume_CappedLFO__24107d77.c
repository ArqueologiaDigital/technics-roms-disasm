/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_9b.c (2026-11-16-86-sub-r9)
   sha256 24107d77b299c2a0b7b8dd207aa28445e75c6c31da771a3b43023d536a3d5ea4 (name+funcs); compiled at -Xr */
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int Voice_Clamp_Byte_HL(int a);
void Voice_ComputeVolume_CappedLFO(unsigned char *v)
{
    unsigned char *s;
    int lv;
    s = *(unsigned char **)(v + 23);
    if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) {
        lv = (int)Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if ((unsigned int)lv <= Voice_EnvelopeLevel_Curve[s[45]]) ;
        else lv = Voice_EnvelopeLevel_Curve[s[45]];
    } else {
        lv = Int_ClampSignedToRange((int)(*(char **)(v + 35))[269] + (int)s[45], 100, 0);
        lv = (int)Voice_EnvelopeLevel_Curve[(unsigned char)lv];
    }
    if (s[53] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[48], s[49], s[50], (char)s[53]);
        lv = Voice_Clamp_Byte_HL(lv);
    }
    ram_451f8 = (lv << 8) | 0x80;
    ram_451fa = lv << 8;
}
