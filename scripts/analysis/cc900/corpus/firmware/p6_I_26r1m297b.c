/* lane_p6 helper I, round 26r1, form b (as form a, but the two table bytes in a second byte variable v declared
   after the loop counter i): module 297 (audio/note_voice_mapping.s), two families of the -Xr NoteMap
   voice allocators.  Family 1 (521 B each, 164-byte nrec record in the frame): NoteMap_CollectAndAllocVoice_Indirect
   (NoteMap_LookupVoice, best slot == 1) and NoteMap_FindAndAllocBestVoice (NoteMap_CollectMatchingEntries, == 0).
   Family 2 (416 B each, record passed in): NoteMap_CollectAndAllocVoice_NoTimerCheck (== 1), NoteMap_UpdateEntry
   (== 0).  One byte variable for the loop and the two table bytes (the ROM keeps both in QIZ's high byte); plain
   &r arguments (the ROM computes &r first and parks it in XDE); index spelling of the built m297 file.
   cc900-options: -Xr
*/
/* cc900-name: NoteMap_CollAllocVoice_Indirect=NoteMap_CollectAndAllocVoice_Indirect */
/* cc900-name: NoteMap_CollAllocVoice_NoTmrChk=NoteMap_CollectAndAllocVoice_NoTimerCheck */
/* cc900-module: NoteMap_AllocateVoice NoteMap_AssignVoiceParams NoteMap_InitVoiceSlots */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };

extern unsigned int __near AUDIO_SEQ_TRACK_FLAGS;
extern unsigned int __near HARMONY_NOTE_LIST;

extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern unsigned char NoteMap_CollectMatchingEntries(struct nrec *, void *, unsigned int, unsigned int);
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

void NoteMap_CollAllocVoice_Indirect(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
  unsigned char i;
  unsigned char v;
  if (e == 0x15) {
    if (NoteMap_LookupVoice(&r, a, 4, 0) != 0) {
      NoteMap_FindEntry(&r, 0);
      if (NoteMap_FindBestVoiceSlot(&r) == 1) {
        NoteMap_AllocateVoice(x, 0);
        NoteMap_AllocateVoice(x, 1);
        if (HARMONY_NOTE_LIST != 0 && NoteMap_FindBestMatch() != 0xff)
          NoteMap_AllocateVoice(x, 2);
      }
      if (AUDIO_SEQ_TRACK_FLAGS & 0x200)
        for (i = 0; i < 16; i++)
          if (x[(unsigned long)((unsigned int)i + 0x84)] == e)
            Voice_BuildAndEmitNoteOnEvents(&r, i);
    }
  } else {
    if (e == x[182] && NoteMap_LookupVoice(&r, a, 4, 2) != 0) {
      NoteMap_FindEntry(&r, 2);
      if (NoteMap_FindBestFreeVoice(&r) == 1 && VoiceMap_AllocateSlot() != 0xff) {
        NoteMap_AssignVoiceParams(x, 2);
        NoteMap_InitVoiceSlots(x, 2);
      }
    }
    if (NoteMap_LookupVoice(&r, a, 0, e) != 0) {
      NoteMap_AllocNewVoiceEntry(&r, e);
      NoteMap_SetChannelParam(&r, e);
      if (AUDIO_SEQ_TRACK_FLAGS & 0x200)
        for (i = 0; i < 16; i++)
          if (x[(unsigned long)((unsigned int)i + 0x84)] == e)
            Voice_BuildAndEmitNoteOnEvents(&r, i);
      if ((v = x[(unsigned long)((unsigned int)e + 0x44)]) != 0xff)
        SeqPart_EmitNoteOnMessages(a, v);
      if ((v = x[(unsigned long)((unsigned int)e + 0x64)]) != 0xff)
        Voice_EmitMidiNoteOnEvents(a, v);
    }
  }
}

void NoteMap_FindAndAllocBestVoice(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
  unsigned char i;
  unsigned char v;
  if (e == 0x15) {
    if (NoteMap_CollectMatchingEntries(&r, a, 4, 0) != 0) {
      NoteMap_FindEntry(&r, 0);
      if (NoteMap_FindBestVoiceSlot(&r) == 0) {
        NoteMap_AllocateVoice(x, 0);
        NoteMap_AllocateVoice(x, 1);
        if (HARMONY_NOTE_LIST != 0 && NoteMap_FindBestMatch() != 0xff)
          NoteMap_AllocateVoice(x, 2);
      }
      if (AUDIO_SEQ_TRACK_FLAGS & 0x200)
        for (i = 0; i < 16; i++)
          if (x[(unsigned long)((unsigned int)i + 0x84)] == e)
            Voice_BuildAndEmitNoteOnEvents(&r, i);
    }
  } else {
    if (e == x[182] && NoteMap_CollectMatchingEntries(&r, a, 4, 2) != 0) {
      NoteMap_FindEntry(&r, 2);
      if (NoteMap_FindBestFreeVoice(&r) == 0 && VoiceMap_AllocateSlot() != 0xff) {
        NoteMap_AssignVoiceParams(x, 2);
        NoteMap_InitVoiceSlots(x, 2);
      }
    }
    if (NoteMap_CollectMatchingEntries(&r, a, 0, e) != 0) {
      NoteMap_AllocNewVoiceEntry(&r, e);
      NoteMap_SetChannelParam(&r, e);
      if (AUDIO_SEQ_TRACK_FLAGS & 0x200)
        for (i = 0; i < 16; i++)
          if (x[(unsigned long)((unsigned int)i + 0x84)] == e)
            Voice_BuildAndEmitNoteOnEvents(&r, i);
      if ((v = x[(unsigned long)((unsigned int)e + 0x44)]) != 0xff)
        SeqPart_EmitNoteOnMessages(a, v);
      if ((v = x[(unsigned long)((unsigned int)e + 0x64)]) != 0xff)
        Voice_EmitMidiNoteOnEvents(a, v);
    }
  }
}

void NoteMap_CollAllocVoice_NoTmrChk(struct nrec *r, unsigned char *x, unsigned char e)
{
  unsigned char i;
  unsigned char v;
  if (e == 0x15) {
    NoteMap_FindEntry(r, 0);
    if (NoteMap_FindBestVoiceSlot(r) == 1) {
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
      if (NoteMap_FindBestFreeVoice(r) == 1 && VoiceMap_AllocateSlot() != 0xff) {
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
    if ((v = x[(unsigned long)((unsigned int)e + 0x44)]) != 0xff)
      SeqPart_EmitNoteOnMessages(r, v);
    if ((v = x[(unsigned long)((unsigned int)e + 0x64)]) != 0xff)
      Voice_EmitMidiNoteOnEvents(r, v);
    if (x[3] == 0)
      NoteMap_EmitNoteOnEvents(r, 0);
  }
}

void NoteMap_UpdateEntry(struct nrec *r, unsigned char *x, unsigned char e)
{
  unsigned char i;
  unsigned char v;
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
    if ((v = x[(unsigned long)((unsigned int)e + 0x44)]) != 0xff)
      SeqPart_EmitNoteOnMessages(r, v);
    if ((v = x[(unsigned long)((unsigned int)e + 0x64)]) != 0xff)
      Voice_EmitMidiNoteOnEvents(r, v);
    if (x[3] == 0)
      NoteMap_EmitNoteOnEvents(r, 0);
  }
}
