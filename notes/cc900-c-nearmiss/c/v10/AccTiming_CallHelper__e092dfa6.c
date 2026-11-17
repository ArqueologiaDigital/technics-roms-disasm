/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_5b.c (2026-11-16-40-p6-r8)
   sha256 e092dfa680c8d9ce8506cdb5b8df148f8e610a6d1a4b2818f2b7087e306f1a75 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_3284;
extern void SeqEvt_CallTimingHelper(void);
extern void Voice_UpdatePlayModeState(void);
extern void AccChord_ReadAndStoreKeys(void);
extern void AccChord_CompareAndSetDirty(void);
extern void Rhythm_CompareAndTrigger(void);
void AccTiming_CallHelper(void)
{
    if ((ram_3284 & 2) == 0)
        return;
    SeqEvt_CallTimingHelper();
    Voice_UpdatePlayModeState();
    AccChord_ReadAndStoreKeys();
    AccChord_CompareAndSetDirty();
    Rhythm_CompareAndTrigger();
}
