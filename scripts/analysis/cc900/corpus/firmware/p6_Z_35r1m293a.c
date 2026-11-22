/* Probe round 35r1, helper Z, form a: audio/dsp_config_sysex.s (module 293), the xr_screen.py shape at -O3 -Xr.
   DSPCfg_WriteParamDelta(id, delta): resolve the parameter id to its slot (an error from the resolver is
   returned as it is), add the slot's base (kind 0: its parameter count; kind 1: the table entry of cnt) to delta
   and write the parameter; any other kind gives -1.  delta is a `register` parameter (IZ); the resolver's five
   results are frame cells (declared last-first: kind at the frame base, the slot pointer at +8).  The kinds are a
   switch (compared 1 then 0), each case with its own write call (the ROM shares the call). */
/* cc900-module: DSPCfg_GetParamCount DSPCfg_ReadViaTableLookup DSPCfg_ResolveParamToSlot DSPCfg_WriteParamFull */

extern int DSPCfg_ResolveParamToSlot(unsigned long id, unsigned char **slot, int *grp, int *offs, int *kind, int *cnt);
extern int DSPCfg_GetParamCount(unsigned char *);
extern int DSPCfg_ReadViaTableLookup(int, unsigned char *);
extern int DSPCfg_WriteParamFull(unsigned long, unsigned int);
extern int DSPCfg_WriteParamDelta(unsigned long, unsigned int);

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
