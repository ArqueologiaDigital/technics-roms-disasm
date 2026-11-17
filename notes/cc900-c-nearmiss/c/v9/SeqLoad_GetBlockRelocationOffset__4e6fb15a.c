/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 4e6fb15a9dcef11c657d923eaf017b50a32c6776dde159610f29f481be75a22a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_FREE_LIST_HEAD;
unsigned int SeqLoad_GetBlockRelocationOffset(void)
{
  unsigned int r = 0;
  unsigned int h = SEQ_FREE_LIST_HEAD;
  if (h != 0) r = h - 1;
  return r;
}
