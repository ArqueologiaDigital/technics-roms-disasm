/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m293b.c (2026-11-22-23-p6-r90)
   sha256 3663e2390472735762755095c2360bee75c3a8c7f862b05cffa3a79cb9701f5c (tar-sha256); compiled at -Xr */
struct dsp6 { unsigned char b[6]; };
extern struct dsp6 *DSPCfg_LookupAndExtract_PtrTable[];
extern unsigned int DSPCfg_GetSlotCount(unsigned int);
extern void DSPCfg_ExtractPairFromStruct(struct dsp6 *, int *, int *, int *, int *);
int DSPCfg_ClampAndExtract(register unsigned int id, unsigned int slot, int *p)
{
    int r;
    int min;
    int max;
    int b;
    int a;
    int v;

    v = *p;
    if (slot >= DSPCfg_GetSlotCount(id))
        r = -1;
    else {
        DSPCfg_ExtractPairFromStruct(DSPCfg_LookupAndExtract_PtrTable[id] + slot, &min, &max, &a, &b);
        if (v < min) {
            r = -2;
            v = min;
        } else if (v > max) {
            r = -3;
            v = max;
        } else
            r = 0;
    }
    *p = v;
    return r;
}
