/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_10a.c (2026-11-16-90-sub-r10)
   sha256 6def4334393a34554eac6ed8e6a3f038b85a58ba9862378261f0ef33018b0276 (name+funcs); compiled at -Xr */
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
    int lv, t;
    s = *(unsigned char **)(v + 23);
    if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        lv = t;
        if ((unsigned int)lv > (unsigned int)Voice_EnvelopeLevel_Curve[s[45]]) {
            t = Voice_EnvelopeLevel_Curve[s[45]];
            lv = t;
        }
    } else {
        lv = Int_ClampSignedToRange((int)s[45] + (int)(*(char **)(v + 35))[269], 100, 0);
        t = Voice_EnvelopeLevel_Curve[(unsigned char)lv];
        lv = t;
    }
    if (s[53] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[48], s[49], s[50], (char)s[53]);
        lv = Voice_Clamp_Byte_HL(lv);
    }
    ram_451f8 = (lv << 8) | 0x80;
    ram_451fa = lv << 8;
}
