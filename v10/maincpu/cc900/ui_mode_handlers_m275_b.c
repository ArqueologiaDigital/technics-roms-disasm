/* Functions of ui/ui_mode_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: EffectMode_DisplayPresetName */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_8d50;
extern unsigned char __near ram_8d52;
extern int SndParam_LookupReadOnly(long);
extern void SoundParam_NotifyChange(long, int, int);
extern void BitMapOut_CopyVoicePreset9(int, void *);
extern void PanelMemory_Recall(int);
extern void EffectMode_DisplayPresetName(void);
extern void SwbtWr_ReinitOutputBank(void);
extern void EffectMode_ReinitSoundOutput(void);

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
