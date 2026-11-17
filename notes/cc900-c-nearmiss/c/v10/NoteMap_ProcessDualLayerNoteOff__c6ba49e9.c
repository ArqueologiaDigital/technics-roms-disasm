/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_6a.c (2026-11-16-45-p6-r9)
   sha256 c6ba49e93845d47cb6db1d330d3125848a7d5054c2193ef4a34f5203cc1bc9c2 (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE_SENT[];
extern void NoteMap_ProcessNoteEvent(struct nrec *, unsigned char *, unsigned int);
void NoteMap_ProcessDualLayerNoteOff(unsigned char a, unsigned char c, unsigned char e)
{
  struct nrec r;
  if (c != 0xff && e != 0xff) {
    r.b2 = 2; r.b3 = a;
    NoteMap_ProcessNoteEvent(&r, AUDIO_STATE_SENT, e);
    r.b2 = 3; r.b3 = a;
    NoteMap_ProcessNoteEvent(&r, AUDIO_STATE_SENT, e);
  } else if (c == 0xff && e != 0xff) {
    r.b2 = 2; r.b3 = a;
    NoteMap_ProcessNoteEvent(&r, AUDIO_STATE_SENT, e);
    r.b2 = 3; r.b3 = a;
    NoteMap_ProcessNoteEvent(&r, AUDIO_STATE_SENT, e);
  }
}
