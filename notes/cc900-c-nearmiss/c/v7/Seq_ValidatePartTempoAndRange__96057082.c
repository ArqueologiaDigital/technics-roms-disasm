/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m234.c (2026-11-16-111-p6-r22-staged)
   sha256 96057082564aad4810f639161de48cb27e23aab7d0acecc00e114ba0cea9b669 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern unsigned char __near ram_2616;
extern unsigned char __near ram_2658;
extern int Seq_ValidatePartNumber();
extern int Seq_ValidateTempoValue(unsigned int);
int Seq_ValidatePartTempoAndRange(void)
{
  if (SEQ_TRACK != 0x11 && Seq_ValidatePartNumber(SEQ_TRACK) != 0) return -1;
  if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0) return -1;
  if (Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0) return -1;
  if (ram_2616 > 127 || ram_2658 > 127) return -1;
  return 0;
}
