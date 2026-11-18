/* FORM B of p6_I_3m293a.c (the table through a converted pointer).  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 3, module 293 (audio/dsp_config_sysex.s), form a.  New.
   DSPCfg_FindSlot63(fx): walks effect fx's packed record list (DspFxRecListPtrTable[fx], DSPCfg_GetSlotCount(fx)
   records, each next one from DSPCfg_PackAddress) and returns the index of the last record whose byte +2 is 0x63,
   or -1.  Read from the hand assembly: the result in the frame, fx then the index in IZ, the count in QIZ, the record
   pointer in XWA (the call's argument and result); the table indexed with exts + sll 2 (unsized array, 32-bit index)
   and its base loaded as an immediate; the loop test copied to the entry (-O3).
   Form a: the table as a plain extern array; form b: read through a converted pointer (lane_hd's idiom for an
   immediate base).  The pool's 146 bytes also hold DSPCfg_Data_003 and an unlabelled routine, not written here. */
/* cc900-module: DSPCfg_GetSlotCount DSPCfg_PackAddress */

extern unsigned char *DspFxRecListPtrTable[];
extern int DSPCfg_GetSlotCount(int fx);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
extern int DSPCfg_FindSlot63(int fx);

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
