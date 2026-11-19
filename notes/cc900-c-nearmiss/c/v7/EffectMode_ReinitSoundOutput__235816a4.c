/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_mode_handlers_m275.c (2026-11-19-43-p6-r48)
   sha256 235816a450a641ef0e2a4ecd1f276319a11f01aa24cd197e56a717cd0de9a720 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8cb4;
extern unsigned char __near ram_8cb6;
extern int SndParam_LookupReadOnly(long);
extern void SoundParam_NotifyChange(long, int, int);
extern void BitMapOut_CopyVoicePreset9(int, void *);
extern void PanelMemory_Recall(int);
extern void EffectMode_DisplayPresetName(void);
extern void SwbtWr_ReinitOutputBank(void);
void EffectMode_ReinitSoundOutput(void)
{
	ram_8cb4 = SndParam_LookupReadOnly(0x302L);
	SoundParam_NotifyChange(0x302L, 1, 0);
	BitMapOut_CopyVoicePreset9(0x80, (void *)0x3c2c4L);
	PanelMemory_Recall(0x80);
	EffectMode_DisplayPresetName();
	ram_8cb6 &= ~0x10;
	if (ram_8cb4 != 1)
		SoundParam_NotifyChange(0x302L, 0, 0);
	else
		SoundParam_NotifyChange(0x302L, 1, 0);
	SwbtWr_ReinitOutputBank();
}
