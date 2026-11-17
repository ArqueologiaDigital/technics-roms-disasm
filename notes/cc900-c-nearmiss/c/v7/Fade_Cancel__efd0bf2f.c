/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/dsp_config_sysex_m293.c (2026-11-16-92-p6-r18)
   sha256 efd0bf2f6257c367212b53339450f2ed159a7f8891d49d0cf2274d98ebe0df52 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_c154;
extern void SoundParam_NotifyChange(long, int, int);
extern void CtrlPanel_SetIndicatorLED(int);
extern void Fade_SetLevel(int);
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
