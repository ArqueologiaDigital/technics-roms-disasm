/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m235.c (2026-11-21-5-p6-r60)
   sha256 977683b578571284fc22dae25fe0670b23005954d0c59229f1ff39ea4c3f0659 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char SEQ_SONG_SLOTS[];
extern long FileIO_WriteByte_Impl(void *, long);
void SeqSave_WriteBlockToFile(unsigned char a)
{
  FileIO_WriteByte_Impl((void *)(SEQ_SONG_SLOTS + ((unsigned long)a << 11)), 0x800L);
}
