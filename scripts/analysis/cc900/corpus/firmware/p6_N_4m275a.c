/* lane_p6 helper N, round 4, form a: module 275 (ui/ui_mode_handlers.s), new function.
   EffectMode_ReinitSoundOutput: reads sound parameter 0x302 into 0x8d50, notifies it, copies voice preset 0x80
   from 0x3c2c4 (a numeric pointer: the ROM loads it with `ld xbc,imm`), recalls panel memory 0x80, redraws the
   preset name, clears bit 4 of 0x8d52, notifies 0x302 again with 1 when 0x8d50 is 1 (else 0) and re-inits the
   output bank (tail jump).  The ROM keeps the `else` case inline and shares the notify call (V4.23's cross jump).
   cc900-options: -O3 -Xr
*/
/* cc900-module: EffectMode_DisplayPresetName */

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
