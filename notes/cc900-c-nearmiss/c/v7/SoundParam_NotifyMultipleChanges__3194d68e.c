/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/tonegen_fileio_handlers_m277.c (2026-11-18-12-p6-r35)
   sha256 3194d68ee1e66847ab3a99592b478107504583f6d54b4ab63735140f980be510 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8dd0;
extern unsigned char __near ram_8dd2;
extern unsigned char __near ram_8dd4;
extern void SoundParam_NotifyChange(long, int, int);
extern void BitMapOut_DetectChanges(void);
extern void ToneGen_DiffScanAndUpdate(void);
void SoundParam_NotifyMultipleChanges(void)
{
	SoundParam_NotifyChange(0, ram_8dd0, 0);
	SoundParam_NotifyChange(0x102, ram_8dd2, 0);
	SoundParam_NotifyChange(0x103, ram_8dd4, 0);
	BitMapOut_DetectChanges();
	ToneGen_DiffScanAndUpdate();
}
