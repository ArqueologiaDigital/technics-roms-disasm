/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_4m275a.c (2026-11-19-29-p6-r46)
   sha256 0bbbe0a7c06c4416eda89946a066d1a772b485e750a9fe6528b139e4c4537b6d (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8d50;
extern unsigned char __near ram_8d52;
extern int SndParam_LookupReadOnly(long);
extern void SoundParam_NotifyChange(long, int, int);
extern void BitMapOut_CopyVoicePreset9(int, void *);
extern void PanelMemory_Recall(int);
extern void EffectMode_DisplayPresetName(void);
extern void SwbtWr_ReinitOutputBank(void);
void EffectMode_ReinitSoundOutput(void)
{
	ram_8d50 = SndParam_LookupReadOnly(0x302L);
	SoundParam_NotifyChange(0x302L, 1, 0);
	BitMapOut_CopyVoicePreset9(0x80, (void *)0x3c2c4L);
	PanelMemory_Recall(0x80);
	EffectMode_DisplayPresetName();
	ram_8d52 &= ~0x10;
	if (ram_8d50 != 1)
		SoundParam_NotifyChange(0x302L, 0, 0);
	else
		SoundParam_NotifyChange(0x302L, 1, 0);
	SwbtWr_ReinitOutputBank();
}
