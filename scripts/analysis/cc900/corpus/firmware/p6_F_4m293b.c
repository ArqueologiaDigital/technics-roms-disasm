/* lane_p6 helper F, round 4, module 293 (audio/dsp_config_sysex.s), form b.
   Fade_Cancel as in form a, with RAM 0xc1f0 as a bit-field byte (V4.23 fills unsigned char bit-fields from
   bit 7 down: four upper bits, then the 2-bit fields at bits 3..2 and 1..0 that the ROM clears). */

/* cc900-module: Fade_SetLevel */

struct FadeState { unsigned char hi : 4; unsigned char mode : 2; unsigned char run : 2; };
extern struct FadeState __near ram_c1f0;
extern void SoundParam_NotifyChange(long, int, int);
extern void CtrlPanel_SetIndicatorLED(int);
extern void Fade_SetLevel(int);

void Fade_Cancel(void)
{
    ram_c1f0.mode = 0;
    ram_c1f0.run = 0;
    SoundParam_NotifyChange(0x40c0, 0, 1);
    CtrlPanel_SetIndicatorLED(0x4d);
    SoundParam_NotifyChange(0x40c1, 0, 1);
    CtrlPanel_SetIndicatorLED(0x4e);
    Fade_SetLevel(0x7f);
}
