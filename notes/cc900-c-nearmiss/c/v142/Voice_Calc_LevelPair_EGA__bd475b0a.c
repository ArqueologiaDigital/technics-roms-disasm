/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_8b.c (2026-11-16-82-sub-r8)
   sha256 bd475b0a234905c6efb6c6e86ec9471fb95bc7b36e30ff14fef91b19d3700a28 (name+funcs); compiled at -Xr */
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int Voice_Clamp_Byte_HL(int a);
void Voice_Calc_LevelPair_EGA(unsigned char *v)
{
    unsigned char *s;
    int lv, t;
    s = *(unsigned char **)(v + 23);
    lv = Int_ClampSignedToRange((*(char **)(v + 35))[108] + s[45], 100, 0);
    lv = Voice_EnvelopeLevel_Curve[(unsigned char)lv];
    if ((*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) && !(*(unsigned int *)(v + 1) & 0x100)) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if (t <= lv) lv = t;
    }
    if (s[53] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[48], s[49], s[50], (char)s[53]);
        lv = Voice_Clamp_Byte_HL(lv);
    }
    ram_451f8 = (lv << 8) | 0x80;
    ram_451fa = lv << 8;
}
