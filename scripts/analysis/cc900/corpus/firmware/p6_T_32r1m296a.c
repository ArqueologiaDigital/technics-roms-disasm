/* Probe round 32r1, helper T, form a: audio/note_voice_mapping.s (module 296).
   Voice_InitSlotData: copy the held chord notes (CHORD_NOTE_COUNT[1..n]) into the note slots at 0xcf04 + 2i with
   velocity byte 0x40 at 0xcf03 + 2i, then allocate voices for both halves of AUDIO_STATE. */

extern unsigned char __near CHORD_NOTE_COUNT[];
extern unsigned int __near CHORD_HELD_KEY_COUNT;
extern unsigned char __near ram_cf00[];
extern unsigned char __near ram_cf03[];
extern unsigned char __near AUDIO_STATE[];
extern void Voice_InitPartAllocState(void);
extern void NoteMap_AllocateVoice(unsigned char *, unsigned int);
extern void Voice_InitSlotData(void);

void Voice_InitSlotData(void)
{
    int i;

    CHORD_HELD_KEY_COUNT = CHORD_NOTE_COUNT[0];
    for (i = 0; i < CHORD_NOTE_COUNT[0]; i++) {
        ram_cf00[i * 2 + 4] = CHORD_NOTE_COUNT[i + 1];
        ram_cf03[i * 2] = 0x40;
    }
    Voice_InitPartAllocState();
    NoteMap_AllocateVoice(AUDIO_STATE, 0);
    NoteMap_AllocateVoice(AUDIO_STATE, 1);
    CHORD_HELD_KEY_COUNT = 0;
}
