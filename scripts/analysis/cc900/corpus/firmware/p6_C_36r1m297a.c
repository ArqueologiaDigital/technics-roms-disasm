/* Probe round 36r1, helper C, form a: audio/note_voice_mapping.s (module 297), unoptimised -Xr shape.
   NoteMap_ProcessNoteEvent(k, x, e): for e == 0x15, look the voice up (mode 4, 0), find its entry, and when the best
   slot is 2 or 3 allocate voices 0 and 1 (and 2 when the harmony list has a best match); otherwise, for e == x[182],
   look up (4, 2), and on slot 2 / 3 claim a slot and assign / init voice 2, else assign voice 2 and clear the two
   allocator cells; then the common tail: look up (0, e), add the entry, set the channel parameter when the channel
   map says so, emit MIDI for the mapped voice (a `register` char, kept in E: not live across a call).
   The record r is the built NoteMap_LookupAllocAndStoreResult's struct nrec (164 B, frame +0). */
/* cc900-module: NoteMap_AllocateVoice NoteMap_AssignVoiceParams NoteMap_InitVoiceSlots */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
struct xpair { unsigned char f0, f1; };
struct vx { unsigned char pad[0x124]; struct xpair pr[128]; };
extern unsigned int __near HARMONY_NOTE_LIST;
extern unsigned int __near ram_ce66;
extern unsigned char __near ram_ceb2;
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern void NoteMap_FindEntry(struct nrec *, unsigned int);
extern unsigned char NoteMap_FindBestVoiceSlot(struct nrec *);
extern unsigned char NoteMap_FindBestFreeVoice(struct nrec *);
extern unsigned char NoteMap_FindBestMatch(void);
extern unsigned char VoiceMap_AllocateSlot(void);
extern void NoteMap_AllocateVoice(struct vx *, unsigned int);
extern void NoteMap_AssignVoiceParams(struct vx *, unsigned int);
extern void NoteMap_InitVoiceSlots(struct vx *, unsigned int);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
extern void NoteMap_ProcessNoteEvent(void *k, struct vx *x, unsigned char e);

void NoteMap_ProcessNoteEvent(void *k, struct vx *x, unsigned char e)
{
  struct nrec r;
  register unsigned char v;

  if (e == 0x15) {
    if (NoteMap_LookupVoice(&r, k, 4, 0) == 0)
      return;
    NoteMap_FindEntry(&r, 0);
    switch (NoteMap_FindBestVoiceSlot(&r)) {
    case 2:
    case 3:
      NoteMap_AllocateVoice(x, 0);
      NoteMap_AllocateVoice(x, 1);
      if (HARMONY_NOTE_LIST != 0 && NoteMap_FindBestMatch() != 0xff)
        NoteMap_AllocateVoice(x, 2);
      break;
    }
    return;
  }
  if (e == x->pad[182] && NoteMap_LookupVoice(&r, k, 4, 2) != 0) {
    NoteMap_FindEntry(&r, 2);
    switch (NoteMap_FindBestFreeVoice(&r)) {
    case 2:
    case 3:
      if (VoiceMap_AllocateSlot() != 0xff) {
        NoteMap_AssignVoiceParams(x, 2);
        NoteMap_InitVoiceSlots(x, 2);
      }
      break;
    default:
      NoteMap_AssignVoiceParams(x, 2);
      ram_ce66 = 0;
      ram_ceb2 = 0;
      break;
    }
  }
  if (NoteMap_LookupVoice(&r, k, 0, e) != 0) {
    NoteMap_AllocNewVoiceEntry(&r, e);
    if (x->pad[(unsigned long)((unsigned int)r.b3 + 0x94)] == e)
      NoteMap_SetChannelParam(&r, e);
    v = x->pad[(unsigned long)((unsigned int)r.b3 + 0xa4)];
    if (v != 0xff && (x->pr[e].f0 & 0x20))
      Voice_ScanAndEmitMidiEvents(&r, v);
  }
}
