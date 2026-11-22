/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_26r1m297a.c (2026-11-22-5-p6-r72)
   sha256 642390c5afd448ecd4486b3e56bcc403ea86033c1b96eb55fcf7fdd0807c3cc9 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned int __near AUDIO_SEQ_TRACK_FLAGS;
extern unsigned int __near HARMONY_NOTE_LIST;
extern void NoteMap_FindEntry(struct nrec *, unsigned int);
extern unsigned char NoteMap_FindBestVoiceSlot(struct nrec *);
extern unsigned char NoteMap_FindBestFreeVoice(struct nrec *);
extern unsigned char NoteMap_FindBestMatch(void);
extern unsigned char VoiceMap_AllocateSlot(void);
extern void NoteMap_AllocateVoice(unsigned char *, unsigned int);
extern void NoteMap_AssignVoiceParams(unsigned char *, unsigned int);
extern void NoteMap_InitVoiceSlots(unsigned char *, unsigned int);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern void Voice_BuildAndEmitNoteOnEvents(struct nrec *, unsigned int);
extern void SeqPart_EmitNoteOnMessages(void *, unsigned int);
extern void Voice_EmitMidiNoteOnEvents(void *, unsigned int);
extern void NoteMap_EmitNoteOnEvents(struct nrec *, unsigned int);
void NoteMap_UpdateEntry(struct nrec *r, unsigned char *x, unsigned char e)
{
  unsigned char i;
  if (e == 0x15) {
    NoteMap_FindEntry(r, 0);
    if (NoteMap_FindBestVoiceSlot(r) == 0) {
      NoteMap_AllocateVoice(x, 0);
      NoteMap_AllocateVoice(x, 1);
      if (HARMONY_NOTE_LIST != 0 && NoteMap_FindBestMatch() != 0xff)
        NoteMap_AllocateVoice(x, 2);
    }
    if (AUDIO_SEQ_TRACK_FLAGS & 0x200)
      for (i = 0; i < 16; i++)
        if (x[(unsigned long)((unsigned int)i + 0x84)] == e)
          Voice_BuildAndEmitNoteOnEvents(r, i);
    if (x[3] == 0)
      NoteMap_EmitNoteOnEvents(r, 1);
  } else {
    if (e == x[182]) {
      NoteMap_FindEntry(r, 2);
      if (NoteMap_FindBestFreeVoice(r) == 0 && VoiceMap_AllocateSlot() != 0xff) {
        NoteMap_AssignVoiceParams(x, 2);
        NoteMap_InitVoiceSlots(x, 2);
      }
    }
    NoteMap_AllocNewVoiceEntry(r, e);
    NoteMap_SetChannelParam(r, e);
    if (AUDIO_SEQ_TRACK_FLAGS & 0x200)
      for (i = 0; i < 16; i++)
        if (x[(unsigned long)((unsigned int)i + 0x84)] == e)
          Voice_BuildAndEmitNoteOnEvents(r, i);
    if ((i = x[(unsigned long)((unsigned int)e + 0x44)]) != 0xff)
      SeqPart_EmitNoteOnMessages(r, i);
    if ((i = x[(unsigned long)((unsigned int)e + 0x64)]) != 0xff)
      Voice_EmitMidiNoteOnEvents(r, i);
    if (x[3] == 0)
      NoteMap_EmitNoteOnEvents(r, 0);
  }
}
