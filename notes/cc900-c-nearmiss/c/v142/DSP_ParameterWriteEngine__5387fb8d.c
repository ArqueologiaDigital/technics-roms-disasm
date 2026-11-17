/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_7a.c (2026-11-16-79-sub-r7)
   sha256 5387fb8dc1a4a10ac803200b808b9746db79da03261b93a1784389397bca675d (name+funcs); compiled at -Xr */
struct bcfg { int a; int b; int c; int d; long e; };
extern unsigned char EFF_SlotToChip_Table[];
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern void DSP_NopReturn();
extern unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, void *st, unsigned char **out);
extern unsigned char *DSP_PerParameterTranslator(int chip, unsigned int slot, int v, unsigned char *p, void *desc,
                                                 unsigned char *rec, struct bcfg *work, int *status);
void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, unsigned char *vals, int v,
                              unsigned char *rec)
{
    int status;
    unsigned char *end;
    int chip;

    chip = EFF_SlotToChip_Table[slot];
    status = 0;
    vals = DSP_TableWalk_SearchWithState(vals, v, &status, &end);
    if (status != 0) {
        DSP_NopReturn(status);
        return;
    }
    while (vals < end) {
        if (chip == 0) {
            status = DSP_DispatchCommand(1, chip);
            status = DSP_DispatchData(1, chip);
            status = DSP_DispatchData(0x60, chip);
        }
        vals = DSP_PerParameterTranslator(chip, slot, v, vals, desc, rec, work, &status);
        if (status != 0) {
            DSP_NopReturn(status);
            return;
        }
        if (chip == 0)
            status = DSP_DispatchCommand(3, chip);
    }
}
