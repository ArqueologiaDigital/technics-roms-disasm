/* lane_p6 helper F, round 4, module 293 (audio/dsp_config_sysex.s), form a.
   Fade_Cancel: clear the fade state bits of RAM 0xc1f0, notify parameters 0x40c0 / 0x40c1, switch off the two
   fade LEDs and end with a tail jump to Fade_SetLevel(0x7f) (a module-local callee, `jr` in the ROM).
   __near: 16-bit absolute operand; plain: 24-bit (or a ROM label).  One declarator per __near declaration. */

/* cc900-module: Fade_SetLevel */

extern unsigned char __near ram_c1f0;
extern void SoundParam_NotifyChange(long, int, int);
extern void CtrlPanel_SetIndicatorLED(int);
extern void Fade_SetLevel(int);

void Fade_Cancel(void)
{
    ram_c1f0 &= 0xf3;
    ram_c1f0 &= 0xfc;
    SoundParam_NotifyChange(0x40c0, 0, 1);
    CtrlPanel_SetIndicatorLED(0x4d);
    SoundParam_NotifyChange(0x40c1, 0, 1);
    CtrlPanel_SetIndicatorLED(0x4e);
    Fade_SetLevel(0x7f);
}
