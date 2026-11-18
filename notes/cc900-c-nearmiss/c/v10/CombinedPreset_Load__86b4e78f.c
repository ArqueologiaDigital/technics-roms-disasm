/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_1m280a.c (2026-11-18-12-p6-r35)
   sha256 86b4e78fa51d1495ad874fe104e17b91ea1306f1b493b8528ad3d42c5bce738f (tar-sha256); compiled at -Xr */
extern unsigned char __near PANEL_DIGITAL_REVERB[];
extern unsigned char __near PANEL_EQUALIZER[];
extern unsigned char *CombinedPreset_Table[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void AssswbWr();
extern void SoundParam_NotifyChange(long, int, int);
void CombinedPreset_Load(unsigned char n)
{
    unsigned char *p;
    unsigned int i;

    p = CombinedPreset_Table[n];
    Mem_Copy(PANEL_DIGITAL_REVERB, p, 24);
    for (i = 0; i < 24; i++)
        AssswbWr(0x63, (unsigned char)i, PANEL_DIGITAL_REVERB[i], 0xff);
    Mem_Copy(PANEL_EQUALIZER, p + 24, 24);
    for (i = 0; i < 24; i++)
        AssswbWr(0x64, (unsigned char)i, PANEL_EQUALIZER[i], 0xff);
    SoundParam_NotifyChange(0x4002L, 0x7f, 1);
    SoundParam_NotifyChange(0x4006L, 1, 1);
}
