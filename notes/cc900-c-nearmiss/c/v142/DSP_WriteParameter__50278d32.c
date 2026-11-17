/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_9a.c (2026-11-16-86-sub-r9)
   sha256 50278d32d579b37dffe2a8c4368d5dcef6c6061274f0ddf727a7b480425c0cab (name+funcs); compiled at -Xr */
struct bcfg { int a; int b; int c; int d; long e; };
extern struct bcfg ToneGen_WorkArea[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, void *vals, int v,
                                     unsigned char *rec);
void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, unsigned char *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, DSP_Eff9_Param_Values, v,
                                     (unsigned char *)((unsigned long)slot * 56 + 8 + (unsigned long)p) + 4);
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, DSP_EffA_Param_Values, v,
                                     (unsigned char *)((unsigned long)slot * 56 + 8 + (unsigned long)p) + 4);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], DSP_Param_Block_Ptrs_A[type],
                                 v, (unsigned char *)((unsigned long)slot * 56 + 8 + (unsigned long)p) + 4);
    }
}
