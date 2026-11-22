/* Probe round 35r1, helper Z, form b: audio/dsp_config_sysex.s (module 293).  As form a, but the frame cells
   declared in frame order (kind first) and one write call after the switch, the error as `default`. */
/* cc900-module: DSPCfg_GetParamCount DSPCfg_ReadViaTableLookup DSPCfg_ResolveParamToSlot DSPCfg_WriteParamFull */

extern int DSPCfg_ResolveParamToSlot(unsigned long id, unsigned char **slot, int *grp, int *offs, int *kind, int *cnt);
extern int DSPCfg_GetParamCount(unsigned char *);
extern int DSPCfg_ReadViaTableLookup(int, unsigned char *);
extern int DSPCfg_WriteParamFull(unsigned long, unsigned int);
extern int DSPCfg_WriteParamDelta(unsigned long, unsigned int);

int DSPCfg_WriteParamDelta(unsigned long id, register unsigned int delta)
{
    int kind;
    int cnt;
    int grp;
    int offs;
    unsigned char *slot;
    register int r;

    if ((r = DSPCfg_ResolveParamToSlot(id, &slot, &grp, &offs, &kind, &cnt)) != 0)
        return r;
    switch (kind) {
    case 0:
        delta += DSPCfg_GetParamCount(slot);
        break;
    case 1:
        delta += DSPCfg_ReadViaTableLookup(cnt, slot);
        break;
    default:
        return -1;
    }
    return DSPCfg_WriteParamFull(id, delta);
}
