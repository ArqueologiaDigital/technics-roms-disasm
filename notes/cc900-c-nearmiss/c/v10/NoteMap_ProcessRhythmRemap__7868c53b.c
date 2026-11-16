/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_7a.c (2026-11-16-53-p6-r11)
   sha256 7868c53b4be9ae7e465581991b52a8087d74fac06d150e81c007ed067f52a205 (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void NoteMap_ComputePitchOffset(struct nrec *, unsigned char *, unsigned int);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
extern unsigned char NoteMap_CollectMatchingEntries(struct nrec *, void *, unsigned int, unsigned int);
void NoteMap_ProcessRhythmRemap(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
  struct nrec *rp;
  unsigned char v;
  rp = &r;
  if (NoteMap_CollectMatchingEntries(rp, a, 0, e) == 0) return;
  rp = &r;
  NoteMap_ComputePitchOffset(rp, x, e);
  rp = &r;
  NoteMap_AllocNewVoiceEntry(rp, e);
  if (x[(unsigned long)((unsigned int)e + 4)] == e) { rp = &r; NoteMap_SetChannelParam(rp, e); }
  v = x[(unsigned long)((unsigned int)e + 0x24)];
  if (v != 0xff && (x[e * 2 + 0x124] & 0x20)) Voice_ScanAndEmitMidiEvents(&r, v);
}
