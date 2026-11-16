/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_7b.c (2026-11-16-53-p6-r11)
   sha256 055bb165f17e4ada5d5cffdf53f6b5255200d3f65d0bb47ed27a1f253a00f0f7 (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
void NoteMap_LookupAllocAndStoreResult(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
 
  if (NoteMap_LookupVoice(&r, a, 0, e) != 0) {
   
    NoteMap_AllocNewVoiceEntry(&r, e);
    if (x[(unsigned long)((unsigned int)e + 4)] == e) NoteMap_SetChannelParam(&r, e);
  }
}
