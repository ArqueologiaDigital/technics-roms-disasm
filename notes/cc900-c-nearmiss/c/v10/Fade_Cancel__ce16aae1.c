/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_4m293a.c (2026-11-16-88-p6-r16)
   sha256 ce16aae11fc2a3d4827b26dc6e1f047d1dbf2ddd952f9abab15d4b6d7c53a26c (tar-sha256); compiled at -O3 -XS -Xr */
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
