/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_36r1m299a.c (2026-11-22-25-p6-r92)
   sha256 d5a178b535f1d95434a7786d98b59ae32a9b23fcacb908af38c627e96d29628f (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern unsigned char NoteMap_ClaimVoiceSlot(struct nrec *, void *, unsigned int, unsigned int);
void PopIzStoreRet_WriteReg(unsigned char a, unsigned char c, unsigned char e)
{
  struct nrec k;
  struct nrec r;

  if (c == 0xff && e != 0xff) {
    k.b2 = 0;
    k.b3 = 0;
    if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
      NoteMap_SetChannelParam(&r, e);
    k.b2 = 4;
    k.b3 = 0xff;
    if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
      NoteMap_SetChannelParam(&r, e);
    k.b2 = 6;
    k.b3 = 0xff;
    if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
      NoteMap_SetChannelParam(&r, e);
  }
  if (c != 0xff && c != e && (a == 0x15 || a == 2)) {
    k.b2 = 6;
    k.b3 = 0xff;
    if (NoteMap_ClaimVoiceSlot(&r, &k, 0, a) != 0)
      NoteMap_SetChannelParam(&r, c);
  }
}
