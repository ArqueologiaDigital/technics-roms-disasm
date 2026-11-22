/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_playback_modes_m203_xr.c (2026-11-21-5-p6-r60)
   sha256 bbf19bffc8224f01d25b0f98e85cfdb8d14e45a019faf3584ba471f80567ee3b (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_1d46;
extern void SeqRecPlay_EnablePlayOnly(void);
extern void SeqRecPlay_EnableRecordOnly(void);
extern void Acc_TransitionPlayMode(void);
extern void Acc_StopPlayMode(void);
void CDlikeSwTtl_SongConfirmDispatch(void)
{
  switch (ram_1d46) {
  case 3:
  case 1:
    SeqRecPlay_EnablePlayOnly();
    Acc_TransitionPlayMode();
    break;
  case 2:
    SeqRecPlay_EnableRecordOnly();
    Acc_StopPlayMode();
    break;
  }
}
