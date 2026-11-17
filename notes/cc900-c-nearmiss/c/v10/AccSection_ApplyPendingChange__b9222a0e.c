/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_16m249a.c (2026-11-16-100-p6-r19)
   sha256 b9222a0e17e51a1054d35a3e2ed7e4b15d008e1f044b11e2240e31f435edd280 (tar-sha256); compiled at -O3 -Xr
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
    unsigned char *r;
    if ((ram_341f & 1) == 0)
        return;
    Rhythm_SendChanPressure_Wrap();
    AccBuf_ResetAll4_Wrap();
    r = (unsigned char *)0x94860 + RhythmTiming_OffsetTable[ram_3421];
    ram_3426 = r;
    AccTuning_CopyAllPartsFromStyle_Wrap(r);
    ACC_LANES_RESYNC |= 63;
    ACC_LANES_RESYNC |= 0x80;
    AccTone_IBDC_Helper2();
    ACC_CHORD_VOICED_TYPE = ACC_CHORD_TYPE;
    ACC_CHORD_VOICED_ROOT = ACC_CHORD_ROOT;
    ACC_CHORD_VOICED_BASS = ACC_CHORD_BASS;
    ram_341f &= ~1;
}
