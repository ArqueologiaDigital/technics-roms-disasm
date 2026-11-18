/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_14m277a.c (2026-11-18-1-p6-r33)
   sha256 8b4e2e7f33672596a78e593a3b95718fd8f4282f84cbff85913ed29a01ac5ec2 (tar-sha256); compiled at -O3 -Xr */
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
