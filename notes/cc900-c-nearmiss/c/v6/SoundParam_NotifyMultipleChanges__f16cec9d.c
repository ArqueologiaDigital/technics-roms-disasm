/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/tonegen_fileio_handlers_m277.c (2026-11-18-12-p6-r35)
   sha256 f16cec9d5848aaf23ac582e9741561f4d10963218ad6d3afd7ddc4da1484cef5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8dac;
extern unsigned char __near ram_8dae;
extern unsigned char __near ram_8db0;
extern void SoundParam_NotifyChange(long, int, int);
extern void BitMapOut_DetectChanges(void);
extern void ToneGen_DiffScanAndUpdate(void);
void SoundParam_NotifyMultipleChanges(void)
{
	SoundParam_NotifyChange(0, ram_8dac, 0);
	SoundParam_NotifyChange(0x102, ram_8dae, 0);
	SoundParam_NotifyChange(0x103, ram_8db0, 0);
	BitMapOut_DetectChanges();
	ToneGen_DiffScanAndUpdate();
}
