/* Phase 6, helper B, round 8, form b: the functions of p6_B_8a.c with the table byte compared as loaded (no
   assignment in the test) and v declared in the inner block, so the record pointer rp is the first local. */

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
  v = x[(unsigned long)((unsigned int)e + 0x24)];
  if (v != 0xff && (x[(unsigned int)e * 2 + 0x124] & 0x20)) Voice_ScanAndEmitMidiEvents(r, v);
}

void NoteMap_LookupAndAllocVoice(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
  struct nrec *rp;
  rp = &r;
  if (NoteMap_LookupVoice(rp, a, 0, e) != 0) {
    unsigned char v;
    rp = &r;
    NoteMap_AllocNewVoiceEntry(rp, e);
    if (x[(unsigned long)((unsigned int)e + 4)] == e) { rp = &r; NoteMap_SetChannelParam(rp, e); }
    v = x[(unsigned long)((unsigned int)e + 0x24)];
    if (v != 0xff && (x[(unsigned int)e * 2 + 0x124] & 0x20)) Voice_ScanAndEmitMidiEvents(&r, v);
  } else {
    if (x[(unsigned long)((unsigned int)e + 4)] == e) { rp = &r; NoteMap_SetChannelParam(rp, e); }
  }
}

void NoteMap_ProcessRhythmRemap(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
  struct nrec *rp;
  rp = &r;
  if (NoteMap_CollectMatchingEntries(rp, a, 0, e) == 0) return;
  rp = &r;
  NoteMap_ComputePitchOffset(rp, x, e);
  rp = &r;
  NoteMap_AllocNewVoiceEntry(rp, e);
  if (x[(unsigned long)((unsigned int)e + 4)] == e) { rp = &r; NoteMap_SetChannelParam(rp, e); }
  {
    unsigned char v = x[(unsigned long)((unsigned int)e + 0x24)];
    if (v != 0xff && (x[(unsigned int)e * 2 + 0x124] & 0x20)) Voice_ScanAndEmitMidiEvents(&r, v);
  }
}
