/* Functions of audio/dsp_config_sysex.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Fade_SetLevel */   /* staged module names, repair_module_lines.py */

extern unsigned char DspFxParamCountTable[], DspCfg_Data002_ByteTable[];

unsigned int DSPCfg_GetSlotCount(unsigned int i)
{
	return DspFxParamCountTable[i];
}

extern unsigned char __near ram_c154;
extern void SoundParam_NotifyChange(long, int, int);
extern void CtrlPanel_SetIndicatorLED(int);
extern void Fade_SetLevel(int);
extern void Fade_Cancel(void);

void Fade_Cancel(void)
{
    ram_c154 &= 0xf3;
    ram_c154 &= 0xfc;
    SoundParam_NotifyChange(0x40c0, 0, 1);
    CtrlPanel_SetIndicatorLED(0x4d);
    SoundParam_NotifyChange(0x40c1, 0, 1);
    CtrlPanel_SetIndicatorLED(0x4e);
    Fade_SetLevel(0x7f);
}
