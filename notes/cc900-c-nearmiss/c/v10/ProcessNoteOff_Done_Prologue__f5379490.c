/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5b.c (2026-11-16-45-p6-r9)
   sha256 f537949078528ed18dfc0b0b9e694946b4d167de54df22a7a21a6f0ca0494772 (tar-sha256); compiled at -O3 -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void InitChannelState_Che_InitVal(struct nrec *);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
void ProcessNoteOff_Done_Prologue(struct nrec *r, unsigned char *x, unsigned char e)
{
  unsigned long k;
  InitChannelState_Che_InitVal(r);
  NoteMap_AllocNewVoiceEntry(r, e);
  k = e + 4;
  if (x[k] == e) NoteMap_SetChannelParam(r, e);
}
