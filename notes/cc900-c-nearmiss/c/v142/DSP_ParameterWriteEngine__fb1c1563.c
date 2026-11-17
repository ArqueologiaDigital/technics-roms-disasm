/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_6b.c (2026-11-16-73-sub-r6)
   sha256 fb1c1563ed8850e15aa1e32d11bf5d2b2bb7c77f193680f3555aae9537d41b3f (name+funcs); compiled at -Xr */
struct bcfg { int a; int b; int c; int d; long e; };
extern unsigned char EFF_SlotToChip_Table[];
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern void DSP_NopReturn();
extern unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out);
extern unsigned char *DSP_PerParameterTranslator(int chip, unsigned int slot, int v, unsigned char *p, void *desc,
                                                 unsigned char *rec, struct bcfg *work, int *status);
void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, void *vals, int v,
                              unsigned char *rec)
{
    int status;
    unsigned char *end;
    int chip;
    unsigned char *p;

    chip = EFF_SlotToChip_Table[slot];
    status = 0;
    p = DSP_TableWalk_SearchWithState(vals, v, &status, &end);
    if (status != 0) {
        DSP_NopReturn(status);
        return;
    }
    while (p < end) {
        if (chip == 0) {
            status = DSP_DispatchCommand(1, chip);
            status = DSP_DispatchData(1, chip);
            status = DSP_DispatchData(0x60, chip);
        }
        p = DSP_PerParameterTranslator(chip, slot, v, p, desc, rec, work, &status);
        if (status != 0) {
            DSP_NopReturn(status);
            return;
        }
        if (chip == 0)
            status = DSP_DispatchCommand(3, chip);
    }
}
