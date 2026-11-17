/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_5a.c (2026-11-16-40-p6-r8)
   sha256 58315a41666f04ee926133487ef86173e174b0df3b0582b8acb925367c6d231d (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_3284;
extern void SeqEvt_CallTimingHelper(void);
extern void Voice_UpdatePlayModeState(void);
extern void AccChord_ReadAndStoreKeys(void);
extern void AccChord_CompareAndSetDirty(void);
extern void Rhythm_CompareAndTrigger(void);
void AccTiming_CallHelper(void)
{
    if (ram_3284 & 2) {
        SeqEvt_CallTimingHelper();
        Voice_UpdatePlayModeState();
        AccChord_ReadAndStoreKeys();
        AccChord_CompareAndSetDirty();
        Rhythm_CompareAndTrigger();
    }
}
