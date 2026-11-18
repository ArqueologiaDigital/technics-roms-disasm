/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/dsp_config_sysex_m293.c (2026-11-18-33-p6-r37)
   sha256 d8275cc5bdd7155e4bea979f39026a82baff54007ece7c934b46c82617b2e5b4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
    p = DspFxRecListPtrTable[fx];
    for (i = 0; i < n; i++) {
        if (p[2] == 0x63)
            r = i;
        p = DSPCfg_PackAddress(p);
    }
    return r;
}
