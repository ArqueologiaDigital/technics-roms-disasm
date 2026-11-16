/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_14b.c (2026-11-16-100-p6-r19)
   sha256 4593df46c7ccd0fe04e84b3b12d7adf29ec8187be773eb6acc8acb80e215a928 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near ram_2652;
extern void SeqPart_InitClear(void);
void SeqPart_UndoAllocOnError(void)
{
  if (!(SEQ_EDIT_FLAGS & 0x80)) return;
  if (SEQ_ERROR_CODE == 0) return;
  SEQ_TRACK = ram_2652;
  SeqPart_InitClear();
  return;
}
