/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/tonegen_fileio_handlers_m277.c (2026-11-18-12-p6-r35)
   sha256 e9af8039936602373f63834865743ad6964b34a998456a9bd3aa2f025e82396c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
