/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern void InitChannelState_Che_InitVal(struct nrec *);

void NoteMap_LookupAllocAndStoreResult(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
  struct nrec *rp;
  rp = &r;
  if (NoteMap_LookupVoice(rp, a, 0, e) != 0) {
    rp = &r;
    NoteMap_AllocNewVoiceEntry(rp, e);
    if (x[(unsigned long)((unsigned int)e + 4)] == e) { rp = &r; NoteMap_SetChannelParam(rp, e); }
  }
}

void ProcessNoteOff_Done_Prologue(struct nrec *r, unsigned char *x, unsigned char e)
{
  InitChannelState_Che_InitVal(r);
  NoteMap_AllocNewVoiceEntry(r, e);
  if (x[(unsigned long)((unsigned int)e + 4)] == e) NoteMap_SetChannelParam(r, e);
}
