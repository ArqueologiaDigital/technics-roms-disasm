/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_4b.c (2026-11-16-62-sub-r4)
   sha256 3f6b729e7593b6348d4062d2bc31effd2d177be96053ddeab43e3728401960d2 (name+funcs); compiled at -Xr */
struct bcfg { int a; int b; int c; int d; long e; };
struct pent { char pad[4]; unsigned char f[52]; };
struct pblk { char pad[8]; struct pent e[100]; };
extern struct bcfg ToneGen_WorkArea[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, void *vals, int v,
                                     unsigned char *rec);
void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, struct pblk *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, DSP_Eff9_Param_Values, v,
                                     (unsigned char *)((unsigned long)&p->e[slot] + 4));
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, DSP_EffA_Param_Values, v,
                                     (unsigned char *)((unsigned long)&p->e[slot] + 4));
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], DSP_Param_Block_Ptrs_A[type],
                                 v, (unsigned char *)((unsigned long)&p->e[slot] + 4));
    }
}
