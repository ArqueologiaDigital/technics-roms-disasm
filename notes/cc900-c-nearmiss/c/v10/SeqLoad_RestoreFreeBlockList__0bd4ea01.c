/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m235.c (2026-11-16-111-p6-r22-staged)
   sha256 0bd4ea0167bc05b4b398e2ce68513d816ea8d530ebc3d812796827ab891a6b65 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near ram_29ca;
extern unsigned int __near ram_29cc;
void SeqLoad_RestoreFreeBlockList(void)
{
  SEQ_FREE_LIST_HEAD = ram_29ca;
  SEQ_FREE_BLOCKS = ram_29cc;
}
