/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_6b.c (2026-11-16-45-p6-r9)
   sha256 84113556c95c5c53bef51bea75448519f5a46d2841d96c959a0458287fbdba8f (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
void NoteMap_LookupAllocAndStoreResult(void *a, unsigned char *x, unsigned char e)
{
  struct nrec r;
  if (NoteMap_LookupVoice(&r, a, 0, e) != 0) {
    NoteMap_AllocNewVoiceEntry(&r, e);
    if (x[(unsigned long)(e + 4)] == e) NoteMap_SetChannelParam(&r, e);
  }
}
