/* Phase 6, lane_p6 helper I, round 1, module 280 (audio/audio_control_engine.s, an -O3 -Xr file), form a.  New.
   CombinedPreset_Load(n): copies the n-th combined preset's 24-byte digital-reverb and 24-byte equalizer records
   into the panel (PANEL_DIGITAL_REVERB / PANEL_EQUALIZER at 0xfc8e / 0xfca8), sends each byte to the DSP queue
   (AssswbWr(tag, index, value, 0xff)) and notifies the two parameters.
   Read from the hand assembly: the preset pointer in the frame, the index in IZ (pushw iz), the panel addresses
   pushed as two immediate words (a __near array passed as a pointer), AssswbWr called without a prototype (its
   arguments come extz'd to int from bytes, the fourth on the stack, callee-popped). */

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
