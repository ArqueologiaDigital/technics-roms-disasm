/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/dsp_config_sysex_m293.c (2026-11-18-34-p6-r38-staged)
   sha256 79d597b567431f48048bf337287fa70e0897027324f8907185cb1da3898118d0 (tar-sha256); compiled at -Xr
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
