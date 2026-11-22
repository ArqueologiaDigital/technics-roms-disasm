/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_35r1m293a.c (2026-11-22-23-p6-r90)
   sha256 587ec76ec9372333d06e7c6aecd82ffa69e51f738096557714bbbe0c9eef31a2 (tar-sha256); compiled at -O3 -Xr */
extern int DSPCfg_ResolveParamToSlot(unsigned long id, unsigned char **slot, int *grp, int *offs, int *kind, int *cnt);
extern int DSPCfg_GetParamCount(unsigned char *);
extern int DSPCfg_ReadViaTableLookup(int, unsigned char *);
extern int DSPCfg_WriteParamFull(unsigned long, unsigned int);
int DSPCfg_WriteParamDelta(unsigned long id, register unsigned int delta)
{
    unsigned char *slot;
    int offs;
    int grp;
    int cnt;
    int kind;
    register int r;

    if ((r = DSPCfg_ResolveParamToSlot(id, &slot, &grp, &offs, &kind, &cnt)) != 0)
        return r;
    switch (kind) {
    case 0:
        delta += DSPCfg_GetParamCount(slot);
        return DSPCfg_WriteParamFull(id, delta);
    case 1:
        delta += DSPCfg_ReadViaTableLookup(cnt, slot);
        return DSPCfg_WriteParamFull(id, delta);
    }
    return -1;
}
