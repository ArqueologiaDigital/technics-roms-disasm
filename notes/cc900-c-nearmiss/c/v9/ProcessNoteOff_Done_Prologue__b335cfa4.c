/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_m297_xr.c (2026-11-16-68-p6-r12)
   sha256 b335cfa42ea42319ebbb7604bb3a22120e29f884b24590211d27ed01d5cecd49 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern void InitChannelState_Che_InitVal(struct nrec *);
void ProcessNoteOff_Done_Prologue(struct nrec *r, unsigned char *x, unsigned char e)
{
  InitChannelState_Che_InitVal(r);
  NoteMap_AllocNewVoiceEntry(r, e);
  if (x[(unsigned long)((unsigned int)e + 4)] == e) NoteMap_SetChannelParam(r, e);
}
