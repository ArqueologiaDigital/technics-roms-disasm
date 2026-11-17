/* Phase 6, lane_p6 helper G, round 14, module 277 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a:
   SoundParam_NotifyMultipleChanges (audio/tonegen_fileio_handlers.s), new.  Reports three sound parameters to
   SoundParam_NotifyChange (ids 0, 0x102, 0x103, values the bytes at 0x8e6c / 0x8e6e / 0x8e70 widened to int, third
   argument 0), then calls BitMapOut_DetectChanges and ends with a jump into ToneGen_DiffScanAndUpdate (V4.23's tail
   call for the last, argument-less call).  Cells reached with 16-bit operands are __near. */
/* cc900-module: ToneGen_DiffScanAndUpdate */

extern unsigned char __near ram_8e6c;
extern unsigned char __near ram_8e6e;
extern unsigned char __near ram_8e70;
extern void SoundParam_NotifyChange(long, int, int);
extern void BitMapOut_DetectChanges(void);
extern void ToneGen_DiffScanAndUpdate(void);

void SoundParam_NotifyMultipleChanges(void)
{
	SoundParam_NotifyChange(0, ram_8e6c, 0);
	SoundParam_NotifyChange(0x102, ram_8e6e, 0);
	SoundParam_NotifyChange(0x103, ram_8e70, 0);
	BitMapOut_DetectChanges();
	ToneGen_DiffScanAndUpdate();
}
