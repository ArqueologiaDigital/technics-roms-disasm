/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m235.c (2026-11-16-111-p6-r22-staged)
   sha256 2a78fcddc032094c763d5086f20356f864dfbe2ec471ecb6bb387d5901b89f78 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near ram_29ae;
extern unsigned int __near ram_29b0;
void SeqLoad_RestoreFreeBlockList(void)
{
  SEQ_FREE_LIST_HEAD = ram_29ae;
  SEQ_FREE_BLOCKS = ram_29b0;
}
