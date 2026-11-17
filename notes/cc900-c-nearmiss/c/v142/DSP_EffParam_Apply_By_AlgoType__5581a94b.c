/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18a.c (2026-11-17-7-sub-r18)
   sha256 5581a94b8744c554c7810133a024cbd218f46e7ca66812c682e8dd6f7e0a7d38 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern void DSP_EffParam_Copy_V0(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V1(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V2(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V3(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V4(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V5(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V6(unsigned int part, unsigned int d);
extern void DSP_EffParam_Copy_V7(unsigned int part, unsigned int d);
void DSP_EffParam_Apply_By_AlgoType(unsigned char part)
{
    switch ((*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf) {
    case 0: DSP_EffParam_Copy_V0(part, 0); break;
    case 1: DSP_EffParam_Copy_V0(part, 1); break;
    case 2: DSP_EffParam_Copy_V0(part, 2); break;
    case 3: DSP_EffParam_Copy_V0(part, 3); break;
    case 4: DSP_EffParam_Copy_V1(part, 4); break;
    case 5: DSP_EffParam_Copy_V1(part, 5); break;
    case 6: DSP_EffParam_Copy_V2(part, 6); break;
    case 7: DSP_EffParam_Copy_V3(part, 7); break;
    case 8: DSP_EffParam_Copy_V4(part, 8); break;
    case 9: DSP_EffParam_Copy_V5(part, 9); break;
    case 10: DSP_EffParam_Copy_V6(part, 10); break;
    case 11: DSP_EffParam_Copy_V7(part, 11); break;
    }
}
