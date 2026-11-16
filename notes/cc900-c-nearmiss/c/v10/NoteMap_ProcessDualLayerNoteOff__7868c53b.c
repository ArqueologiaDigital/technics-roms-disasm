/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_7a.c (2026-11-16-53-p6-r11)
   sha256 7868c53b4be9ae7e465581991b52a8087d74fac06d150e81c007ed067f52a205 (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE_SENT[];
extern void NoteMap_ProcessNoteEvent(struct nrec *, unsigned char *, unsigned int);
void NoteMap_ProcessDualLayerNoteOff(unsigned char a, unsigned char c, unsigned char e)
{
  struct nrec r;
  struct nrec *rp;
  if (c != 0xff && e != 0xff) {
    r.b2 = 2; r.b3 = a; rp = &r;
    NoteMap_ProcessNoteEvent(rp, AUDIO_STATE_SENT, e);
    r.b2 = 3; r.b3 = a; rp = &r;
    NoteMap_ProcessNoteEvent(rp, AUDIO_STATE_SENT, e);
  } else if (c == 0xff && e != 0xff) {
    r.b2 = 2; r.b3 = a; rp = &r;
    NoteMap_ProcessNoteEvent(rp, AUDIO_STATE_SENT, e);
    r.b2 = 3; r.b3 = a; rp = &r;
    NoteMap_ProcessNoteEvent(rp, AUDIO_STATE_SENT, e);
  }
}
