/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_m297_xr.c (2026-11-16-68-p6-r12)
   sha256 b335cfa42ea42319ebbb7604bb3a22120e29f884b24590211d27ed01d5cecd49 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
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
