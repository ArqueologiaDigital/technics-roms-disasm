/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 4e6fb15a9dcef11c657d923eaf017b50a32c6776dde159610f29f481be75a22a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
