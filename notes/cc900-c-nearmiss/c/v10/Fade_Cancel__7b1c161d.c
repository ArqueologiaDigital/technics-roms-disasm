/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_4m293b.c (2026-11-16-88-p6-r16)
   sha256 7b1c161daced00218e7d409b53cb4f37ccb60a5594bdd2e1d924e45850459cfe (tar-sha256); compiled at -O3 -Xr */
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
