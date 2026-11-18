/* Phase 6, lane_p6 helper I, round 4, module 285 (midi/midi_dispatch_handlers.s), form a.  New.
   DataBuf_InitSlotFromPreset(slot): resets a song record: slot 0 is the current song (SEQ_SONG_RECORD), slot n the
   n-th 0x800-byte record of SEQ_SONG_SLOTS; the 32-byte header at +0x2e0 comes from DataSlot_HeaderTemplate and
   the sound-parameter block at +0x300 from SndParamRam_DefaultImage, its length the distance from 0xf9a0 to
   PANEL_PMEM_SETTINGS + 12.
   Read from the hand assembly: slot in IZ (pushw iz), the template address loaded once before the test; the
   record addresses get +0x2e0 / +0x300 added after the base (the slots' base an immediate after the scaled index:
   a pointer converted to Mem_Copy's void *); the default image pushed as two immediate words; the length a pointer
   difference truncated to a word.  Form b: the records as a 0x800-byte struct array with member offsets.
   The pool's 172 bytes also hold SndParam_SaturationClamp (not written here). */

extern unsigned char SEQ_SONG_RECORD[];
extern unsigned char SEQ_SONG_SLOTS[];
extern unsigned char __near PANEL_PMEM_SETTINGS[];
extern unsigned char DataSlot_HeaderTemplate[];
extern unsigned char SndParamRam_DefaultImage[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void DataBuf_InitSlotFromPreset(unsigned int slot);

void DataBuf_InitSlotFromPreset(unsigned int slot)
{
    if (slot == 0) {
        Mem_Copy(SEQ_SONG_RECORD + 0x2e0, DataSlot_HeaderTemplate, 0x20);
        Mem_Copy(SEQ_SONG_RECORD + 0x300, SndParamRam_DefaultImage,
                 &PANEL_PMEM_SETTINGS[12] - (unsigned char *)0xf9a0L);
    } else {
        Mem_Copy(SEQ_SONG_SLOTS + (unsigned long)(slot - 1) * 0x800 + 0x2e0, DataSlot_HeaderTemplate, 0x20);
        Mem_Copy(SEQ_SONG_SLOTS + (unsigned long)(slot - 1) * 0x800 + 0x300, SndParamRam_DefaultImage,
                 &PANEL_PMEM_SETTINGS[12] - (unsigned char *)0xf9a0L);
    }
}
