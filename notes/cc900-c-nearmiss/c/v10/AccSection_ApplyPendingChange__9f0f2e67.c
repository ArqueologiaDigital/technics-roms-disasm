/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_16m249b.c (2026-11-16-100-p6-r19)
   sha256 9f0f2e67df390303dacaafc02f99462df0766d196505a81a246ba4c4361ff11d (tar-sha256); compiled at -O3 -Xr
   cc900-name: AccTone_IBDC_Helper2=AccTone_InlineBytecodeData_Code_Helper2 */
extern unsigned char __near ram_341f;
extern unsigned char __near ram_3421;
extern unsigned char *__near ram_3426;
extern unsigned char __near ACC_LANES_RESYNC;
extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ACC_CHORD_ROOT;
extern unsigned char __near ACC_CHORD_BASS;
extern unsigned char __near ACC_CHORD_VOICED_TYPE;
extern unsigned char __near ACC_CHORD_VOICED_ROOT;
extern unsigned char __near ACC_CHORD_VOICED_BASS;
extern unsigned long RhythmTiming_OffsetTable[];
extern void Rhythm_SendChanPressure_Wrap(void);
extern void AccBuf_ResetAll4_Wrap(void);
extern void AccTuning_CopyAllPartsFromStyle_Wrap(unsigned char *rec);
extern void AccTone_IBDC_Helper2(void);
void AccSection_ApplyPendingChange(void)
{
    if (ram_341f & 1) {
        Rhythm_SendChanPressure_Wrap();
        AccBuf_ResetAll4_Wrap();
        AccTuning_CopyAllPartsFromStyle_Wrap(ram_3426 = (unsigned char *)0x94860 + RhythmTiming_OffsetTable[ram_3421]);
        ACC_LANES_RESYNC |= 63;
        ACC_LANES_RESYNC |= 0x80;
        AccTone_IBDC_Helper2();
        ACC_CHORD_VOICED_TYPE = ACC_CHORD_TYPE;
        ACC_CHORD_VOICED_ROOT = ACC_CHORD_ROOT;
        ACC_CHORD_VOICED_BASS = ACC_CHORD_BASS;
        ram_341f &= ~1;
    }
}
