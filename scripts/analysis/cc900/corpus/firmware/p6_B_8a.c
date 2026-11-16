/* Phase 6, helper B, round 8, form a: one-spot refinements of the NoteMap_* routines of v10's
   audio/note_voice_mapping.s (no -O).  The firmware loads the table byte into E and compares it through A
   (an assignment inside the test); the 2-byte field index is an int (e widened before the * 2); the local
   byte v is declared before the record pointer rp. */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void NoteMap_ComputePitchOffset(struct nrec *, unsigned char *, unsigned int);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern unsigned char NoteMap_CollectMatchingEntries(struct nrec *, void *, unsigned int, unsigned int);

void NoteMap_ProcessRhythmNoteOn(struct nrec *r, unsigned char *x, unsigned char e)
{
  unsigned char v;
  NoteMap_ComputePitchOffset(r, x, e);
  NoteMap_AllocNewVoiceEntry(r, e);
  if (x[(unsigned long)((unsigned int)e + 4)] == e) NoteMap_SetChannelParam(r, e);
  if ((v = x[(unsigned long)((unsigned int)e + 0x24)]) != 0xff && (x[(unsigned int)e * 2 + 0x124] & 0x20))
    Voice_ScanAndEmitMidiEvents(r, v);
}

void NoteMap_LookupAndAllocVoice(void *a, unsigned char *x, unsigned char e)
{
  unsigned char v;
  struct nrec r;
  struct nrec *rp;
  rp = &r;
  if (NoteMap_LookupVoice(rp, a, 0, e) != 0) {
    rp = &r;
    NoteMap_AllocNewVoiceEntry(rp, e);
    if (x[(unsigned long)((unsigned int)e + 4)] == e) { rp = &r; NoteMap_SetChannelParam(rp, e); }
    if ((v = x[(unsigned long)((unsigned int)e + 0x24)]) != 0xff && (x[(unsigned int)e * 2 + 0x124] & 0x20))
      Voice_ScanAndEmitMidiEvents(&r, v);
  } else {
    if (x[(unsigned long)((unsigned int)e + 4)] == e) { rp = &r; NoteMap_SetChannelParam(rp, e); }
  }
}

void NoteMap_ProcessRhythmRemap(void *a, unsigned char *x, unsigned char e)
{
  unsigned char v;
  struct nrec r;
  struct nrec *rp;
  rp = &r;
  if (NoteMap_CollectMatchingEntries(rp, a, 0, e) == 0) return;
  rp = &r;
  NoteMap_ComputePitchOffset(rp, x, e);
  rp = &r;
  NoteMap_AllocNewVoiceEntry(rp, e);
  if (x[(unsigned long)((unsigned int)e + 4)] == e) { rp = &r; NoteMap_SetChannelParam(rp, e); }
  if ((v = x[(unsigned long)((unsigned int)e + 0x24)]) != 0xff && (x[(unsigned int)e * 2 + 0x124] & 0x20))
    Voice_ScanAndEmitMidiEvents(&r, v);
}
