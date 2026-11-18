/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_3m293a.c (2026-11-18-28-p6-r36)
   sha256 0afa65ca61c887086e96c2d7c8397604f235b3912e395c2c60b89d40c7fff94c (tar-sha256); compiled at -Xr */
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
