/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_6a.c (2026-11-16-45-p6-r9)
   sha256 c6ba49e93845d47cb6db1d330d3125848a7d5054c2193ef4a34f5203cc1bc9c2 (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
struct xpair { unsigned char f0, f1; };
struct xs { unsigned char hdr[4]; unsigned char ch[32]; unsigned char map[256]; struct xpair pr[128]; };
extern void NoteMap_ComputePitchOffset(struct nrec *, struct xs *, unsigned int);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
void NoteMap_ProcessRhythmNoteOn(struct nrec *r, struct xs *x, unsigned char e)
{
  unsigned char v;
  NoteMap_ComputePitchOffset(r, x, e);
  NoteMap_AllocNewVoiceEntry(r, e);
  if (x->ch[e] == e) NoteMap_SetChannelParam(r, e);
  v = x->map[e];
  if (v != 0xff && (x->pr[e].f0 & 0x20)) Voice_ScanAndEmitMidiEvents(r, v);
}
