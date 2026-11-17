/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m234.c (2026-11-16-111-p6-r22-staged)
   sha256 83e57315c375c1c940336c1fd470f4631a66d0a489ca456b1c516c63985f9806 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern unsigned char __near ram_25fc;
extern unsigned char __near ram_263e;
extern int Seq_ValidatePartNumber();
extern int Seq_ValidateTempoValue(unsigned int);
int Seq_ValidatePartTempoAndRange(void)
{
  if (SEQ_TRACK != 0x11 && Seq_ValidatePartNumber(SEQ_TRACK) != 0) return -1;
  if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0) return -1;
  if (Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0) return -1;
  if (ram_25fc > 127 || ram_263e > 127) return -1;
  return 0;
}
