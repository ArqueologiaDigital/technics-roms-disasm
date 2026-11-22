/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_36r1m297a.c (2026-11-22-25-p6-r92)
   sha256 7f8c59f49a09593acd9671941ea5209a6a5fb76e2d8186541488c4422471f824 (tar-sha256); compiled at -Xr */
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
