/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near PANEL_DIGITAL_REVERB[];
extern unsigned char __near PANEL_EQUALIZER[];
extern unsigned char *CombinedPreset_Table[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void AssswbWr();
extern void SoundParam_NotifyChange(long, int, int);
extern void CombinedPreset_Load(unsigned char n);

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
