/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_7b.c (2026-11-16-53-p6-r11)
   sha256 055bb165f17e4ada5d5cffdf53f6b5255200d3f65d0bb47ed27a1f253a00f0f7 (tar-sha256); compiled at -Xr */
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
