/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_8a.c (2026-11-16-72-p6-r13)
   sha256 c5a8acb47ebac3a65e9d3c9b79a934fb9eaa1f9fc364eb885803eefd3fd4ab16 (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void NoteMap_ComputePitchOffset(struct nrec *, unsigned char *, unsigned int);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
extern unsigned char NoteMap_CollectMatchingEntries(struct nrec *, void *, unsigned int, unsigned int);
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
