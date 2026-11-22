/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m293a.c (2026-11-22-23-p6-r90)
   sha256 d0d1aab7f592efae2482cd6f3d67cc433e2c7ddfc5e64f5b04dba1318a6ff801 (tar-sha256); compiled at -O3 -Xr */
struct dsp6 { unsigned char b[6]; };
extern struct dsp6 *DSPCfg_LookupAndExtract_PtrTable[];
extern unsigned int DSPCfg_GetSlotCount(int);
extern void DSPCfg_ExtractPairFromStruct(struct dsp6 *, int *, int *, int *, int *);
int DSPCfg_ClampAndExtract(register int id, unsigned int slot, int *p)
{
    int r;
    int min;
    int max;
    int b;
    int a;
    int v;

    v = *p;
    if (slot < DSPCfg_GetSlotCount(id)) {
        DSPCfg_ExtractPairFromStruct(DSPCfg_LookupAndExtract_PtrTable[(unsigned int)id] + slot, &min, &max, &a, &b);
        if (v < min) {
            r = -2;
            v = min;
        } else if (v > max) {
            r = -3;
            v = max;
        } else
            r = 0;
    } else
        r = -1;
    *p = v;
    return r;
}
