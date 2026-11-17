/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -O3 -Xr */
extern void Part_WriteByte(unsigned char, unsigned int, unsigned char);
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char *SeqStep_ReinitPartTable(void);
extern void SeqData_CopyBlockToBuffer(unsigned int);
unsigned char *SeqSavePre(void)
{
  unsigned char *r = SeqStep_ReinitPartTable();
  SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
  Part_WriteByte(1, 4, 1);
  return r;
}
