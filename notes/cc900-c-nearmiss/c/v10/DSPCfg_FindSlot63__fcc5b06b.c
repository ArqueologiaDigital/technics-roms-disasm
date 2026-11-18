/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_3m293b.c (2026-11-18-28-p6-r36)
   sha256 fcc5b06b9915c3f0398147d94e3792a4018759844b16e1cbf4c6d96fa2b4442a (tar-sha256); compiled at -O3 -Xr */
extern unsigned char *DspFxRecListPtrTable[];
extern int DSPCfg_GetSlotCount(int fx);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
int DSPCfg_FindSlot63(int fx)
{
    int r;
    int n;
    int i;
    unsigned char *p;

    r = -1;
    n = DSPCfg_GetSlotCount(fx);
    p = ((unsigned char **)(long)DspFxRecListPtrTable)[fx];
    for (i = 0; i < n; i++) {
        if (p[2] == 0x63)
            r = i;
        p = DSPCfg_PackAddress(p);
    }
    return r;
}
